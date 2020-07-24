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
/// 基时
@property(nonatomic,copy)NSString *jzrq;
/// 基名
@property(nonatomic,copy)NSString *name;
/// 基序
@property(nonatomic,assign)NSInteger sort;

- (instancetype)initWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
