//
//  DMBytesResponse.m
//  DMAppFramework
//
//  Created by chenxinxin on 15/12/15.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "DMBytesResponse.h"

@implementation DMBytesResponse

-(NSData*) toData {
    NSMutableData* buffer = [[NSMutableData alloc] init];
    
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:buffer];
    [archiver encodeInt64:self.statusCode forKey:@"statusCode"];
    [archiver encodeInt64:self.maxAge forKey:@"maxAge"];
    [archiver encodeInt64:self.expireTime forKey:@"expireTime"];
    [archiver encodeObject:self.etag forKey:@"etag"];
    [archiver encodeObject:self.lastModified forKey:@"lastModified"];
    [archiver encodeObject:self.data forKey:@"data"];
    [archiver finishEncoding];
    return buffer;
}
-(void) fromData:(NSData*)data {
    NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    self.statusCode = (int)[unarchiver decodeInt64ForKey:@"statusCode"];
    self.maxAge = [unarchiver decodeInt64ForKey:@"maxAge"];
    self.expireTime = [unarchiver decodeInt64ForKey:@"expireTime"];
    self.etag = [unarchiver decodeObjectForKey:@"etag"];
    self.lastModified = [unarchiver decodeObjectForKey:@"lastModified"];
    self.data = [unarchiver decodeObjectForKey:@"data"];
}

@end
