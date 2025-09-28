//
//  LocalFundModel.h
//  jj
//
//  Created by LY_MD on 2020/7/17.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocalFundModel : NSObject
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *abbreviation;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *pinyin;

- (instancetype)initWithArray:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END
