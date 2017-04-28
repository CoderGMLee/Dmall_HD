//
//  DMUrlDecoder.m
//  DMAppFramework
//
//  Created by chenxinxin on 15/10/27.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "DMUrlDecoder.h"
#import "DMUrlEncoder.h"
#import "DMStringUtils.h"


@implementation DMUrlInfo
-(NSMutableDictionary*) params {
    if (self->_params == nil) {
        self->_params = [[NSMutableDictionary alloc] init];
    }
    return self->_params;
}
-(NSMutableDictionary*) frameworkParams {
    if (self->_frameworkParams == nil) {
        self->_frameworkParams = [[NSMutableDictionary alloc] init];
    }
    return self->_frameworkParams;
}

-(NSMutableArray*)paramsArray {
    if (self->_paramsArray == nil) {
        self->_paramsArray = [[NSMutableArray alloc] init];
    }
    return self->_paramsArray;
}
@end

@implementation DMUrlDecoder
/*!
 *  将url解析成模型
 *
 *  @param url 待解析的url
 *
 *  @return 解析后的信息
 */
+(DMUrlInfo*) decodeUrl:(NSString*)url {
    DMUrlInfo* info = nil;
    if (!url) {
        return info;
    }
    url             = [DMStringUtils trim:url];
    NSRange stub    = [url rangeOfString:@"?"];
    
    if(stub.location != NSNotFound && url.length > (stub.location + 1)) {
        NSString* paramUrl  = [url substringFromIndex:stub.location + 1];
        info                = [DMUrlDecoder decodeParams:paramUrl];
        info.urlPath        = [url substringToIndex:stub.location];
    } else {
        info            = [[DMUrlInfo alloc] init];
        info.urlPath    = url;
    }
    info.urlOrigin = url;

    NSRange protocolStub = [url rangeOfString:@"://"];
    if (protocolStub.location != NSNotFound) {
        info.protocol = [url substringToIndex:protocolStub.location];
        NSArray* pathComponents = [[url substringFromIndex:protocolStub.location+3] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"?"]];
        info.appPageName = pathComponents[0];
    }
    
    NSMutableString* buffer = [[NSMutableString alloc] init];
    [buffer appendString:info.urlPath];
    if (info.params.count > 0) {
        [buffer appendString:@"?"];
        BOOL first = YES;
        for (NSDictionary *dict in info.paramsArray) {
            for (NSString *key in dict) {
                if (first) {
                    first = NO;
                } else {
                    [buffer appendString:@"&"];
                }
                id value = dict[key];
                [buffer appendFormat:@"%@=%@",[DMUrlEncoder escape:key],[DMUrlEncoder escape:value]];
            }
        }
    }
    info.url = buffer;
    return info;
}
/*!
 *  只解析url中参数的部分
 *
 *  @param paramUrl 待解析的url
 *
 *  @return 解析后的模型
 */
+(DMUrlInfo*) decodeParams:(NSString*)paramUrl {
    if([DMStringUtils isEmpty:paramUrl]) {
        return nil;
    }
    
    DMUrlInfo* info = [[DMUrlInfo alloc] init];
    paramUrl        = [DMStringUtils trim:paramUrl];
    info.urlOrigin  = paramUrl;
    info.url        = paramUrl;
    
    NSArray* components = [paramUrl componentsSeparatedByString:@"&"];
    for (NSString* element in components) {
        NSArray* keyValuePair   =  [element componentsSeparatedByString:@"="];
        if (keyValuePair.count < 2) {
            [info.params setObject:@"" forKey:element];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"", element, nil];
            [info.paramsArray addObject:dict];
            continue;
        }
        NSString* key           =  [DMStringUtils trim:[DMUrlEncoder unescape:keyValuePair[0]]];
        NSString* value         =  [DMStringUtils trim:[DMUrlEncoder unescape:keyValuePair[1]]];
        if ([key rangeOfString:@"@"].location == 0) {
            [info.frameworkParams setObject:value forKey:[key substringFromIndex:1]];
        } else {
            [info.params setObject:value forKey:key];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:value, key, nil];
            [info.paramsArray addObject:dict];
        }
    }
    return info;
}


@end
