//
//  FundModel.m
//  jj
//
//  Created by LY_MD on 2020/7/17.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import "FundModel.h"

@implementation FundModel

- (instancetype)initWithDic:(NSDictionary *)dic{
    
    if (self = [super init]) {

        self.name = dic[@"name"];
        self.gztime = dic[@"gztime"];
        self.fundcode = dic[@"fundcode"];
        CGFloat gz = [dic[@"gszzl"] floatValue];
        self.gszzl = [[NSString stringWithFormat:@"%.2f",gz]stringByAppendingString:@"%"];

    }
    
    return self;
}
@end
