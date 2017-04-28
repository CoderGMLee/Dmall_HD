//
//  UPPageViewLoader.m
//  DMAppFramework
//
//  Created by chenxinxin on 15/12/15.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "UPPageViewLoader.h"
#import "UPBundleLoader.h"
#import "UPCacheLoader.h"
#import "UPNetLoader.h"
#import "UPView.h"
#import "DMWeakify.h"
#import "UPViewUpdator.h"
#import "UPPathUtil.h"
#import "DMLog.h"
#import "DMDateUtil.h"


@interface UPPageViewLoader()
@property (strong,nonatomic) NSString* rootPath;
@property (strong,nonatomic) UPCacheLoader* cacheLoader;
@property (strong,nonatomic) UPBundleLoader* bundleLoader;
@property (strong,nonatomic) UPNetLoader* netLoader;
@property (assign,nonatomic) BOOL isRootInCache;
@property (assign,nonatomic) BOOL isRootInBundle;
@end

@implementation UPPageViewLoader


DMLOG_DEFINE(UPPageViewLoader)

-(instancetype) initWithRootPath:(NSString *)rootPath {
    if (self = [super init]) {
        self.rootPath = rootPath;
        self.cacheLoader = [[UPCacheLoader alloc] initWithRootPath:rootPath];
        self.bundleLoader = [[UPBundleLoader alloc] initWithRootPath:rootPath];
        self.netLoader = [[UPNetLoader alloc] init];
        self.netLoader.cacheLoader = self.cacheLoader;
        self.bundleLoader.cacheLoader = self.cacheLoader;
        self.cacheLoader.netLoader = self.netLoader;
        self.cacheLoader.bundleLoader = self.bundleLoader;
        
        self.isRootInCache = [self.cacheLoader isRootInCache];
        self.isRootInBundle = [self.bundleLoader isRootInBundle];
        
        DMDebug(@"init loader for page => %@ inbundle:%d incache:%d",rootPath,self.isRootInBundle,self.isRootInCache);
    }
    return self;
}

-(BOOL) loadResourceFromCache:(NSString*)path callback:(void (^)(NSData *))callback {
    if (!self.isRootInCache) {
        return NO;
    }
    [self.cacheLoader loadResource:path callback:callback];
    return YES;
}


-(BOOL) loadResourceFromBundle:(NSString*)path callback:(void (^)(NSData *))callback {
    if (!self.isRootInBundle) {
        return NO;
    }
    [self.bundleLoader loadResource:path callback:callback];
    return YES;
}

-(void) loadResourceFromNet:(NSString*)path callback:(void (^)(NSData *))callback {
    [self.netLoader loadResource:path callback:callback];
}


-(void) update:(void(^)(UPView*))callback {
    DMDebug(@"start update page due to expired => %@",self.rootPath);
    UPViewUpdator* updator = [[UPViewUpdator alloc] init];
    updator.resourceLoader = self.netLoader;
    updator.contextPath = [UPPathUtil resolveWithRootPath:@"/" contextPath:nil relativePath:self.rootPath];
    updator.rootPath = @"/";
    updator.callback = ^(BOOL succ){
        if (succ) {
            DMDebug(@"update success. will save to cache");
            [self.netLoader saveToCache];
            
            [UPView loadViewFromPath:self.rootPath resourceLoader:self.cacheLoader callback:callback];
        } else {
            DMWarn(@"update failed. will drop temp resources.")
            [self.netLoader clearTempReources];
        }
    };
    [updator update];
}

-(void) checkAndUpdate:(void(^)(UPView*))callback {
    DMDebug(@"start check update for page => %@",self.rootPath);
    if (self.isRootInCache) {
        
        /*
        DMBytesResponse* data = [self.cacheLoader loadFromCache:self.rootPath];
        if (data == nil) {
            DMError(@"page not exist in cache => %@",self.rootPath);
            return;
        }
        
        // 检查是否过期
        long long now = [[[NSDate alloc] init] timeIntervalSince1970] * 1000;
        if (data.expireTime > now) {
            DMDebug(@"page not expire (expire:%@) => %@",[DMDateUtil formatTimeMillsSince1970:data.expireTime],self.rootPath);
            return;
        }
        DMDebug(@"page expired (expire:'%@') in cache => %@",[DMDateUtil formatTimeMillsSince1970:data.expireTime],self.rootPath);
        
         */
        
        
        [self update:callback];
        return;
    }
    
    if (self.isRootInBundle) {
        // 到此处，说明Cache没有，只有Bundle有，需要发起更新请求，成功后缓存到本地
        
        [self update:callback];
        return;
    }
    
    // 到此处说明Cache和Bundle里都没有，但是已经从网上刚刚加载过一次了，只需要存入缓存即可
    [self.netLoader saveToCache];
}


-(void) loadResource:(NSString *)name callback:(void (^)(NSData *))callback {
    if ([self loadResourceFromCache:name callback:callback]) {
        return;
    }
    
    if ([self loadResourceFromBundle:name callback:callback]) {
        return;
    }
    
    [self loadResourceFromNet:name callback:callback];
}


@end
