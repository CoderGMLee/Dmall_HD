//
//  DMBridgeProtocol.h
//  DMAppFramework
//
//  Created by chenxinxin on 15/11/13.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  该协议定义了object c暴露给javascript调用的接口
 */
@protocol DMBridgeProtocol<NSObject>
@required
/**
 * 子类需要重写此函数已提供当前Bridge在javascript中的对象名称
 */
-(NSString*) javascriptObjectName;

@end
