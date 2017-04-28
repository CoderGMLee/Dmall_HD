//
//  UPInputView.h
//  DMAppFramework
//
//  Created by chenxinxin on 15/11/13.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "UPView.h"

@protocol UPInputViewJSExport <JSExport>
-(NSString*) getText;
-(NSString*) getPlaceholder;
-(NSString*) getType;
-(void) setText:(NSString *)text;
-(void) setType:(NSString*)spec;
-(void) setPlaceholder:(NSString*)spec;
-(void) setPlaceholderColor:(NSString*)spec;
-(void) setFontColor:(NSString*) spec;
-(void) setFontSize:(NSString*) spec;
-(void) setFontBold:(NSString*) spec;
@end

@interface UPInputView : UPView<UPInputViewJSExport>
@end
