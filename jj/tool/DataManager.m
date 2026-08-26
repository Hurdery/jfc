//
//  DataManager.m
//  jj
//
//  Created by LY_MD on 2020/7/22.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import "DataManager.h"
/// 观察区基金
#define jjKey @"jjkey"
/// 持有基金
#define jjMyKey @"jjMyKey"
/// 持仓金额
#define jcKey @"jcKey"
/// 记录大盘的最高值
#define szHighKey @"szRecordHighKey"
/// 记录大盘的最低值
#define szLowKey @"szRecordLowKey"

@interface DataManager ()

/// 标记最近一次加载，避免并发刷新完成顺序不同导致共享数据回退。
@property(nonatomic,assign) NSUInteger loadGeneration;

@end

@implementation DataManager

+ (instancetype)manger {
    static DataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DataManager alloc] init];
        // 启动即清理历史孤立金额，不依赖用户先切换到持有区。
        [manager getInvestedMoney];
    });
    return manager;
}

- (void)loadData:(SourceType)st resp:(void (^)(id resp,NSString *errMsg))resp {
    NSUInteger requestGeneration = ++self.loadGeneration;
    NSArray *sourceA;
    if (st == ObType) {
        sourceA = [[NSUserDefaults standardUserDefaults] objectForKey:jjKey];
        if (sourceA.count < 1) {
            NSArray *jjA = @[@"003834", @"005968", @"006299", @"002190", @"540008", @"090018", @"001644", @"006049", @"161725", @"001951"];
            [[NSUserDefaults standardUserDefaults] setObject:jjA forKey:jjKey];

            sourceA = jjA;
        } else {
            NSMutableArray *resultArrM = [NSMutableArray array];
            NSArray *originalArr = sourceA;

            for (NSString *item in originalArr) {
                if (![resultArrM containsObject:item]) {
                    [resultArrM addObject:item];
                }
            }
            sourceA = [NSArray arrayWithArray:resultArrM];
        }


    } else if (st == OwnType) {
        // 去重
        NSMutableArray *resultArrM = [NSMutableArray array];
        NSArray *originalArr = [[NSUserDefaults standardUserDefaults] objectForKey:jjMyKey];

        for (NSString *item in originalArr) {
            if (![resultArrM containsObject:item]) {
                [resultArrM addObject:item];
            }
        }

        sourceA = [NSArray arrayWithArray:resultArrM];
    } else {
        [NetTool getFundRank:^(id _Nonnull rankA,NSString *errMsg) {
            if (errMsg){
                resp(@[],errMsg);
            } else {
                resp(rankA,nil);
            }
        }];
        return;
    }

    NSMutableArray *tempA = [NSMutableArray array];
    NSMutableArray *tempB = [NSMutableArray array];
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t jjqueue = dispatch_get_global_queue(0, 0);

    [sourceA enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        dispatch_group_enter(group);
        dispatch_group_async(group, jjqueue, ^{
            [NetTool getFundInfo:obj complete:^(id _Nonnull resp) {
                @synchronized (tempA) {
                             [tempA addObject:resp];
                         }
                dispatch_group_leave(group);

            }               fail:^(id _Nonnull resp) {
                // 单只基金失败时仍保留这一行，避免一次失败影响整张列表。
                FundModel *placeholder = [[FundModel alloc] initWithBaseInfoDic:@{@"FCODE": obj}];
                @synchronized (tempA) {
                    [tempA addObject:placeholder];
                }
                dispatch_group_leave(group);
            }];
        });
    }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 请求完成后排序
        [tempA enumerateObjectsUsingBlock:^(FundModel *_Nonnull jjModel, NSUInteger idx, BOOL *_Nonnull stop) {

            [sourceA enumerateObjectsUsingBlock:^(id _Nonnull code, NSUInteger idx, BOOL *_Nonnull stop) {
                if ([code isEqualToString:jjModel.fundcode]) {
                    jjModel.sort = idx;
                    [tempB addObject:jjModel];
                }
            }];

        }];
        // 每一批刷新使用独立结果，不能写入其他并发请求正在使用的数组。
        NSArray *resultModels = [[self sortHomeModelArray:tempB] copy];
        if (requestGeneration == self.loadGeneration) {
            self.modelsAry = [resultModels mutableCopy];

            // 只有最新批次可以写本地列表，防止旧刷新覆盖刚完成的新增或删除。
            if (st == ObType) {
                [[NSUserDefaults standardUserDefaults] setObject:sourceA forKey:jjKey];
            } else if (st == OwnType) {
                [[NSUserDefaults standardUserDefaults] setObject:sourceA forKey:jjMyKey];
            }
        }

        if (resp) {
            resp(resultModels,nil);
        }
    });

}

