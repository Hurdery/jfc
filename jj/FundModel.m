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
        self.gsz = dic[@"gsz"];
        self.dwjz = dic[@"dwjz"];
        self.f2 = [NSString stringWithFormat:@"%@",dic[@"f2"]];
        self.f3 = [[NSString stringWithFormat:@"%@",dic[@"f3"]]stringByAppendingString:@"%"];
        self.f4 = [NSString stringWithFormat:@"%@",dic[@"f4"]];
        CGFloat gz = [dic[@"gszzl"] floatValue];
        self.gszzl = [[NSString stringWithFormat:@"%.2f",gz]stringByAppendingString:@"%"];

    }
    
    return self;
}
@end
