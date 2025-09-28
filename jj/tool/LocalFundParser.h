//
//  LocalFundParser.h
//  jj
//
//  Created by LY_MD on 2020/7/17.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalFundModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LocalFundParser : NSObject

+ (NSArray<LocalFundModel *> *)parseFundsFromJSONFile:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
