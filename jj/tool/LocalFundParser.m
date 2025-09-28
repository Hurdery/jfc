//
//  LocalFundParser.m
//  jj
//
//  Created by LY_MD on 2020/7/17.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import "LocalFundParser.h"

@implementation LocalFundParser

+ (NSArray<LocalFundModel *> *)parseFundsFromJSONFile:(NSString *)fileName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    if (!filePath) {
        NSLog(@"找不到 %@.json 文件", fileName);
        return @[];
    }
    
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    if (!jsonData) {
        NSLog(@"读取 %@.json 文件失败", fileName);
        return @[];
    }
    
    NSError *error;
    NSArray *outerArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"解析 %@.json 出错: %@", fileName, error.localizedDescription);
        return @[];
    }
    
    NSMutableArray<LocalFundModel *> *fundList = [NSMutableArray array];
    for (NSArray *innerArray in outerArray) {
        LocalFundModel *fund = [[LocalFundModel alloc] initWithArray:innerArray];
        [fundList addObject:fund];
    }
    return [NSArray arrayWithArray:fundList];
}

@end
