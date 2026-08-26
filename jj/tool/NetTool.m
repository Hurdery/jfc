//
//  NetTool.m
//  jj
//
//  Created by LY_MD on 2020/7/17.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import "NetTool.h"
#import "AlertTool.h"
#import <CoreFoundation/CoreFoundation.h>
/// 数据来源天天基金
#define ttFundEstimatePrimaryURL @"https://fund.eastmoney.com/data/funddataforgznew.aspx"
#define ttFundEstimateBackupURL @"https://qcloud.fund.eastmoney.com/data/funddataforgznew.aspx"
#define ttFundQDIIBackupURL @"https://www.haoetf.com/qdii/"
#define ttFundBaseURL @"https://fundmobapi.eastmoney.com/FundMApi/FundBaseTypeInformation.ashx"
static NSTimeInterval const kFundRequestTimeout = 5.0;

/// 与 JDZ 保持一致的请求头，避免估值接口因来源校验返回空内容。
static NSDictionary *FundEstimateHeaders(void) {
    return @{
        @"Referer": @"https://fund.eastmoney.com/",
        @"User-Agent": @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    };
}

/// 从 jsonp(...) 中提取 JSON；不依赖固定回调名，接口调整回调名时仍可解析。
static NSDictionary *FundDictionaryFromJSONPResponse(id responseObject) {
    NSString *body = nil;
    if ([responseObject isKindOfClass:[NSData class]]) {
        body = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    } else if ([responseObject isKindOfClass:[NSString class]]) {
        body = responseObject;
    }
    NSRange jsonStart = [body rangeOfString:@"{"];
    NSRange jsonEnd = [body rangeOfString:@"}" options:NSBackwardsSearch];
    if (!body || jsonStart.location == NSNotFound || jsonEnd.location <= jsonStart.location) {
        return nil;
    }

    NSString *payload = [body substringWithRange:NSMakeRange(jsonStart.location, jsonEnd.location - jsonStart.location + 1)];
    return [JTool dictionaryWithJsonString:payload];
}

/// 只接受字段完整且与请求代码一致的估值，避免把错误页或残缺数据当成 0 展示。
static FundModel *FundEstimateModel(id responseObject, NSString *code) {
    NSDictionary *dic = FundDictionaryFromJSONPResponse(responseObject);
    NSString *fundCode = [dic[@"fundcode"] isKindOfClass:[NSString class]] ? dic[@"fundcode"] : nil;
    NSString *estimate = dic[@"gsz"] == [NSNull null] ? nil : [NSString stringWithFormat:@"%@", dic[@"gsz"] ?: @""];
    NSString *rate = dic[@"gszzl"] == [NSNull null] ? nil : [NSString stringWithFormat:@"%@", dic[@"gszzl"] ?: @""];
    NSString *time = [dic[@"gztime"] isKindOfClass:[NSString class]] ? dic[@"gztime"] : nil;
    if (![fundCode isEqualToString:code] || estimate.doubleValue <= 0 || rate.length < 1 || time.length < 1) {
        return nil;
    }
    return [[FundModel alloc] initWithDic:dic];
}

