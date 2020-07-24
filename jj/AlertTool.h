//
//  AlertTool.h
//  jj
//
//  Created by LY_MD on 2020/7/22.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSUInteger, AlertResponse) {
    FirstResp = 0,
    SecondResp = 1,
    ThirdResp = 2
};

@interface AlertTool : NSObject
+(void)showAlert:(NSString *)msg  actionTitle1:(NSString *)actionTitle1 actionTitle2:(NSString *)actionTitle2 window:(NSWindow *)window action:(void(^)(AlertResponse resp))action;
@end

