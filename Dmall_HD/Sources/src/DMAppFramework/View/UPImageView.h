//
//  UPImageView.h
//  DMAppFramework
//
//  Created by chenxinxin on 15/11/13.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "UPView.h"

@protocol UPImageViewJSExport <JSExport>
-(void)setSrc:(NSString*)spec;

-(void) playOnce;
-(void) playLoop;
@end

@interface UPImageView : UPView<UPImageViewJSExport>

@end
