//
//  UPPathUtil.m
//  DMAppFramework
//
//  Created by chenxinxin on 15/11/13.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "UPPathUtil.h"

@implementation UPPathUtil

+(NSString*) trimTail:(NSString*)path {
    if ([path hasSuffix:@"/"]) {
        return [path substringToIndex:path.length-1];
    }
    return path;
}

+(NSString*) cleanPath:(NSString*)path {
    // 处理上层目录
    NSRange range;
    while ((range=[path rangeOfString:@"../"]).location != NSNotFound) {
        NSString* parent = [path substringToIndex:range.location];
        NSString* child = [path substringFromIndex:range.location+range.length];
        parent = [UPPathUtil parentPathFor:parent];
        path = [NSString stringWithFormat:@"%@/%@",parent,child];
    }
    
    // 处理当前目录
    while ((range=[path rangeOfString:@"./"]).location != NSNotFound) {
        NSString* parent = [path substringToIndex:range.location];
        NSString* child = [path substringFromIndex:range.location+range.length];
        parent = [UPPathUtil trimTail:parent];
        path = [NSString stringWithFormat:@"%@/%@",parent,child];
    }

    return path;
}

+(NSString*) resolveWithRootPath:(NSString*)rootPath
                     contextPath:(NSString*)contextPath
                    relativePath:(NSString*)relativePath {
    if([relativePath hasPrefix:@"http"]) {
        return relativePath;
    }
    
    rootPath = [UPPathUtil trimTail:rootPath];
    if (contextPath == nil) {
        contextPath = [NSString stringWithFormat:@"%@/.",rootPath];
    } else {
        contextPath = [UPPathUtil trimTail:contextPath];
    }
    relativePath = [UPPathUtil trimTail:relativePath];
    
    NSString* parentPath = nil;
    if ([relativePath hasPrefix:@"/"]) {
        relativePath = [relativePath substringFromIndex:1];
        parentPath = rootPath;
    } else {
        parentPath = [UPPathUtil parentPathFor:contextPath];
    }
    
    return [UPPathUtil cleanPath:[NSString stringWithFormat:@"%@/%@",parentPath,relativePath]];
}

+(NSString*) parentPathFor:(NSString*) path {
    path = [UPPathUtil trimTail:path];
    NSRange range = [path rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location == NSNotFound) {
        return @"";
    }
    return [path substringToIndex:range.location];
}

@end
