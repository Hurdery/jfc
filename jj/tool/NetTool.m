//
//  NetTool.m
//  jj
//
//  Created by LY_MD on 2020/7/17.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import "NetTool.h"
#import "AFNetworking.h"
#import "FundModel.h"
#import "AlertTool.h"
/// 数据来源天天基金
#define tturl @"http://fundgz.1234567.com.cn/js/"

@implementation NetTool
+ (void)getFundInfo:(NSString *)code complete:(void(^)(id resp))resp {
      AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
      mgr.requestSerializer = [AFHTTPRequestSerializer serializer];
      mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
      mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/x-javascript",nil];
      [mgr GET:[NSString stringWithFormat:@"%@%@.js",tturl,code] parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          
           NSString *string = [[[[[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"(" withString:@""]stringByReplacingOccurrencesOfString:@")" withString:@""]stringByReplacingOccurrencesOfString:@"jsonpgz" withString:@""]stringByReplacingOccurrencesOfString:@";" withString:@""];
          NSDictionary *dic = [self dictionaryWithJsonString:string];
          
          if (dic) {
             FundModel *fm = [[FundModel alloc]initWithDic:dic];
             resp(fm);
          }
//          NSLog(@"responseObject===%@",string);
      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          NSLog(@"NSError===%@",error);
          [AlertTool showAlert:@"哎呀呀，搜寻基码出错了" actionTitle1:@"换个基码" actionTitle2:@"" window:[NSApplication sharedApplication].keyWindow action:nil];
      }];
    
}

+ (void)getIndexInfo:(void(^)(id resp))resp {
    
          AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
          mgr.requestSerializer = [AFHTTPRequestSerializer serializer];
          mgr.responseSerializer = [AFJSONResponseSerializer serializer];
          mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",nil];
          [mgr GET:@"https://push2.eastmoney.com/api/qt/ulist.np/get?fltt=2&fields=f2,f3,f4,f12,f14&secids=1.000001,1.000300,0.399001" parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              
//              NSLog(@"responseObject===%@",responseObject);
              
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

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end
