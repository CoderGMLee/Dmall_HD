//
//  DMUrlDecoder.h
//  DMAppFramework
//
//  Created by chenxinxin on 15/10/27.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMUrlInfo : NSObject
@property (strong,nonatomic) NSString* url;
@property (strong,nonatomic) NSString* urlOrigin;
@property (strong,nonatomic) NSString* urlPath;
@property (strong,nonatomic) NSString* protocol;
@property (strong,nonatomic) NSString* animation;
@property (strong,nonatomic) NSString* appPageName;
@property (strong,nonatomic) NSMutableDictionary* params;
@property (strong,nonatomic) NSMutableDictionary* frameworkParams;
@property (strong,nonatomic) NSMutableArray* paramsArray;

@end


@interface DMUrlDecoder : NSObject

+(DMUrlInfo*) decodeUrl:(NSString*)url;

+(DMUrlInfo*) decodeParams:(NSString*)paramUrl;

@end
