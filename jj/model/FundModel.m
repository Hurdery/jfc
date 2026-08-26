//
//  FundModel.m
//  jj
//
//  Created by LY_MD on 2020/7/17.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import "FundModel.h"

@implementation FundModel

/// 将接口中的空值统一转成占位符，避免表格给 stringValue 传入 nil。
static NSString *FundDisplayString(id value) {
    if (!value || value == [NSNull null]) {
        return @"--";
    }
    NSString *string = [NSString stringWithFormat:@"%@", value];
    return string.length > 0 ? string : @"--";
}

- (instancetype)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.name = dic[@"name"];
        self.gztime = dic[@"gztime"];
        self.fundcode = dic[@"fundcode"];
        self.gsz = dic[@"gsz"];
        self.dwjz = dic[@"dwjz"];
        self.zoneType = 1;
        
        self.f2 = [NSString stringWithFormat:@"%@",dic[@"f2"]];
        self.f_f2 = [dic[@"f2"] floatValue];
        CGFloat ff3 = [[NSString stringWithFormat:@"%@",dic[@"f3"]] floatValue];
        CGFloat ff4 = [[NSString stringWithFormat:@"%@",dic[@"f4"]] floatValue];

        self.f3 = [[NSString stringWithFormat:@"%.2f",ff3]stringByAppendingString:@"%"];
        self.f4 = [NSString stringWithFormat:@"%.2f",ff4];
        CGFloat gz = [dic[@"gszzl"] floatValue];
        self.gszzl = [[NSString stringWithFormat:@"%.2f",gz]stringByAppendingString:@"%"];
    }
    
    return self;
}

- (instancetype)initWithBaseInfoDic:(NSDictionary *)dic {
    if (self = [super init]) {
        self.name = FundDisplayString(dic[@"SHORTNAME"]);
        self.fundcode = FundDisplayString(dic[@"FCODE"]);
        self.dwjz = FundDisplayString(dic[@"DWJZ"]);
        self.jzrq = FundDisplayString(dic[@"FSRQ"]);

        // 盘中估值不可用时仅隐藏估值；正式日涨幅和净值日期仍应正常展示。
        self.gsz = @"--";
        NSString *dailyChange = FundDisplayString(dic[@"RZDF"]);
        if ([dailyChange isEqualToString:@"--"]) {
            self.gszzl = dailyChange;
        } else {
            self.gszzl = [[NSString stringWithFormat:@"%.2f", dailyChange.floatValue] stringByAppendingString:@"%"];
        }
        self.gztime = self.jzrq;
        self.zoneType = 1;
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
