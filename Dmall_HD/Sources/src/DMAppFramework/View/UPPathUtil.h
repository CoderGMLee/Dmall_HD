//
//  UPPathUtil.h
//  DMAppFramework
//
//  Created by chenxinxin on 15/11/13.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPPathUtil : NSObject

+(NSString*) resolveWithRootPath:(NSString*)rootPath
                     contextPath:(NSString*)contextPath
                    relativePath:(NSString*)relativePath;

+(NSString*) parentPathFor:(NSString*) path;

@end
