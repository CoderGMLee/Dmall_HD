//
//  UPScrollView.h
//  DMAppFramework
//
//  Created by chris on 16/2/3.
//  Copyright © 2016年 dmall. All rights reserved.
//

#import "UPView.h"

@protocol UPScrollViewJSExport <NSObject>

- (void) setPageScrollEnable:(NSString*)spec;
- (void) setScrollContentWidth:(NSString*)spec;
- (void) setScrollContentHeight:(NSString *)spec;
- (void) setscrollTouchEdgeX:(NSString*)spec;


@end

@interface UPScrollView : UPView<UPScrollViewJSExport>


@end
