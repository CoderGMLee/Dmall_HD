//
//  UPPageViewLoader.h
//  DMAppFramework
//
//  Created by chenxinxin on 15/12/15.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UPResourceLoader.h"
#import "UPView.h"

@interface UPPageViewLoader : NSObject <UPResourceLoader>

-(instancetype) initWithRootPath:(NSString*) rootPath;

-(void) checkAndUpdate:(void(^)(UPView*))callback;

@end
