//
//  UPCacheLoader.h
//  DMAppFramework
//
//  Created by chenxinxin on 15/12/15.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPResourceLoader.h"
#import "DMBytesResponse.h"


@class UPBundleLoader;
@class UPNetLoader;

@interface UPCacheLoader : NSObject <UPResourceLoader>

@property (weak,nonatomic) UPNetLoader* netLoader;
@property (weak,nonatomic) UPBundleLoader* bundleLoader;

-(instancetype) initWithRootPath:(NSString*)path;
-(DMBytesResponse*) loadFromCache:(NSString*)path;
-(void) saveToCache:(DMBytesResponse*)data byPath:(NSString*)path;
-(BOOL) isRootInCache;
@end
