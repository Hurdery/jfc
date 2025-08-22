//
//  NetTool.m
//  jj
//
//  Created by LY_MD on 2020/7/17.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import "NetTool.h"
#import "AlertTool.h"
/// 数据来源天天基金
#define tturl @"http://fundgz.1234567.com.cn/js/"
#define ttjzurl @"http://fund.eastmoney.com/f10/F10DataApi.aspx?"

@implementation NetTool

+ (void)getFundInfo:(NSString *)code complete:(void(^)(id resp))resp fail:(void(^)(id resp))failBlock {
      NSString *requestUrl = [NSString stringWithFormat:@"%@%@.js",tturl,code];
      [[NetClient shareHttpInstance] GET:requestUrl parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

           NSString *string = [[[[[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"(" withString:@""]stringByReplacingOccurrencesOfString:@")" withString:@""]stringByReplacingOccurrencesOfString:@"jsonpgz" withString:@""]stringByReplacingOccurrencesOfString:@";" withString:@""];

          NSDictionary *dic = [JTool dictionaryWithJsonString:string];
          
          if (dic) {
             FundModel *fm = [[FundModel alloc]initWithDic:dic];
             resp(fm);
          }else {
              NSLog(@"查询基金：%@ 相关信息为空：",code);
              failBlock(@"error");
          }
      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          NSLog(@"NSError===%@",error);
          [AlertTool showAlert:@"哎呀，搜寻基码出错了" actionTitle1:@"换个基码" actionTitle2:@"" window:[NSApplication sharedApplication].keyWindow action:nil];
      }];
}

+ (void)getFundLastJZ:(NSString *)code resp:(void(^)(id resp))resp {
      NSString *timeStr ;
      NSString *curWeek = [TimeTool weekdayString];
      if ([curWeek isEqualToString:@"周一"]) {
         timeStr = [TimeTool getbeforebeforeyesterday];
      }else{
         timeStr = [TimeTool getLastday];
      }

    /**
      一定时间内好像只能查三十个，气人？！

     */
      [[NetClient shareHttpInstance] GET:[NSString stringWithFormat:@"http://fund.eastmoney.com/f10/F10DataApi.aspx?type=lsjz&code=%@&&sdate=%@",code,timeStr] parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          
           NSString *jzStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                  
            if ([jzStr containsString:@"%"]) {
                
                  NSRange range = [jzStr rangeOfString:@"%"];
                  jzStr = [[jzStr substringWithRange:NSMakeRange(range.location - 5, 5)]stringByReplacingOccurrencesOfString:@">" withString:@""];
                  resp(jzStr);
            }
                
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  NSLog(@"NSError===%@",error);
                  [AlertTool showAlert:@"哎呀呀，获取净值出错了" actionTitle1:@"稍后再试" actionTitle2:@"" window:[NSApplication sharedApplication].keyWindow action:nil];
              }];
}

+ (void)getIndexInfo:(void(^)(id resp))resp {
          [[NetClient shareJsonInstance] GET:@"https://push2.eastmoney.com/api/qt/ulist.np/get?fltt=2&fields=f2,f3,f4,f12,f14&secids=1.000001,1.000300,0.399006" parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

              NSArray *diffA = responseObject[@"data"][@"diff"];
              NSMutableArray *diffM = [NSMutableArray array];
              [diffA enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                  FundModel *fm = [[FundModel alloc]initWithDic:obj];
                  [diffM addObject:fm];
              }];
              resp(diffM);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"NSError===%@",error);
             [AlertTool showAlert:@"哎呀呀，出错了" actionTitle1:@"换个基码" actionTitle2:@"" window:[NSApplication sharedApplication].keyWindow action:nil];
          }];
}

+ (void)getFundRank:(void(^)(id resp))resp {
    [[NetClient shareJsonInstance] GET:[NSString stringWithFormat:@"https://fundmobapi.eastmoney.com/FundMNewApi/FundMNRank?FundType=0&SortColumn=SYL_Y&Sort=desc&pageIndex=1&pageSize=30&BUY=true&CompanyId=&LevelOne=&LevelTwo=&ISABNORMAL=true&DISCOUNT=&RISKLEVEL=&ENDNAV=&RLEVEL_SZ=&ESTABDATE=&TOPICAL=&CLTYPE=&DataConstraintType=0&GTOKEN=&product=EFund&passportutoken=&deviceid=%@&plat=Iphone&passportctoken=&version=6.4.7",[NSUUID UUID].UUIDString] parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        NSMutableArray *rankM = [NSMutableArray array];
        NSArray *Datas = responseObject[@"Datas"];
        [Datas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FundModel *fm = [[FundModel alloc]initWithRankDic:obj];
            [rankM addObject:fm];
        }];
        resp(rankM);
      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"NSError===%@",error);
       [AlertTool showAlert:@"哎呀呀，出错了" actionTitle1:@"换个基码" actionTitle2:@"" window:[NSApplication sharedApplication].keyWindow action:nil];
    }];
}

@end
