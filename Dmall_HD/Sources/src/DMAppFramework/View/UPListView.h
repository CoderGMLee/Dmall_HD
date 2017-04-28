//
//  UPListView.h
//  DMAppFramework
//
//  Created by chenxinxin on 15/11/18.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "UPView.h"

@protocol UPListViewJSExport <JSExport>
-(void) setPullEnable : (NSString*) spec;
-(void) setData : (NSString*) spec;
-(void) setOnPull : (NSString*) spec;
-(void) setHeaderBackgroundImage : (NSString*) spec;
-(void) setHeaderArrowImage : (NSString*) spec;
-(void) populate : (JSValue*) param;
@end

@interface UPListView : UPView <UPListViewJSExport>

@end
