//
//  DataManager.m
//  jj
//
//  Created by LY_MD on 2020/7/22.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import "DataManager.h"
#define jjKey @"jjkey"

@implementation DataManager

+ (instancetype)manger {
    
    static DataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DataManager alloc]init];
    });
    return manager;
    
}

- (void)loadData:(void(^)(id resp))resp {
    
      NSArray *jja = [[NSUserDefaults standardUserDefaults]objectForKey:jjKey];
      if (jja.count < 1) {
          [self resetDefaultData:^(id resp) {
              
          }];
       }
       self.modelsAry =  [NSMutableArray array];
       NSMutableArray *tempA = [NSMutableArray array];
       NSMutableArray *tempB = [NSMutableArray array];
       dispatch_group_t group = dispatch_group_create();
       dispatch_queue_t jjqueue = dispatch_get_global_queue(0, 0);

    [jja enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           
           dispatch_group_enter(group);
           dispatch_group_async(group, jjqueue, ^{
                   [NetTool getFundInfo:obj complete:^(id  _Nonnull resp) {
                     [tempA addObject:resp];
                     dispatch_group_leave(group);
                   }];
           });
           
       }];
           
       dispatch_group_notify(group, dispatch_get_main_queue(), ^{

           // 请求完成后排序
           [tempA enumerateObjectsUsingBlock:^(FundModel * _Nonnull jjModel, NSUInteger idx, BOOL * _Nonnull stop) {
               
               [jja enumerateObjectsUsingBlock:^(id  _Nonnull code, NSUInteger idx, BOOL * _Nonnull stop) {
                   if ([code isEqualToString:jjModel.fundcode]) {
                       jjModel.sort = idx;
                       [tempB addObject:jjModel];
                   }
               }];
           
           }];
           [self.modelsAry addObjectsFromArray:[self sortHomeModelArray:tempB]];
                 
           if (resp) {
               resp(self.modelsAry);
           }
           
      });
    
    
}
- (void)addData:(NSString *)codeStr resp:(void(^)(id result,AlertType at))result{
    
      NSArray *jja = [[NSUserDefaults standardUserDefaults]objectForKey:jjKey];
       
       if (codeStr.length < 1) {
           result(nil,AlertEmpty);
           return;
        }
       
       if ([jja containsObject:codeStr]) {
           result(nil,AlertRepeat);
           return;
       }
      
       NSMutableArray *tempA = [NSMutableArray arrayWithArray:jja];
       
       [NetTool getFundInfo:codeStr complete:^(id  _Nonnull resp) {
          
           if (![resp isKindOfClass:[NSError class]]) {
               
               [self.modelsAry addObject:resp];
               [tempA insertObject:codeStr atIndex:0];
               [[NSUserDefaults standardUserDefaults]setObject:[NSArray arrayWithArray:tempA] forKey:jjKey];
              
               if (result) {
                   result(self.modelsAry,-100);
               }
               
           }else {
               result(nil,AlertNull);
           }
           
       }];
    
    
    
}
- (void)deleteData:(NSInteger)row resp:(void(^)(id resp))resp {
    
    NSArray *jja = [[NSUserDefaults standardUserDefaults]objectForKey:jjKey];
    NSMutableArray *mjja = [NSMutableArray arrayWithArray:jja];
    [mjja removeObjectAtIndex:row];
    [[NSUserDefaults standardUserDefaults]setObject:[NSArray arrayWithArray:mjja] forKey:jjKey];
    resp(@"delete");
    
}
- (void)clearData{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:jjKey];
}
/// 默认天天基金榜十
/// @param resp <#resp description#>
- (void)resetDefaultData:(void(^)(id resp))resp{
    
       NSArray *jjA = @[@"004997",@"001475",@"006266",@"004698",@"006269",@"001838",@"005609",@"004069",@"004070",@"002251"];
       [[NSUserDefaults standardUserDefaults]setObject:jjA forKey:jjKey];
    
     resp(@"reset");
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
@end
