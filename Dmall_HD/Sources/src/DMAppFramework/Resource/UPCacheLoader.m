//
//  UPCacheLoader.m
//  DMAppFramework
//
//  Created by chenxinxin on 15/12/15.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "UPCacheLoader.h"
#import "DMCache.h"
#import "UPNetLoader.h"
#import "DMWeakify.h"
#import "UPView.h"
#import "UPBundleLoader.h"

@interface UPCacheLoader()
@property (strong,nonatomic) NSString* rootPath;
@end

@implementation UPCacheLoader
-(instancetype) initWithRootPath:(NSString *)path {
    if (self = [super init]) {
        self.rootPath = path;
    }
    return self;
}

-(void) loadResource:(NSString *)name callback:(void (^)(NSData *))callback {
    DMBytesResponse* res = [self loadFromCache:name];
    if (res == nil) {
        @weakify_self
        [self.netLoader loadResponse:name  callback:^(DMBytesResponse *obj) {
            @strongify_self
            
            // 如果obj.data 为nil 尝试再去bundle里取
            if (obj.data == nil) {
                [self.bundleLoader loadResource:name callback:callback];
                return;
            }
            
            callback(obj.data);
            if(obj.statusCode == 304 || obj.statusCode == 200) {
                [self saveToCache:obj byPath:name];
            }
        }];
        return;
    }
    callback(res.data);
    
    if ([name hasSuffix:@".xml"] || [name hasSuffix:@".js"]) {
        return;
    }
    
    @weakify_self
    [self.netLoader loadResponse:name  callback:^(DMBytesResponse *obj) {
        @strongify_self
        
        if(obj.statusCode == 200) {
            [self saveToCache:obj byPath:name];
            callback(obj.data);
        }
    }];
}

-(DMBytesResponse*) loadFromCache:(NSString*)path {
    NSString* key = [self getCacheKey:path];
    NSData* data = [[DMCache getInstance] dataForKey:key];
    if (data == nil) {
        return nil;
    }
    DMBytesResponse* res = [[DMBytesResponse alloc] init];
    [res fromData:data];
    return res;
}
-(void) saveToCache:(DMBytesResponse*)data byPath:(NSString*)path {
    if (path == nil || data == nil) {
        return;
    }
    if (data.statusCode != 200 && data.statusCode != 304) {
        // 非正常数据不做存储
        return;
    }
    NSString* key = [self getCacheKey:path];
    [[DMCache getInstance] setData:[data toData] forKey:key];
}
-(BOOL) isRootInCache {
    NSString* key = [self getCacheKey:self.rootPath];
    NSData* data = [[DMCache getInstance] dataForKey:key];
    return data != nil;
}

-(NSString*) getCacheKey:(NSString*)path {
    return [NSString stringWithFormat:@"upcache/%@/%@!!%@",UPVIEW_VERSION,self.rootPath,path];
}
@end
