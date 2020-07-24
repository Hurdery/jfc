//
//  DataManager.h
//  jj
//
//  Created by LY_MD on 2020/7/22.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetTool.h"

typedef enum : NSUInteger {
    AlertEmpty,
    AlertRepeat,
    AlertNull,
} AlertType;

@interface DataManager : NSObject

/// 模型数据
@property(nonatomic,strong)NSMutableArray <FundModel *>*modelsAry;

/// 获取实例
+ (instancetype)manger;

/// 加载数据
/// @param resp <#resp description#>
- (void)loadData:(void(^)(id resp))resp;

/// 添加数据
/// @param codeStr <#codeStr description#>
/// @param result <#result description#>
- (void)addData:(NSString *)codeStr resp:(void(^)(id result,AlertType at))result;

/// 删除数据
/// @param resp <#resp description#>
- (void)deleteData:(NSInteger)row resp:(void(^)(id resp))resp;

/// 清楚数据
- (void)clearData;

/// 重置数据
- (void)resetDefaultData:(void(^)(id resp))resp;

@end

