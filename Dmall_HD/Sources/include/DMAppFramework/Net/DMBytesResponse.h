//
//  DMBytesResponse.h
//  DMAppFramework
//
//  Created by chenxinxin on 15/12/15.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMBytesResponse : NSObject
@property (assign,nonatomic) int statusCode;
@property (assign,nonatomic) long long maxAge;
@property (assign,nonatomic) long long expireTime;
@property (strong,nonatomic) NSString* etag;
@property (strong,nonatomic) NSString* lastModified;
@property (strong,nonatomic) NSMutableData* data;

-(NSData*) toData;
-(void) fromData:(NSData*)data;
@end
