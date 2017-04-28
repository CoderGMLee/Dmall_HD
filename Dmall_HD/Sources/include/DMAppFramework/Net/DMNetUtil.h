//
//  DMNetUtil.h
//  DMAppFramework
//
//  Created by chenxinxin on 15/12/15.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMBytesResponse.h"

@interface DMNetUtil : NSObject

+(void) doGetUrl:(NSString*)url
            etag:(NSString*)etag
    lastModified:(NSString*)lastModified
        callback:(void(^)(DMBytesResponse*))callback;

@end
