//
//  DMBridgeObject.m
//  DMTools
//
//  Created by chenxinxin on 15/10/21.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "DMBridgeObject.h"
#import <objc/runtime.h>



@implementation DMBridgeObject
-(NSString*) javascriptObjectName {
    return @"window.bridge";
}
@end