- (void)addData:(NSString *)codeStr source:(SourceType)st resp:(void (^)(id result, AlertType at))result {
    NSArray *sourceA;
    if (st == ObType) {
        sourceA = [[NSUserDefaults standardUserDefaults] objectForKey:jjKey];
    } else if (st == OwnType) {
        sourceA = [[NSUserDefaults standardUserDefaults] objectForKey:jjMyKey];
    }

    if (codeStr.length < 1) {
        result(nil, AlertEmpty);
        return;
    }

    if ([sourceA containsObject:codeStr]) {
        result(nil, AlertRepeat);
        return;
    }

    NSMutableArray *tempA = [NSMutableArray arrayWithArray:sourceA];

    [NetTool getFundInfo:codeStr complete:^(id _Nonnull resp) {
        if (![resp isKindOfClass:[NSError class]]) {
            [self.modelsAry addObject:resp];
            [tempA insertObject:codeStr atIndex:0];
            if (st == ObType) {
                [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:tempA] forKey:jjKey];
            } else if (st == OwnType) {
                // 新加入持有区的基金从空金额开始，不能继承以前删除后残留的数据。
                NSMutableDictionary *investedMoney = [[self getInvestedMoney] mutableCopy];
                investedMoney = investedMoney ?: [NSMutableDictionary dictionary];
                [investedMoney removeObjectForKey:codeStr];
                [self saveInvestedMoney:investedMoney];
                [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:tempA] forKey:jjMyKey];
            }

            if (result) {
                result(self.modelsAry, -100);
            }

        } else {
            result(nil, AlertNull);
        }
    }
           fail:^(id _Nonnull resp) {
        result(nil, AlertNull);
    }];
}

- (void)deleteData:(NSInteger)row source:(SourceType)st resp:(void (^)(id resp))resp {
    if (st == RankType) return;

    NSArray *sourceA;
    if (st == ObType) {
        sourceA = [[NSUserDefaults standardUserDefaults] objectForKey:jjKey];
    } else if (st == OwnType) {
        sourceA = [[NSUserDefaults standardUserDefaults] objectForKey:jjMyKey];
    }

    if (row < 0 || row >= sourceA.count) {
        return;
    }
    NSString *removedCode = sourceA[row];
    NSMutableArray *mjja = [NSMutableArray arrayWithArray:sourceA];
    [mjja removeObjectAtIndex:row];

    if (st == ObType) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:mjja] forKey:jjKey];
    } else if (st == OwnType) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:mjja] forKey:jjMyKey];
        // 删除持有基金时同步删除金额，避免以后重新添加时出现历史金额。
        NSMutableDictionary *investedMoney = [[self getInvestedMoney] mutableCopy];
        investedMoney = investedMoney ?: [NSMutableDictionary dictionary];
        [investedMoney removeObjectForKey:removedCode];
        [self saveInvestedMoney:investedMoney];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];

    resp(@"delete");
}

