//
//  DMUrlEncoder.m
//  DMAppFramework
//
//  Created by chenxinxin on 15/10/28.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#include "DMUrlEncoder.h"


@implementation DMUrlEncoder


+(NSString*) encodeParams:(NSDictionary*)param {
    NSMutableString* buffer = [[NSMutableString alloc] init];
    
    BOOL first = YES;
    NSEnumerator* enumerator = [param keyEnumerator];
    id key = nil;
    while ((key = [enumerator nextObject]) != nil) {
        id value = [param objectForKey:key];
        if (first) {
            first = NO;
        } else {
            [buffer appendString:@"&"];
        }
        
        [buffer appendFormat:@"%@=%@",[DMUrlEncoder escape:key],[DMUrlEncoder escape:value]];
    }
    
    return buffer;
}

// 将URL编码
+ (NSString *)escape: (NSString *) input
{
    if (!input || input.length < 1) {
        return @"";
    }
    NSString *outputStr = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                 (CFStringRef)input,
                                                                                                 NULL,
                                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                 kCFStringEncodingUTF8));
    return outputStr;
}

// 将URL解码
+(NSString *)unescape: (NSString *) input
{
    if (!input || input.length < 1) {
        return @"";
    }
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    
    return [outputStr stringByRemovingPercentEncoding];
}

@end
