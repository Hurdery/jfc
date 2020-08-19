//
//  FundJZWC.m
//  jj
//
//  Created by LY_MD on 2020/8/17.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import "FundJZWC.h"
#import <WebKit/WebKit.h>
@interface FundJZWC ()

@property (weak) IBOutlet WKWebView *webV;

@end

@implementation FundJZWC
- (void)windowDidLoad {
    [super windowDidLoad];
    self.window.title = _fundName;
    [self.webV loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://fund.eastmoney.com/%@.html",_fundCode]]]];
}

@end