static NSString *FundStringFromHTTPResponse(id responseObject) {
    if ([responseObject isKindOfClass:[NSData class]]) {
        return [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    }
    return [responseObject isKindOfClass:[NSString class]] ? responseObject : nil;
}

static NSString *FundStripHTML(NSString *value) {
    NSRegularExpression *tags = [NSRegularExpression regularExpressionWithPattern:@"<[^>]*>" options:0 error:nil];
    NSString *text = [tags stringByReplacingMatchesInString:value options:0 range:NSMakeRange(0, value.length) withTemplate:@""];
    return [[text stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

static NSString *FundNormalizeDate(NSString *date, NSString *updateTime) {
    NSRegularExpression *monthDay = [NSRegularExpression regularExpressionWithPattern:@"^\\d{2}-\\d{2}$" options:0 error:nil];
    BOOL isMonthDay = [monthDay firstMatchInString:date options:0 range:NSMakeRange(0, date.length)] != nil;
    if (isMonthDay && updateTime.length >= 4) {
        return [NSString stringWithFormat:@"%@-%@", [updateTime substringToIndex:4], date];
    }
    return date;
}

@implementation NetTool

+ (void)getFundEstimateFromURL:(NSString *)url code:(NSString *)code complete:(void(^)(id resp))resp fail:(void(^)(void))failBlock {
    NSDictionary *parameters = @{@"cb": @"jsonp", @"fc": code, @"t": @"basewap"};
    [[NetClient shareHttpInstance] GET:url parameters:parameters headers:FundEstimateHeaders() progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        FundModel *model = FundEstimateModel(responseObject, code);
        model ? resp(model) : failBlock();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"fund estimate request failed for %@ (%@): %@", code, url, error.localizedDescription);
        failBlock();
    }];
}

+ (void)getFundEstimateFromHaoETF:(NSString *)code complete:(void(^)(id resp))resp fail:(void(^)(void))failBlock {
    NSString *url = [ttFundQDIIBackupURL stringByAppendingString:code];
    [[NetClient shareHttpInstance] GET:url parameters:nil headers:FundEstimateHeaders() progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *body = FundStringFromHTTPResponse(responseObject);
        if (body.length < 1 || [[body stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:[NSString stringWithFormat:@"%@ not found", code]]) {
            failBlock();
            return;
        }

        NSString *escapedCode = [NSRegularExpression escapedPatternForString:code];
        NSString *rowPattern = [NSString stringWithFormat:@"<tr[^>]*>\\s*<td[^>]*>\\s*%@\\s*</td>.*?</tr>", escapedCode];
        NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators;
        NSRegularExpression *rowRegex = [NSRegularExpression regularExpressionWithPattern:rowPattern options:regexOptions error:nil];
        NSTextCheckingResult *rowMatch = [rowRegex firstMatchInString:body options:0 range:NSMakeRange(0, body.length)];
        NSRegularExpression *timeRegex = [NSRegularExpression regularExpressionWithPattern:@"数据更新时间：\\s*([^<]+)" options:regexOptions error:nil];
        NSTextCheckingResult *timeMatch = [timeRegex firstMatchInString:body options:0 range:NSMakeRange(0, body.length)];
        if (!rowMatch || !timeMatch || timeMatch.numberOfRanges < 2) {
            failBlock();
            return;
        }

        NSString *rowHTML = [body substringWithRange:rowMatch.range];
        NSRegularExpression *comments = [NSRegularExpression regularExpressionWithPattern:@"<!--.*?-->" options:NSRegularExpressionDotMatchesLineSeparators error:nil];
        rowHTML = [comments stringByReplacingMatchesInString:rowHTML options:0 range:NSMakeRange(0, rowHTML.length) withTemplate:@""];
        NSRegularExpression *cellRegex = [NSRegularExpression regularExpressionWithPattern:@"<td[^>]*>(.*?)</td>" options:regexOptions error:nil];
        NSArray<NSTextCheckingResult *> *matches = [cellRegex matchesInString:rowHTML options:0 range:NSMakeRange(0, rowHTML.length)];
        NSMutableArray<NSString *> *cells = [NSMutableArray arrayWithCapacity:matches.count];
        for (NSTextCheckingResult *match in matches) {
            if (match.numberOfRanges > 1) {
                [cells addObject:FundStripHTML([rowHTML substringWithRange:[match rangeAtIndex:1]])];
            }
        }
        if (cells.count < 14 || ![cells[0] isEqualToString:code] || [cells[1] length] < 1) {
            failBlock();
            return;
        }

        double estimatedValue = [cells[2] doubleValue];
        double netAssetValue = [cells[12] doubleValue];
        if (estimatedValue <= 0 || netAssetValue <= 0) {
            failBlock();
            return;
        }

        NSString *updateTime = [[body substringWithRange:[timeMatch rangeAtIndex:1]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *estimatedRate = [NSString stringWithFormat:@"%.2f", (estimatedValue / netAssetValue - 1) * 100];
        NSDictionary *dic = @{
            @"fundcode": cells[0], @"name": cells[1], @"gsz": cells[2],
            @"dwjz": cells[12], @"jzrq": FundNormalizeDate(cells[13], updateTime),
            @"gszzl": estimatedRate, @"gztime": updateTime
        };
        resp([[FundModel alloc] initWithDic:dic]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"HaoETF estimate request failed for %@: %@", code, error.localizedDescription);
        failBlock();
    }];
}

+ (void)getFundBaseInfo:(NSString *)code complete:(void(^)(id resp))resp fail:(void(^)(id resp))failBlock {
    NSDictionary *parameters = @{
        @"FCODE": code,
        @"deviceid": [NSUUID UUID].UUIDString,
        @"plat": @"Iphone",
        @"product": @"EFund",
        @"version": @"6.4.7"
    };
    [[NetClient shareJsonInstance] GET:ttFundBaseURL parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [responseObject isKindOfClass:[NSDictionary class]] ? responseObject[@"Datas"] : nil;
        NSString *fundCode = [dic[@"FCODE"] isKindOfClass:[NSString class]] ? dic[@"FCODE"] : nil;

        if ([dic isKindOfClass:[NSDictionary class]] && [fundCode isEqualToString:code]) {
            FundModel *fm = [[FundModel alloc] initWithBaseInfoDic:dic];
            resp(fm);
        } else {
            NSLog(@"getFundInfo invalid response for %@: %@", code, responseObject);
            failBlock(code);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"getFundInfo error for %@: %@", code, error.localizedDescription);
        failBlock(code);
    }];
}

+ (void)getFundInfo:(NSString *)code complete:(void(^)(id resp))resp fail:(void(^)(id resp))failBlock {
    NSObject *completionLock = [[NSObject alloc] init];
    __block BOOL completed = NO;

    // 所有数据源共享一个 5 秒总时限，并保证成功、失败只回调一次。
    BOOL (^isCompleted)(void) = ^BOOL{
        @synchronized (completionLock) {
            return completed;
        }
    };
    void (^completeOnce)(id) = ^(id model) {
        @synchronized (completionLock) {
            if (completed) return;
            completed = YES;
        }
        resp(model);
    };
    void (^failOnce)(void) = ^{
        @synchronized (completionLock) {
            if (completed) return;
            completed = YES;
        }
        failBlock(code);
    };

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kFundRequestTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        failOnce();
    });

    [self getFundEstimateFromURL:ttFundEstimatePrimaryURL code:code complete:completeOnce fail:^{
        if (isCompleted()) return;
        [self getFundEstimateFromURL:ttFundEstimateBackupURL code:code complete:completeOnce fail:^{
            if (isCompleted()) return;
            [self getFundEstimateFromHaoETF:code complete:completeOnce fail:^{
                if (isCompleted()) return;
                [self getFundBaseInfo:code complete:completeOnce fail:^(id resp) {
                    failOnce();
                }];
            }];
        }];
    }];
}

+ (void)getFundLastJZ:(NSString *)code resp:(void(^)(id resp,NSString *errMsg))resp {
    NSDictionary *parameters = @{
        @"FCODE": code,
        @"deviceid": [NSUUID UUID].UUIDString,
        @"plat": @"Iphone",
        @"product": @"EFund",
        @"version": @"6.4.7"
    };
    [[NetClient shareJsonInstance] GET:ttFundBaseURL parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [responseObject isKindOfClass:[NSDictionary class]] ? responseObject[@"Datas"] : nil;
        NSString *fundCode = [dic[@"FCODE"] isKindOfClass:[NSString class]] ? dic[@"FCODE"] : nil;
        NSString *dailyChange = dic[@"RZDF"] == [NSNull null] ? nil : [NSString stringWithFormat:@"%@", dic[@"RZDF"] ?: @""];
        NSString *valueDate = [dic[@"FSRQ"] isKindOfClass:[NSString class]] ? dic[@"FSRQ"] : nil;

        // 使用最新正式净值日涨幅更新持有金额，不再解析已经失效的 HTML 页面。
        if ([fundCode isEqualToString:code] && [JTool isPureFloat:dailyChange] && valueDate.length > 0) {
            resp(dailyChange,nil);
        } else {
            resp(nil,@"未获取到最新正式净值涨幅");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"getFundLastJZ error: %@",error.localizedDescription);
        resp(nil, error.localizedDescription);
    }];
}

