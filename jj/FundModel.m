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
        self.zoneType = 1;
        
        self.f2 = [NSString stringWithFormat:@"%@",dic[@"f2"]];
        CGFloat ff3 = [[NSString stringWithFormat:@"%@",dic[@"f3"]] floatValue];
        CGFloat ff4 = [[NSString stringWithFormat:@"%@",dic[@"f4"]] floatValue];

        self.f3 = [[NSString stringWithFormat:@"%.2f",ff3]stringByAppendingString:@"%"];
        self.f4 = [NSString stringWithFormat:@"%.2f",ff4];
        CGFloat gz = [dic[@"gszzl"] floatValue];
        self.gszzl = [[NSString stringWithFormat:@"%.2f",gz]stringByAppendingString:@"%"];
    }
    
    return self;
}

- (instancetype)initWithRankDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.name = dic[@"SHORTNAME"];
        self.ENDNAV = dic[@"ENDNAV"];
        self.RZDF = dic[@"RZDF"];
        self.SYL_Y = dic[@"SYL_Y"];
        self.SYL_1N = dic[@"SYL_1N"];
        self.FSRQ = dic[@"FSRQ"];
        self.fundcode = dic[@"FCODE"];
        self.zoneType = 2;
    }
    return self;
}
@end
