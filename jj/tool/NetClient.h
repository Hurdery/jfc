//
//  NetClient.h
//  jj
//
//  Created by LY_MD on 2020/7/17.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetClient : AFHTTPSessionManager
+ (instancetype)shareHttpInstance;
+ (instancetype)shareJsonInstance;
@end

NS_ASSUME_NONNULL_END
