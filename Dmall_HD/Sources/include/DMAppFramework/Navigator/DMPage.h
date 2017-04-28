//
//  DMPage.h
//  DMAppFramework
//
//  Created by chenxinxin on 15/10/27.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMNavigator.h"
#import "DMPageLifeCircle.h"
#import "DMPageAware.h"
#import "DMNibController.h"
#import "DMMagicMoveSet.h"

/*!
 *  DMPage是页面的基类。本质上也是一个UIViewController。
 *  DMAppFramework是支持管理原生的UIViewController，但是由于
 *  原生的UIViewController缺乏必要的生命周期及自省功能，因此推荐
 *  新增的页面都继承自DMPage. 
 *
 *  当然，考虑到集成到现有的代码模块时有可能很多页面已经有基类了，无法
 *  多重继承，因此，实际在集成到现有的代码时也可以不继承自DMPage, 而是
 *  让现有的页面实现DMPageAware,DMPageLifeCircle两个协议，这样做的
 *  效果是等价的。
 */
@interface DMPage : DMNibController <DMPageAware,DMPageLifeCircle,DMMagicMoveSet>
-(void) warePageParam:(NSString*)value byKey:(NSString*)key;

-(void) pageRollup;

@end


@interface DMPage(Navigate)
/*!
 *  跳转到指定的页面
 *
 *  @param url 页面资源路径
 *     可能为app，h5或者RN页面
 */
-(void) forward:(NSString*)url;

/*!
 *  跳转到指定的页面
 *
 *  @param url      页面资源路径
 *  @param callback 页面回调接口
 */
-(void) forward:(NSString* )url
callback:(void(^)(NSDictionary* ))callback;

/**
 * 触发页面回退
 * @param param 可选返回参数，允许携带框架参数(参数名以@开头)。（例如"param=value&param2=value2&@animate=popright"）
 *     如果不传此参数，框架将在页面回退的同时不向上一个页面的回传数据。
 *     这样做的目的，是允许开发者在当前页面其他时机去主动调用callback回传数据，
 *     避免页面传参和页面回退动作绑死。
 */
-(void) backward:(NSString*)param;


-(void) backward;

/**
 * 单独向上一个页面回传参数的接口
 * @param param 参数 （例如"param=value&param2=value2"）
 */
-(void) callback:(NSString*)param;

/*!
 *  开启一个子业务流程
 */
-(void) pushFlow;
/*!
 *  结束当前子业务流程，同时页面跳转回之前pushFlow的地方
 */
-(void) popFlow:(NSString*)param;
@end