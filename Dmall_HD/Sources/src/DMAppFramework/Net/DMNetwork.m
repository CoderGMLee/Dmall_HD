//
//  DMNetwork.m
//  DMAppFramework
//
//  Created by chris on 16/2/2.
//  Copyright © 2016年 dmall. All rights reserved.
//

#import "DMNetwork.h"

@implementation DMNetwork

+ (void) doPostWithUrl:(NSString *)url headers:(NSDictionary *)headers body:(NSString *)bodyText callback:(void (^)(NSInteger, NSString *))callback{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    
    // set headers
    for(NSString *key in [headers allKeys]){
        [request setValue:headers[key] forHTTPHeaderField:key];
    }
    
    // set body
    if(bodyText.length>0){
        NSData *bodyData = [bodyText dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPBody = bodyData;
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *result = nil;
        NSInteger statusCode = 0;
        if(error){
            result = @"网络错误";
            statusCode = -1;
        }
        else{
            result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            statusCode = ((NSHTTPURLResponse*)response).statusCode;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(callback){
                callback(statusCode,result);
            }
        });
        
    }];

    [task resume];
}

+ (NSData*) dataFromParams:(NSDictionary*)params{
    
    NSMutableString *paramsText = [[NSMutableString alloc] init];
    for(NSString *key in [params allKeys]){
        NSString *field = [NSString stringWithFormat:@"%@=%@&",key,params[key]];
        [paramsText appendString:field];
    }
    
    NSString *bodyText = paramsText;
    if(bodyText.length>0){
        bodyText = [bodyText substringToIndex:bodyText.length-1];
    }
    
    return [bodyText dataUsingEncoding:NSUTF8StringEncoding];
}

@end
