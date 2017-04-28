//
//  UPDefaultResourceLoader.m
//  UPAppFramework
//
//  Created by chenxinxin on 15/11/12.
//  Copyright (c) 2015年 UPall. All rights reserved.
//

#import "UPBundleLoader.h"
#import "UPPathUtil.h"

@interface UPBundleLoader()
@property (strong,nonatomic) NSString* baseBundle;
@property (strong,nonatomic) NSString* rootPath;
@end

@implementation UPBundleLoader

-(instancetype) initWithRootPath:(NSString*)rootPath {
    if (self = [super init]) {
        self.baseBundle = @"UPBundle.bundle";
        self.rootPath = rootPath;
    }
    return self;
}

-(void)loadResource:(NSString*)name callback:(void(^)(NSData*))callback {
    if ([name hasPrefix:@"http"]) {
        [self.cacheLoader loadResource:name callback:callback];
        return;
    }
    NSString* fullpath = [UPPathUtil resolveWithRootPath:self.baseBundle contextPath:nil relativePath:name];
    NSString* path = [[NSBundle mainBundle] pathForResource:fullpath ofType:nil];
    if (path == nil) {
        [self.cacheLoader loadResource:name callback:callback];
        return;
    }
    NSData* data = [NSData dataWithContentsOfFile:path];
    callback(data);
}

-(BOOL) isRootInBundle {
    NSString* fullpath = [UPPathUtil resolveWithRootPath:self.baseBundle contextPath:nil relativePath:self.rootPath];
    NSString* path = [[NSBundle mainBundle] pathForResource:fullpath ofType:nil];
    return path != nil;
}

@end
