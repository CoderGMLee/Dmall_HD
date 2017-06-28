//
//  NSString+md5String.m
//  ImageTest
//
//  Created by 杨涵 on 15/4/16.
//  Copyright (c) 2015年 richard. All rights reserved.
//

#import "NSString+md5String.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (md5String)

- (NSString *) md5String
{
    const char *string = self.UTF8String;
    int length = (int)strlen(string);
    unsigned char bytes[CC_MD5_DIGEST_LENGTH];
    CC_MD5(string, length, bytes);
    NSString *str = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",bytes[0],bytes[1],bytes[2],bytes[3],bytes[4],bytes[5],bytes[6],bytes[7],bytes[8],bytes[9],bytes[10],bytes[11],bytes[12],bytes[13],bytes[14],bytes[15]];
    return [str lowercaseString];
}

- (NSString*) md5String32{
    
    const char *cStr = [self UTF8String];
    unsigned char digest[32];
    CC_MD5( cStr, (int)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < 32; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}
@end
