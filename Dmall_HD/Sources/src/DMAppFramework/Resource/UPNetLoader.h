//
//  UPNetLoader.h
//  DMAppFramework
//
//  Created by chenxinxin on 15/12/15.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPResourceLoader.h"
#import "UPCacheLoader.h"

@interface UPNetLoader : NSObject <UPResourceLoader>

@property (strong,nonatomic) UPCacheLoader* cacheLoader;

-(void) loadResponse:(NSString*)path callback:(void (^)(DMBytesResponse *))callback;

-(void) saveToCache;

-(void) clearTempReources;

@end
