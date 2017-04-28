//
//  DMWebPage.m
//  DMAppFramework
//
//  Created by chenxinxin on 15/10/27.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "DMWebPage.h"
#import "DMBridgeHelper.h"
#import "DMJSPageBridge.h"

@interface DMWebPage () <UIWebViewDelegate>
@property (strong,nonatomic) DMJSPageBridge* jsPageBridge;
@end

@implementation DMWebPage

-(NSString*) evaluateScript:(NSString*) script {
    return [self.webView stringByEvaluatingJavaScriptFromString:script];
}

-(DMJSPageBridge*) jsPageBridge {
    if (self->_jsPageBridge == nil) {
        self->_jsPageBridge = [[DMJSPageBridge alloc] init];
        self->_jsPageBridge.jsPage = self.webView;
        self->_jsPageBridge.navigator = self.navigator;
    }
    return self->_jsPageBridge;
}



-(UIWebView*) webView {
    if (self->_webView == nil) {
        self->_webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self->_webView.backgroundColor = [UIColor greenColor];
    }
    return self->_webView;
}

-(void) loadView {
    self.view = self.webView;
    self.webView.delegate = self;
}

-(void) pageWillBeShown {
    [super pageWillBeShown];
    [[DMBridgeHelper getInstance] registBridge:self.jsPageBridge];
    [[DMBridgeHelper getInstance] bindWebView:self.webView];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
//    [[DMBridgeHelper getInstance] bindWebView:self.webView];
}

-(void) webViewDidFinishLoad:(UIWebView *)webView {
//    [[DMBridgeHelper getInstance] bindWebView:self.webView];

}

-(void) pageDestroy {
    [super pageDestroy];
    [self.webView stopLoading];
    self.webView = nil;
}

-(void) pageWillForwardToMe {
    [super pageWillForwardToMe];
    NSString* pageUrl = self.pageUrl;
    NSURL* url = nil;
    if ([pageUrl rangeOfString:@"file://"].location == 0) {
        NSString*   filePath = [pageUrl substringFromIndex:7];
        NSString* fileFolder = [filePath substringToIndex:
                                    (filePath.length-filePath.lastPathComponent.length-1)];
        NSURL*       context = [NSURL fileURLWithPath:fileFolder];
        
        [self.webView loadHTMLString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] baseURL:context];
    } else {
        url = [NSURL URLWithString:pageUrl];
        NSURLRequest* request = [NSURLRequest requestWithURL:url] ;
        [self.webView loadRequest:request];
    }
}

@end
