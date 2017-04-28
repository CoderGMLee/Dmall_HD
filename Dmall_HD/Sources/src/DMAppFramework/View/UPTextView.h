//
//  UPTextView.h
//  DMAppFramework
//
//  Created by chenxinxin on 15/11/13.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "UPView.h"


@protocol UPTextViewJSExport <JSExport>
-(NSString*) getText;
-(void) setText:(NSString *)text;
-(void) setMaxWidth:(NSString*) spec;
-(void) setFontColor:(NSString*) spec;
-(void) setFontSize:(NSString*) spec;
-(void) setFontBold:(NSString*) spec;
@end

@interface UPTextView : UPView <UPTextViewJSExport>

@end