- (NSString *)getCode:(NSInteger)row source:(SourceType)st {
    NSArray *sourceA;
    if (st == ObType) {
        sourceA = [[NSUserDefaults standardUserDefaults] objectForKey:jjKey];
    } else if (st == OwnType) {
        sourceA = [[NSUserDefaults standardUserDefaults] objectForKey:jjMyKey];
    }
    return [sourceA objectAtIndex:row];
}

- (void)clearData {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:jjKey];
}

- (void)resetDefaultData:(SourceType)st resp:(void (^)(id resp))resp {
    if (st == ObType) {
        NSArray *jjA = @[@"003834", @"005968", @"006299", @"002190", @"540008", @"090018", @"001644", @"006049", @"161725", @"001951"];
        [[NSUserDefaults standardUserDefaults] setObject:jjA forKey:jjKey];

        resp(@"reset");
    } else if (st == OwnType) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:jjMyKey];

        resp(@"reset");
    }
}

- (NSArray *)sortHomeModelArray:(NSArray *)tempAry {
    NSArray *sortedArray = [tempAry sortedArrayUsingComparator:^NSComparisonResult(FundModel *obj1, FundModel *obj2) {

        if (obj1.sort < obj2.sort) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    return sortedArray;
}

- (void)dragReset:(SourceType)st modelsAry:(NSArray *)modelsAry {
    NSMutableArray *tempAry = [NSMutableArray arrayWithCapacity:modelsAry.count];

    [modelsAry enumerateObjectsUsingBlock:^(FundModel *obj, NSUInteger idx, BOOL *_Nonnull stop) {

        [tempAry addObject:obj.fundcode];

    }];

    if (st == ObType) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:tempAry] forKey:jjKey];
    } else if (st == OwnType) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:tempAry] forKey:jjMyKey];
    }
}

- (void)saveInvestedMoney:(NSMutableDictionary *)mdic {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithDictionary:mdic] forKey:jcKey];
}

- (NSDictionary *)getInvestedMoney {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *savedMoney = [defaults objectForKey:jcKey];
    NSArray<NSString *> *ownedCodes = [defaults objectForKey:jjMyKey];
    NSMutableDictionary *validMoney = [NSMutableDictionary dictionary];

    // 金额只允许属于当前持有区，自动清理已经删除基金留下的孤立数据。
    for (NSString *code in ownedCodes) {
        id amount = savedMoney[code];
        if (amount) {
            validMoney[code] = amount;
        }
    }
    if (![validMoney isEqualToDictionary:savedMoney ?: @{}]) {
        [defaults setObject:validMoney forKey:jcKey];
        [defaults synchronize];
    }
    return [validMoney copy];
}

- (void)updateSZ:(float)value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentTime = [TimeTool getCurrentymdhms];
    float localMax = [defaults floatForKey:szHighKey];
    NSString *maxTimeKey = [szHighKey stringByAppendingString:@"_updateTime"];
    if (value > localMax) {
        [defaults setFloat:value forKey:szHighKey];
        [defaults setObject:currentTime forKey:maxTimeKey];
    }

    float localMin = [defaults floatForKey:szLowKey];
    NSString *minTimeKey = [szLowKey stringByAppendingString:@"_updateTime"];
    if (value < localMin || ![defaults objectForKey:szLowKey]) {
        [defaults setFloat:value forKey:szLowKey];
        [defaults setObject:currentTime forKey:minTimeKey];
    }
}

- (NSString *)getRecordSZHigh {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float szHigh = [defaults floatForKey:szHighKey];
    NSString *time = [[NSUserDefaults standardUserDefaults] objectForKey:[szHighKey stringByAppendingString:@"_updateTime"]];
    return [NSString stringWithFormat:@"High:%f\n%@", szHigh, time];
}

- (NSString *)getRecordSZLow {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float szLow = [defaults floatForKey:szLowKey];
    NSString *time = [[NSUserDefaults standardUserDefaults] objectForKey:[szLowKey stringByAppendingString:@"_updateTime"]];
    return [NSString stringWithFormat:@"Low:%f\n%@", szLow, time];
}

@end
