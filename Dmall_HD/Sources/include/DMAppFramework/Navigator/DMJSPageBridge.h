//
//  DMWebPageBridge.h
//  DMAppFramework
//
//  Created by chenxinxin on 15/10/28.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "DMBridgeObject.h"
#import "DMNavigator.h"
#import <JavaScriptCore/JavaScriptCore.h>



@protocol DMJSPageBridgeJSExport <JSExport>
-(void) forward:(NSString*)url ;
-(void) backward:(NSString*)param;
-(void) pushFlow;
-(void) popFlow:(NSString*)param;
-(void) callback:(NSString*)param;
-(void) registRedirect:(NSString*)fromUrl :(NSString*)toUrl;
-(NSString*) topPage:(int)deep;
-(void) rollup;
-(void) httpPost:(NSString*)requestId :(NSString*)url :(id)headers :(NSString*)body;
-(void) httpGet:(NSString*)requestId :(NSString*)url :(id)headers ;
-(void) httpCallback:(NSString*)requestId :(NSString*)statusCode :(NSString*)data;
-(void) httpCancel:(NSString*)requestId;
@end


@interface DMJSPageBridge : DMBridgeObject <DMJSPageBridgeJSExport>
@property (weak,nonatomic) UIWebView* jsPage;
@property (weak,nonatomic) DMNavigator* navigator;
@end
