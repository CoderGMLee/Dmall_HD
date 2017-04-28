//
//  DMNetwork.h
//  DMAppFramework
//
//  Created by chris on 16/2/2.
//  Copyright © 2016年 dmall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMNetwork : NSObject


+ (void) doPostWithUrl:(NSString*)url headers:(NSDictionary*)headers body:(NSString*)bodyText callback:(void(^)(NSInteger statusCode, NSString *result))callback;

@end
