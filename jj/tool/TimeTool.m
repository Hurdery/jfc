//
//  TimeTool.m
//  jj
//
//  Created by LY_MD on 2020/8/18.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import "TimeTool.h"

@implementation TimeTool

+ (NSString*)getCurrentymdhms{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    return currentTimeString;
}

+ (NSString*)getCurrentymd{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    return currentTimeString;
}

+ (NSString *)getLastday {
    NSTimeInterval secondsPerDay1 = 24*60*60;
    NSDate *now = [NSDate date];
    NSDate *yesterDay = [now dateByAddingTimeInterval:-secondsPerDay1];
    NSDateFormatter * formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *yd=[formatter stringFromDate:yesterDay];
    return yd;
}

+ (NSString *)getbeforebeforeyesterday {
    NSTimeInterval secondsPerDay1 = 72*60*60;
    NSDate *now = [NSDate date];
    NSDate *yesterDay = [now dateByAddingTimeInterval:-secondsPerDay1];
    NSDateFormatter * formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *yd=[formatter stringFromDate:yesterDay];
    return yd;
}

+ (NSString*)weekdayString {
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"周末", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [calendar setTimeZone: timeZone];
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:[NSDate date]];
    return [weekdays objectAtIndex:theComponents.weekday];
}

@end
