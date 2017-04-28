//
//  DMTableViewCell.m
//  DMAppFramework
//
//  Created by chenxinxin on 15/11/30.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "DMResizableTableViewCell.h"

@interface DMResizableTableViewCell()
@property (strong,nonatomic) UIView* rootView;

@end

@implementation DMResizableTableViewCell


-(void) setRootView:(UIView*)rootView {
    self->_rootView = rootView;
    [self.contentView addSubview:rootView];
}

-(void) layoutSubviews {
    [super layoutSubviews];
    self.rootView.frame = self.bounds;
}



@end
