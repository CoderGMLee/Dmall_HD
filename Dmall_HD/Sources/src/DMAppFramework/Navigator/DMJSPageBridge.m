//
//  DMWebPageBridge.m
//  DMAppFramework
//
//  Created by chenxinxin on 15/10/28.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "DMJSPageBridge.h"
#import "DMUrlEncoder.h"
#import "DMUrlDecoder.h"
#import "DMPage.h"

@implementation DMJSPageBridge
-(NSString*) javascriptObjectName {
    return @"window.pageBridge";
}

-(void) forward:(NSString*)url {
    [self.navigator forward:url callback:^(NSDictionary *param) {
        NSString* str = [DMUrlEncoder encodeParams:param];
        [self.jsPage stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"com.dmall.Bridge.appPageCallback(\"%@\")",str]];
    }];
}
-(void) backward:(NSString*)param {
    [self.navigator backward:param];
}
-(void) pushFlow {
    [self.navigator pushFlow];
}
-(void) popFlow:(NSString*)param {
    [self.navigator popFlow:param];
}
-(void) callback:(NSString*)param {
    [self.navigator callback:param];
}
-(void) registRedirect:(NSString*)fromUrl :(NSString*)toUrl {
    [DMNavigator registRedirectFromUrl:fromUrl toUrl:toUrl];
}
-(NSString*) topPage:(int)deep {
    return [((DMPage*)[[DMNavigator getInstance] topPage:deep]) pageUrl];
}
@end
