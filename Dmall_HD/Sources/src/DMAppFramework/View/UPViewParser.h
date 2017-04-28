//
//  UPViewParser.h
//  UPAppFramework
//
//  Created by chenxinxin on 15/11/12.
//  Copyright (c) 2015年 UPall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPView.h"

@interface UPViewParser : NSObject

@property (strong,nonatomic) NSString* classPrefix;
/*!
 *  contextPath是当前解析器解析的对象的资源路径（完整路径），如果资源中有
 * 相对路径的查找需求，将以contextPath为参考去找。
 */
@property (strong,nonatomic) NSString* contextPath;
/*!
 *  rootPath是根路径，如果当前资源中包含相对根路径的查询需求，将以rootPath为参考去查找
 */
@property (strong,nonatomic) NSString* rootPath;
@property (strong,nonatomic) id<UPResourceLoader> resourceLoader;

@property (copy,nonatomic) void(^callback)(UPView*) ;

-(void) parse;
@end
