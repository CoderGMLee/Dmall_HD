//
//  DMNetUtil.m
//  DMAppFramework
//
//  Created by chenxinxin on 15/12/15.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "DMNetUtil.h"
#import "DMBytesResponse.h"
#import "DMLog.h"

@interface DMNetUtil()
+(DMLog*) logger;
@end

@interface DMNetUtilDelegate : NSObject<NSURLConnectionDelegate>
@property (strong,nonatomic) NSString* url;
@property (strong,nonatomic) DMBytesResponse* response;
@property (copy,nonatomic) void(^callback)(DMBytesResponse*);
@end

@implementation DMNetUtilDelegate

-(DMLog*) logger {
    return [DMNetUtil logger];
}

-(DMBytesResponse*) response {
    if (self->_response == nil) {
        self->_response = [[DMBytesResponse alloc] init];
    }
    return self->_response;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse* res = (NSHTTPURLResponse*)response;
    self.response.statusCode = (int)res.statusCode;
    self.response.lastModified = [res.allHeaderFields objectForKey:@"Last-Modified"];
    self.response.etag = [res.allHeaderFields objectForKey:@"ETag"];
    self.response.maxAge = [self parseMaxAge:[res.allHeaderFields objectForKey:@"Cache-Control"]];
    if (self.response.maxAge >= 0) {
        self.response.expireTime = [[[NSDate alloc] init] timeIntervalSince1970] * 1000l + self.response.maxAge;
    } else {
        self.response.expireTime = [[[NSDate alloc] init] timeIntervalSince1970] * 1000l;
    }
}

-(long long) parseMaxAge:(NSString*)cacheControll {
    BOOL limitMaxAge = [self.url hasSuffix:@".xml"] || [self.url hasSuffix:@".js"];
    
    NSRange range = [cacheControll rangeOfString:@"max-age\\s*=\\s*([0-9]+)" options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        NSString* sub = [cacheControll substringWithRange:range];
        long long maxAge = [[sub componentsSeparatedByString:@"="][1] longLongValue]*1000;
        if (limitMaxAge) {
            // xml 和 js 的过期时间不能超过2小时
            long long maxMaxAge = 1000 * 60 * 60 * 2;
            if (maxAge > maxMaxAge) {
                maxAge = maxMaxAge;
            }
        }
        return maxAge;
    }
    return -1;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (data == nil) {
        return;
    }
    if (self.response.data == nil) {
        self.response.data = [[NSMutableData alloc] init];
    }
    [self.response.data appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self fireCallback];
    DMDebug(@"finish request url:%@ etag:%@ lastModified:%@ statusCode:%d",self.url,self.response.etag,self.response.lastModified,self.response.statusCode);
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.response.statusCode = (int)error.code;
    [self fireCallback];
    DMError(@"error request url:%@ statusCode:%d",self.url,self.response.statusCode);
}

-(void)fireCallback {
    void(^callback)(DMBytesResponse*) = self.callback;
    DMBytesResponse* response = self.response;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (callback) {
            callback(response);
        }
    });
}

@end


@implementation DMNetUtil

DMLOG_DEFINE(DMNetUtil)


NSOperationQueue* DMNetUtil_operationQueue;

+(NSOperationQueue*) operationQueue {
    if (DMNetUtil_operationQueue == nil) {
        DMNetUtil_operationQueue = [[NSOperationQueue alloc] init];
//        [DMNetUtil_operationQueue setMaxConcurrentOperationCount:10240];
    }
    return DMNetUtil_operationQueue;
}


+(void) doGetUrl:(NSString*)url
            etag:(NSString*)etag
    lastModified:(NSString*)lastModified
        callback:(void(^)(DMBytesResponse*))callback {
    DMDebug(@"start request url:%@ etag:%@ lastModified:%@",url,etag,lastModified);
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.3 (KHTML, like Gecko) Version/8.0 Mobile/12A4345d Safari/600.1.4" forHTTPHeaderField:@"User-Agent"];
    if (etag) {
        [request setValue:etag forHTTPHeaderField:@"If-None-Match"];
    }
    if (lastModified) {
        [request setValue:lastModified forHTTPHeaderField:@"If-Modified-Since"];
    }
    DMNetUtilDelegate* delegate = [[DMNetUtilDelegate alloc] init];
    delegate.url = url;
    delegate.callback = callback;
    NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:request delegate:delegate];
    [conn setDelegateQueue:[DMNetUtil operationQueue]];
    [conn start];
}

@end
