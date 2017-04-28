
//
//  DMNibView.m
//  DMall
//
//  Created by chenxinxin on 2015-10-21.
//  Copyright (c) 2015 ledai. All rights reserved.
//

#import "DMNibView.h"

@implementation DMNibView

-(id) init {
    if(self = [super init]) {
        [self loadNibViewAndFrame];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        if (frame.size.width == 0 || frame.size.height == 0) {
            [self loadNibViewAndFrame];
        } else {
            [self loadNibView];
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if(self = [super initWithCoder:decoder]) {
        [self loadNibView];
    }
    return self;
}

-(NSString*) nibFileName {
    return NSStringFromClass(self.class);
}

- (void) loadNibViewAndFrame {
    NSString* fileName = [self nibFileName];
    NSArray* nib = [[NSBundle mainBundle] loadNibNamed:fileName owner:self options:nil];
    if (nib.count == 0) {
        return;
    }
    UIView* view = [nib objectAtIndex:0];
    
    for (UIView* view in self.subviews) {
        [view removeFromSuperview];
    }
    self.frame = view.bounds;
    [self addSubview:view];
    [self nibViewDidLoad];
    
}

- (void) loadNibView {
    NSString* fileName = [self nibFileName];
    NSArray* nib = [[NSBundle mainBundle] loadNibNamed:fileName owner:self options:nil];
    if (nib.count == 0) {
        return;
    }
    UIView* view = [nib objectAtIndex:0];
    
    
    for (UIView* view in self.subviews) {
        [view removeFromSuperview];
    }
    view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:view];
    [self nibViewDidLoad];
}

-(void) layoutSubviews {
    if (self.subviews.count == 0) {
        return;
    }
    UIView* contentView = [self.subviews objectAtIndex:0];
    contentView.frame = self.bounds;
}

-(void) nibViewDidLoad {
}

@end
