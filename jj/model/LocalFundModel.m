//
//  LocalFundModel.m
//  jj
//
//  Created by LY_MD on 2020/7/17.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import "LocalFundModel.h"

@implementation LocalFundModel

- (instancetype)initWithArray:(NSArray *)array {
    self = [super init];
    if (self && array.count >= 5) {
        self.code = array[0];
        self.abbreviation = array[1];
        self.name = array[2];
        self.type = array[3];
        self.pinyin = array[4];
    }
    return self;
}

@end
