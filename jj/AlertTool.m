//
//  AlertTool.m
//  jj
//
//  Created by LY_MD on 2020/7/22.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import "AlertTool.h"

@implementation AlertTool

+(void)showAlert:(NSString *)msg  actionTitle1:(NSString *)actionTitle1 actionTitle2:(NSString *)actionTitle2 window:(NSWindow *)window action:(void(^)(AlertResponse resp))action {

         NSAlert * alert = [[NSAlert alloc]init];
         alert.messageText = @"入基有风险，买卖需谨慎";
         [alert addButtonWithTitle:actionTitle1];
         if (actionTitle2.length > 1) {
         [alert addButtonWithTitle:@"取消"];
         }
         [alert setInformativeText:msg];
         [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
             if (returnCode == NSModalResponseOK){
                 NSLog(@"(returnCode == NSOKButton)");
             }else if (returnCode == NSModalResponseCancel){
                 NSLog(@"(returnCode == NSCancelButton)");
             }else if(returnCode == NSAlertFirstButtonReturn){
                 if (action) {action(FirstResp);}
             }else if (returnCode == NSAlertSecondButtonReturn){
                 if (action) {action(SecondResp);}
             }else if (returnCode == NSAlertThirdButtonReturn){
                 if (action) {action(ThirdResp);}
             }else{
                 NSLog(@"All Other return code %ld",(long)returnCode);
             }
         }];
}

@end
