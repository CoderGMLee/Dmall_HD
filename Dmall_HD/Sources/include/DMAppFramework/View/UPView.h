//
//  UPView.h
//  UPAppFramework
//
//  Created by chenxinxin on 15/11/12.
//  Copyright (c) 2015年 UPall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UPLayoutParam.h"
#import "DMEvaluateScript.h"
#import "UPResourceLoader.h"
#import <JavaScriptCore/JavaScriptCore.h>


#define UPVIEW_VERSION @"V2.1.0"


@protocol UPResourceLocator <NSObject>
-(NSString*) locateResource : (NSString*)path;
@end

@class UPAnimationConfig;

/*!
 *  这些方法是可以在javascript中访问的方法
 */
@protocol UPViewJSExport <JSExport>
-(NSString*) getId;
-(NSString*) getGid;
-(BOOL) isVisible;
-(BOOL) isGone;

-(void) setId:(NSString*)spec;
-(void) setGid:(NSString*)spec;
-(void) setAlphaRate:(NSString*)spec;
-(void) setVisible:(NSString*)spec;
-(void) setGone:(NSString*)spec;
-(void) setSrc:(NSString*)spec ;
-(void) setLayout:(NSString *)spec ;
-(void) setWidth:(NSString *)spec ;
-(void) setHeight:(NSString *)spec ;
-(void) setMargin:(NSString*) spec ;
-(void) setMarginTop:(NSString*) spec ;
-(void) setMarginRight:(NSString*) spec ;
-(void) setMarginBottom:(NSString*) spec ;
-(void) setMarginLeft:(NSString*) spec ;
-(void) setPadding:(NSString*) spec ;
-(void) setPaddingTop:(NSString*) spec ;
-(void) setPaddingRight:(NSString*) spec ;
-(void) setPaddingBottom:(NSString*) spec ;
-(void) setPaddingLeft:(NSString*) spec ;
-(void) setGravity:(NSString*) spec ;
-(void) setContentGravity:(NSString*) spec ;
-(void) setBackground:(NSString*) spec ;
-(void) setBorderWidth:(NSString*) spec ;
-(void) setBorderColor:(NSString*) spec ;
-(void) setBorderCorner:(NSString*) spec;
-(void) setBorderClip:(NSString*) spec;
-(void) setOnClick:(NSString*) spec;
-(void) setOnDoubleClick:(NSString*) spec;

-(JSValue*) getPage;
-(void) startAnimation:(UPAnimationConfig*)config;

@end



/*!
 *  UPView是UPAppFramework提供的
 *  支持动态更新的视图对象，提供了一套
 *  基于XML构建并更新View的机制
 */
@interface UPView : UIView <UPViewJSExport,DMEvaluateScript>
@property (copy,nonatomic) NSString* id;
@property (copy,nonatomic) NSString* gid;
@property (copy,nonatomic) NSString* src;// 如果当前View是一个include的View会此字段不为空
@property (strong,nonatomic) id<UPResourceLoader> resourceLoader;
@property (strong,nonatomic) id<UPResourceLocator> resourceLocator;
@property (strong,nonatomic) UPLayoutParam* layoutParam;

@property (strong,nonatomic) NSString* match;

+(JSContext*) globalJSContext;

+(NSString*) getVersion;

-(id) deepClone;

-(void) injectValue:(NSString*)value forProperty:(NSString*)name;


-(void) requestLayout;

-(float) measureWidth;
-(float) measureHeight;

-(void) setContentGravity:(NSString*) spec;

-(NSString*) evaluateScript:(NSString*) script;

+(JSValue*) evaluate : (NSString*) script;

-(UPView*) findViewByGid:(NSString*)gid;

/*!
 *  在执行完所有依赖的脚本后，通过按照约定来调用和XML同名的js函数完成页面绑定和初始化工作
 *
 *  @param entryName 函数名称，默认和XML名称相同
 */
-(void) runEntryJSFunction:(NSString*)entryName;

+(void) loadViewFromPath:(NSString*)path callback:(void(^)(UPView*))callback;


+(void) loadViewFromPath:(NSString*)path resourceLoader:(id<UPResourceLoader>)resourceLoader callback:(void(^)(UPView*))callback;

/*!
 *  解析尺寸
 *
 *  @param spec 文本
 *
 *  @return 尺寸
 */
+(float) parseSize:(NSString*) spec;

+(UIColor*) parseColor:(NSString*) spec;


+(BOOL) parseBoolean:(NSString*) spec;
@end
