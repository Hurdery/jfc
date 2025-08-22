//
//  FundModel.h
//  jj
//
//  Created by LY_MD on 2020/7/17.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FundModel : NSObject

/// 基码
@property(nonatomic,copy)NSString *fundcode;
/// 基幅
@property(nonatomic,copy)NSString *gszzl;
/// 基止
@property(nonatomic,copy)NSString *gztime;
/// 基刷
@property(nonatomic,copy)NSString *refreshtime;
/// 基时
@property(nonatomic,copy)NSString *jzrq;
/// 基净
@property(nonatomic,copy)NSString *dwjz;
/// 基估
@property(nonatomic,copy)NSString *gsz;
/// 基名
@property(nonatomic,copy)NSString *name;
/// 基序
@property(nonatomic,assign)NSInteger sort;
/// 基持
@property(nonatomic,copy)NSString *jc;
/// 规模
@property(nonatomic,copy)NSString *ENDNAV;
/// 周涨幅
@property(nonatomic,copy)NSString *SYL_Z;
/// 月涨幅
@property(nonatomic,copy)NSString *SYL_Y;
/// 年涨幅
@property(nonatomic,copy)NSString *SYL_1N;
/// 日涨幅
@property(nonatomic,copy)NSString *RZDF;
/// 上日
@property(nonatomic,copy)NSString *FSRQ;
/// 区类型  2====>榜单
@property(nonatomic,assign)NSInteger zoneType;

/// 指数
@property(nonatomic,copy)NSString *f2;
@property(nonatomic,copy)NSString *f3;
@property(nonatomic,copy)NSString *f4;

- (instancetype)initWithDic:(NSDictionary *)dic;

/// 榜单区
/// @param dic <#dic description#>
- (instancetype)initWithRankDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
