//
//  UPNetLoader.m
//  DMAppFramework
//
//  Created by chenxinxin on 15/12/15.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "UPNetLoader.h"
#import "DMNetUtil.h"
#import "DMWeakify.h"
#import "DMLog.h"
#import "UPView.h"

@interface UPNetLoader()

@property (strong,nonatomic) NSMutableDictionary* toBeUpdate;

@end


@implementation UPNetLoader


DMLOG_DEFINE(UPNetLoader)


NSString* UPNetLoader_baseUrl = @"http://st.app.dmall.com/UPViewPage/iOS/" UPVIEW_VERSION @"/UPBundle.bundle";


-(void) loadResponse:(NSString*)path callback:(void (^)(DMBytesResponse *))callback {
    NSString* url = nil;
    if ([path hasPrefix:@"http"]) {
        url = path;
    } else {
        url = [NSString stringWithFormat:@"%@%@",UPNetLoader_baseUrl,path];
    }
    
    DMBytesResponse* res = [self.cacheLoader loadFromCache:path];
    NSString* lastModified = nil;
    NSString* etag = nil;
    if (res != nil) {
        lastModified = res.lastModified;
        etag = res.etag;
    }
    
    DMDebug(@"start load url => %@ etag:%@ lastModified:%@",url,etag,lastModified);
    
    
    @weakify_self
    [DMNetUtil doGetUrl:url etag:etag lastModified:lastModified callback:^(DMBytesResponse * obj) {
        @strongify_self
        if (obj.statusCode == 304) {
            DMDebug(@"load success with 304 not modified => %@",url);
            // 资源没变化，需要更新
            obj.data = res.data;
            if (obj.maxAge < 0) {
                obj.maxAge = res.maxAge;
                obj.expireTime = [[[NSDate alloc] init] timeIntervalSince1970]*1000 + obj.maxAge;
            }
            callback(obj);
            return;
        }
        
        if (obj.statusCode == 200) {
            DMDebug(@"load success with 200 => %@ dataLen:%d",url,(int)obj.data.length);
            [self.toBeUpdate setObject:obj forKey:path];
            callback(obj);
            return;
        }
        
        DMDebug(@"load failed with status code %d => %@",obj.statusCode,url);
        callback(obj);
    }];
}

-(void) loadResource:(NSString *)path callback:(void (^)(NSData *))callback {
    [self loadResponse:path callback:^(DMBytesResponse *obj) {
        if (obj.statusCode == 304 || obj.statusCode == 200) {
            /**
             * 正常情况下载网络加载数据之后不能立即存储，因为有可能影响到本地数据的一致性
             * 因此需要在更新结束后一次性存入缓存, 考虑到单页面的量不会太大，因此
             * 暂时存储在内存中已备后续一次性存入缓存更新内容。
             */
            [self.toBeUpdate setObject:obj forKey:path];
            callback(obj.data);
            return;
        }
        
        // 其他错误码数据不是需要的数据，而是hmtl错误信息内容，因此不能回传调用者
        callback(nil);
    }];
}

-(NSMutableDictionary*) toBeUpdate {
    if (self->_toBeUpdate == nil) {
        self->_toBeUpdate = [[NSMutableDictionary alloc] init];
    }
    return self->_toBeUpdate;
}


-(void) saveToCache {
    for (NSString* key in self.toBeUpdate) {
        DMBytesResponse* data = [self.toBeUpdate objectForKey:key];
        [self.cacheLoader saveToCache:data byPath:key];
    }
}

-(void) clearTempReources {
    self.toBeUpdate = nil;
}

@end
