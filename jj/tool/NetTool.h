//
//  NetTool.h
//  jj
//
//  Created by LY_MD on 2020/7/17.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FundModel.h"
#import "TimeTool.h"
#import "JTool.h"
#import "AFNetworking.h"
#import "NetClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetTool : NSObject


/// 加载基金信息
/// @param code <#code description#>
/// @param resp <#resp description#>
/// @param failBlock <#failBlock description#>
+ (void)getFundInfo:(NSString *)code complete:(void(^)(id resp))resp fail:(void(^)(id resp))failBlock ;


/// 加载指数信息
/// @param resp <#resp description#>
+ (void)getIndexInfo:(void(^)(id resp))resp;

/// 获取上天净值
/// @param code <#code description#>
+ (void)getFundLastJZ:(NSString *)code resp:(void(^)(id resp))resp;

+ (void)getFundRank:(void(^)(id resp))resp;

@end

NS_ASSUME_NONNULL_END
