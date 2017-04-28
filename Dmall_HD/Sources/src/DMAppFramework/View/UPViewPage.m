//
//  UPViewPage.m
//  DMAppFramework
//
//  Created by chenxinxin on 15/11/16.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "UPViewPage.h"
#import "UPView.h"
#import "DMJSPageBridge.h"
#import "DMBridgeHelper.h"
#import "DMUrlDecoder.h"
#import "UPAnimationConfig.h"

@interface UPViewPage ()
@property (strong,nonatomic) UPView*        rootView;
@end

@implementation UPViewPage


-(NSString*) evaluateScript:(NSString*) script {
    if (self->_rootView != nil) {
        return [((UPView*)self->_rootView) evaluateScript:script];
    }
    return nil;
}

-(void) loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void) pageWillBeShown {
    [super pageWillBeShown];
    [self loadUPView];
    [self bindTransform];
}

-(void) loadUPView {
    if (self.rootView != nil) {
        return;
    }
    NSString* pageUrl = self.pageUrl;
    DMUrlInfo* urlInfo = [DMUrlDecoder decodeUrl:pageUrl];
    if ([@"up" isEqualToString:urlInfo.protocol]) {
        NSString* path = [urlInfo.urlPath substringFromIndex:4];
        [UPView loadViewFromPath:path callback:^(UPView * view) {
            self.rootView = view;
            self.rootView.frame = [UIScreen mainScreen].bounds;
            for (UIView* subview in self.view.subviews) {
                [subview removeFromSuperview];
            }
            [self.view addSubview:self.rootView];
        }];
    }
}

- (void) bindTransform{
    
    JSContext *context = [UPView globalJSContext];
    context[@"UPAnimationConfig"] = [UPAnimationConfig class];
}

@end
