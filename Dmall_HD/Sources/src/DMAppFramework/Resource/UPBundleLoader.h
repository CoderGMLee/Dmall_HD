//
//  UPDefaultResourceLoader.h
//  DMAppFramework
//
//  Created by chenxinxin on 15/11/12.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UPView.h"
#import "UPCacheLoader.h"

/*!
 *  默认只从本地bundle中获取资源
 */
@interface UPBundleLoader : NSObject<UPResourceLoader>

@property (weak,nonatomic) UPCacheLoader* cacheLoader;


-(instancetype) initWithRootPath:(NSString*)rootPath;

-(BOOL) isRootInBundle;

@end
