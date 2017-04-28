//
//  UPView+Private.h
//  DMAppFramework
//
//  Created by chenxinxin on 15/11/19.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

@interface UPView(Private)
@property (strong,nonatomic) NSMutableDictionary* populateParams;
-(JSValue*) getValueFromJSObject:(JSValue*) value byExpression:(NSString*)expression;
-(void) populatePageData:(JSValue*) value;
-(void) invokeJSMethod:(NSString*)methodSpec;
+(JSContext*) globalJSContext;
@end