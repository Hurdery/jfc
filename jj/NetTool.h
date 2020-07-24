//
//  NetTool.h
//  jj
//
//  Created by LY_MD on 2020/7/17.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FundModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetTool : NSObject
+ (void)getFundInfo:(NSString *)code complete:(void(^)(id resp))resp;
@end

NS_ASSUME_NONNULL_END
