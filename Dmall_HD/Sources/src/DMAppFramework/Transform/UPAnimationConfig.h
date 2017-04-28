//
//  UPAnimationConfig.h
//  DMAppFramework
//
//  Created by chris on 16/1/29.
//  Copyright © 2016年 dmall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class UPAnimationConfig;

@protocol UPAnimationJSExport <JSExport>

@property(nonatomic, assign) CGFloat        duration;       //动画时间
@property(nonatomic, strong) NSDictionary   *position;      //平移的大小 ({x:20,y:20})
@property(nonatomic, strong) NSDictionary   *size;          //缩放大小 ({width:1.1,height:1.1})
@property(nonatomic, assign) CGFloat        angle;          //旋转角度 (M_PI_2)
@property(nonatomic, copy)   NSString       *axis;          //旋转轴 ("x","y","z")

@property(nonatomic, copy)   NSString       *animationType; //动画类型 ("position","scale","rotate")

+ (UPAnimationConfig*) animationConfig;

@end

@interface UPAnimationConfig : NSObject<UPAnimationJSExport>



@end
