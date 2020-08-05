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

typedef enum : NSUInteger {
    RecommedType, // 自选 + 推荐的数据
    OtherType, // 自定义，如自己持仓部分
} SourceType;

/// <#Description#>
@interface DataManager : NSObject

/// 模型数据
@property(nonatomic,strong)NSMutableArray <FundModel *>*modelsAry;

/// 获取实例
+ (instancetype)manger;

/// 加载数据
/// @param resp <#resp description#>
- (void)loadData:(SourceType)st resp:(void(^)(id resp))resp;

/// 添加数据
/// @param codeStr <#codeStr description#>
/// @param result <#result description#>
- (void)addData:(NSString *)codeStr source:(SourceType)st resp:(void(^)(id result,AlertType at))result;

/// 删除数据
/// @param resp <#resp description#>
- (void)deleteData:(NSInteger)row source:(SourceType)st resp:(void(^)(id resp))resp;

/// 清楚数据
- (void)clearData;

/// 重置数据
- (void)resetDefaultData:(SourceType)st resp:(void(^)(id resp))resp;


/// 拖拽后，重排数据
/// @param st <#st description#>
/// @param modelsAry <#modelsAry description#>
- (void)dragReset:(SourceType)st modelsAry:(NSArray *)modelsAry;
@end

