//
//  LDPassView.m
//  DMall
//
//  Created by chenxinxin on 2015-10-21.
//  Copyright (c) 2015 DMall. All rights reserved.
//

#import "DMPassView.h"

@implementation DMPassView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;  {
    for (UIView *subview in self.subviews)
    {
        if (subview.isHidden || !subview.isUserInteractionEnabled)
        {
            continue;
        }
        
        CGPoint subviewPoint = [self convertPoint:point toView:subview];
        if ([subview pointInside:subviewPoint withEvent:event])
        {
            return YES;
        }
    }
    return NO;
}

@end
