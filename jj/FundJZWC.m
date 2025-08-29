//
//  FundJZWC.m
//  jj
//
//  Created by LY_MD on 2020/8/17.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import "FundJZWC.h"
#import <WebKit/WebKit.h>

@interface FundJZWC () <WKUIDelegate, WKNavigationDelegate>

@property(weak) IBOutlet WKWebView *webV;

@end

@implementation FundJZWC

- (void)windowDidLoad {
    [super windowDidLoad];
    self.window.title = _fundName;
    //    self.webV.UIDelegate = self;
    //    self.webV.navigationDelegate = self;
    [self.webV loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://fund.eastmoney.com/%@.html", _fundCode]]]];
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    NSLog(@"createWebViewWithConfiguration");
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    // 如果是跳转一个新页面
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }

    decisionHandler(WKNavigationActionPolicyAllow);
}


@end
