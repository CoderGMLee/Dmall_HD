//
//  DMBridgeHelper.h
//  DMTools
//
//  Created by chenxinxin on 15/10/21.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DMBridgeObject.h"
#import "UPView.h"


@interface DMBridgeHelper : NSURLProtocol

/*!
 *  注册桥接对象
 *
 *  @param bridgeObject 桥接对象
 */
-(void) registBridge:(id<DMBridgeProtocol>) bridgeObject;

/*!
 *  绑定webView
 *  需要在绑定webView之前将所有的桥接对象注册到DMBridgeHelper中去
 *
 *  @param webView 待绑定的webView
 */
-(void) bindWebView:(UIWebView*) webView;

/*!
 *  绑定upView
 *  将所有桥接对象注册到UPView中去
 *
 *  @param upView 待绑定的upview
 */
-(void) bindUPView:(UPView*) upView;

+(DMBridgeHelper*) getInstance;

@end
