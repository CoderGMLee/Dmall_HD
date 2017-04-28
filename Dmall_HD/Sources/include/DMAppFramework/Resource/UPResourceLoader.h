//
//  UPView.h
//  UPAppFramework
//
//  Created by chenxinxin on 15/11/12.
//  Copyright (c) 2015年 UPall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UPResourceLoader <NSObject>
/*!
 *  加载资源接口
 *  此接口实现资源加载功能，由于可能存在网络更新，此接口回调可能调用多次，框架会跟新视图
 *  @param name     资源名称
 *  @param callback 回调接口
 */
-(void)loadResource:(NSString*)name callback:(void(^)(NSData*))callback;
@end


