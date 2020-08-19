//
//  TimeTool.h
//  jj
//
//  Created by LY_MD on 2020/8/18.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeTool : NSObject

+ (NSString*)getCurrentymdhms;
+ (NSString *)getbeforebeforeyesterday;
+ (NSString *)getLastday;
+ (NSString*)weekdayString;

@end

NS_ASSUME_NONNULL_END
