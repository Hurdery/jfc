//
//  DataManager.m
//  jj
//
//  Created by LY_MD on 2020/7/22.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import "DataManager.h"
#define jjKey @"jjkey"
#define jjMyKey @"jjMyKey"
#define jcKey @"jcKey"

@implementation DataManager

+ (instancetype)manger {
    
    static DataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DataManager alloc]init];
    });
    return manager;
    
}

- (void)loadData:(SourceType)st resp:(void(^)(id resp))resp {
//       NSLog(@"发起请求");

       NSArray *sourceA;
       if (st == RecommedType) {
           sourceA = [[NSUserDefaults standardUserDefaults]objectForKey:jjKey];
              
              if (sourceA.count < 1) {
               NSArray *jjA = @[@"004997",@"001475",@"006266",@"004698",@"006269",@"001838",@"005609",@"004069",@"004070",@"002251"];
               [[NSUserDefaults standardUserDefaults]setObject:jjA forKey:jjKey];
            }
           
       } else {
           
           // 去重
           NSMutableArray *resultArrM = [NSMutableArray array];
           NSArray  *originalArr = [[NSUserDefaults standardUserDefaults]objectForKey:jjMyKey];

              for (NSString *item in originalArr) {
                  if (![resultArrM containsObject:item]) {
                    [resultArrM addObject:item];
                  }
              }
           
           sourceA = [NSArray arrayWithArray:resultArrM];
       }
    
       self.modelsAry =  [NSMutableArray array];
       NSMutableArray *tempA = [NSMutableArray array];
       NSMutableArray *tempB = [NSMutableArray array];
       dispatch_group_t group = dispatch_group_create();
       dispatch_queue_t jjqueue = dispatch_get_global_queue(0, 0);

    [sourceA enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           
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
               
               [sourceA enumerateObjectsUsingBlock:^(id  _Nonnull code, NSUInteger idx, BOOL * _Nonnull stop) {
                   if ([code isEqualToString:jjModel.fundcode]) {
                       jjModel.sort = idx;
                       [tempB addObject:jjModel];
                   }
               }];
           
           }];
           [self.modelsAry addObjectsFromArray:[self sortHomeModelArray:tempB]];
//           NSLog(@"请求完成");
           if (resp) {
               resp(self.modelsAry);
           }
           
      });
    
    
}
- (void)addData:(NSString *)codeStr source:(SourceType)st resp:(void(^)(id result,AlertType at))result {
    
    NSArray *sourceA;
    if (st == RecommedType) {
        sourceA = [[NSUserDefaults standardUserDefaults]objectForKey:jjKey];
    } else {
        sourceA = [[NSUserDefaults standardUserDefaults]objectForKey:jjMyKey];
    }

       if (codeStr.length < 1) {
           result(nil,AlertEmpty);
           return;
        }
       
       if ([sourceA containsObject:codeStr]) {
           result(nil,AlertRepeat);
           return;
       }
    
      
       NSMutableArray *tempA = [NSMutableArray arrayWithArray:sourceA];

       [NetTool getFundInfo:codeStr complete:^(id  _Nonnull resp) {
           
           if (![resp isKindOfClass:[NSError class]]) {
               
               [self.modelsAry addObject:resp];
               [tempA insertObject:codeStr atIndex:0];
               if (st == RecommedType) {
                     [[NSUserDefaults standardUserDefaults]setObject:[NSArray arrayWithArray:tempA] forKey:jjKey];
                 } else {
                     [[NSUserDefaults standardUserDefaults]setObject:[NSArray arrayWithArray:tempA] forKey:jjMyKey];
                 }

               if (result) {
                   result(self.modelsAry,-100);
               }
               
           }else {
               result(nil,AlertNull);
           }
           
       }];
        
}
- (void)deleteData:(NSInteger)row source:(SourceType)st resp:(void(^)(id resp))resp {
    
    NSArray *sourceA;
       if (st == RecommedType) {
           sourceA = [[NSUserDefaults standardUserDefaults]objectForKey:jjKey];
       } else {
           sourceA = [[NSUserDefaults standardUserDefaults]objectForKey:jjMyKey];
       }
    
    NSMutableArray *mjja = [NSMutableArray arrayWithArray:sourceA];
    [mjja removeObjectAtIndex:row];
    if (st == RecommedType) {
              [[NSUserDefaults standardUserDefaults]setObject:[NSArray arrayWithArray:mjja] forKey:jjKey];
          } else {
              [[NSUserDefaults standardUserDefaults]setObject:[NSArray arrayWithArray:mjja] forKey:jjMyKey];
          }
    resp(@"delete");
    
}
- (NSString *)getCode:(NSInteger)row source:(SourceType)st{
    
          NSArray *sourceA;
          if (st == RecommedType) {
              sourceA = [[NSUserDefaults standardUserDefaults]objectForKey:jjKey];
          } else {
              sourceA = [[NSUserDefaults standardUserDefaults]objectForKey:jjMyKey];
          }
    
         return [sourceA objectAtIndex:row];
    
}
- (void)clearData{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:jjKey];

}
/// 默认天天基金榜十
/// @param resp <#resp description#>
- (void)resetDefaultData:(SourceType)st resp:(void(^)(id resp))resp {
    
    if (st == RecommedType) {
      NSArray *jjA = @[@"004997",@"001475",@"006266",@"004698",@"006269",@"001838",@"005609",@"004069",@"004070",@"002251"];
    [[NSUserDefaults standardUserDefaults]setObject:jjA forKey:jjKey];
          
           resp(@"reset");
    } else {
         [[NSUserDefaults standardUserDefaults]removeObjectForKey:jjMyKey];

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

    [modelsAry enumerateObjectsUsingBlock:^(FundModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [tempAry addObject:obj.fundcode];

    }];
    
    if (st == RecommedType) {
        [[NSUserDefaults standardUserDefaults]setObject:[NSArray arrayWithArray:tempAry] forKey:jjKey];
    } else {
        [[NSUserDefaults standardUserDefaults]setObject:[NSArray arrayWithArray:tempAry] forKey:jjMyKey];
    }
    
}
- (void)saveInvestedMoney:(NSMutableDictionary *)mdic {
    [[NSUserDefaults standardUserDefaults]setObject:[NSDictionary dictionaryWithDictionary:mdic] forKey:jcKey];
}
- (NSDictionary *)getInvestedMoney {
    return  [[NSUserDefaults standardUserDefaults]objectForKey:jcKey];
}

@end