+ (void)getIndexInfoFromTencent:(void(^)(id resp,NSString *errMsg))resp {
    NSDictionary *headers = @{
        @"Referer": @"https://gu.qq.com/",
        @"User-Agent": @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    };
    [[NetClient shareHttpInstance] GET:@"https://qt.gtimg.cn/q=s_sh000001,s_sh000300,s_sz399006" parameters:nil headers:headers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSStringEncoding gb18030 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *body = [responseObject isKindOfClass:[NSData class]] ? [[NSString alloc] initWithData:responseObject encoding:gb18030] : nil;
        NSMutableArray<FundModel *> *models = [NSMutableArray array];

        for (NSString *line in [body componentsSeparatedByString:@";"]) {
            NSRange firstQuote = [line rangeOfString:@"\""];
            NSRange lastQuote = [line rangeOfString:@"\"" options:NSBackwardsSearch];
            if (firstQuote.location == NSNotFound || lastQuote.location <= firstQuote.location) continue;

            NSString *payload = [line substringWithRange:NSMakeRange(firstQuote.location + 1, lastQuote.location - firstQuote.location - 1)];
            NSArray<NSString *> *fields = [payload componentsSeparatedByString:@"~"];
            if (fields.count < 6 || [fields[3] doubleValue] <= 0 || [fields[4] length] < 1 || [fields[5] length] < 1) continue;

            FundModel *model = [[FundModel alloc] initWithDic:@{
                @"name": fields[1], @"f2": fields[3], @"f4": fields[4], @"f3": fields[5]
            }];
            [models addObject:model];
        }

        if (models.count == 3) {
            resp(models,nil);
        } else {
            resp(@[],@"备用指数数据格式错误");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"getIndexInfo backup error: %@", error.localizedDescription);
        resp(@[],error.localizedDescription);
    }];
}

+ (void)getIndexInfoWithRetryCount:(NSUInteger)retryCount resp:(void(^)(id resp,NSString *errMsg))resp {
    [[NetClient shareJsonInstance] GET:@"https://push2.eastmoney.com/api/qt/ulist.np/get?fltt=2&fields=f2,f3,f4,f12,f14&secids=1.000001,1.000300,0.399006" parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *diffA = responseObject[@"data"][@"diff"];
        if([JTool isEmptyArray:diffA]){
            resp(@[],nil);
        } else {
            NSMutableArray *diffM = [NSMutableArray array];
            [diffA enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FundModel *fm = [[FundModel alloc]initWithDic:obj];
                [diffM addObject:fm];
            }];
            resp(diffM,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"getIndexInfo error: %@",error.localizedDescription);
        if (retryCount > 0) {
            // 指数接口偶发断线时自动重试一次，避免瞬时网络抖动直接报错。
            [self getIndexInfoWithRetryCount:retryCount - 1 resp:resp];
        } else {
            // 主接口重试后仍失败，改用腾讯行情，避免同一域名持续断线。
            [self getIndexInfoFromTencent:resp];
        }
    }];
}

+ (void)getIndexInfo:(void(^)(id resp,NSString *errMsg))resp {
    [self getIndexInfoWithRetryCount:1 resp:resp];
}

+ (void)getFundRank:(void(^)(id resp,NSString *errMsg))resp {
    [[NetClient shareJsonInstance] GET:[NSString stringWithFormat:@"https://fundmobapi.eastmoney.com/FundMNewApi/FundMNRank?FundType=0&SortColumn=SYL_Y&Sort=desc&pageIndex=1&pageSize=30&BUY=true&CompanyId=&LevelOne=&LevelTwo=&ISABNORMAL=true&DISCOUNT=&RISKLEVEL=&ENDNAV=&RLEVEL_SZ=&ESTABDATE=&TOPICAL=&CLTYPE=&DataConstraintType=0&GTOKEN=&product=EFund&passportutoken=&deviceid=%@&plat=Iphone&passportctoken=&version=6.4.7",[NSUUID UUID].UUIDString] parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableArray *rankM = [NSMutableArray array];
        NSArray *datas = responseObject[@"Datas"];
        if([JTool isEmptyArray:datas]){
            resp(@[],nil);
        } else {
            [datas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FundModel *fm = [[FundModel alloc]initWithRankDic:obj];
                [rankM addObject:fm];
            }];
            resp(rankM,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"getFundRank error: %@",error.localizedDescription);
        resp(@[],error.localizedDescription);
    }];
}

@end
