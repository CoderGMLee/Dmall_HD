//
//  UPTextView.m
//  DMAppFramework
//
//  Created by chenxinxin on 15/11/13.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "UPTextView.h"

#import <UIKit/UIKit.h>

@interface UPTextView()

@property (strong,nonatomic) UILabel* mLabelView;
@property (assign,nonatomic) float mMaxWidthValue;
@property (assign,nonatomic) float mFontSize;
@end

@implementation UPTextView

-(instancetype) init {
    if (self = [super init]) {
        self.mMaxWidthValue = -1;
        self.mLabelView = [[UILabel alloc] init];
        self.mLabelView.numberOfLines = 10240;
        self.mFontSize = [UPView parseSize:@"18dp"];
        self.mLabelView.font = [UIFont systemFontOfSize:self.mFontSize];
        self.mLabelView.textColor = [UPView parseColor:@"#000000"];
        self.backgroundColor = [UPView parseColor:@"#00FFFFFF"];
        [self addSubview:self.mLabelView];
    }
    return self;
}

-(NSArray*) subUPViews {
    return nil;
}


-(void) setContentGravity:(NSString*) spec {
    [super setContentGravity:spec];
    if ( (self.layoutParam.contentGravity & UPGravityLeft) != 0) {
        self.mLabelView.textAlignment = NSTextAlignmentLeft;
    } else if((self.layoutParam.contentGravity & UPGravityRight) != 0) {
        self.mLabelView.textAlignment = NSTextAlignmentRight;
    } else if((self.layoutParam.contentGravity & UPGravityCenterHorizontal) != 0
              ||(self.layoutParam.contentGravity & UPGravityCenter) != 0
              ){
        self.mLabelView.textAlignment = NSTextAlignmentCenter;
    } else {
        self.mLabelView.textAlignment = NSTextAlignmentLeft;
    }
}

-(void) setMaxWidth:(NSString*) spec {
    self.mMaxWidthValue = [UPView parseSize:spec];
}

-(void) setFontColor:(NSString*) spec {
    self.mLabelView.textColor = [UPView parseColor:spec];
}

-(void) setFontSize:(NSString*) spec {
    self.mFontSize = [UPView parseSize:spec];
    self.mLabelView.font = [UIFont fontWithName:self.mLabelView.font.fontName size:self.mFontSize];
}

-(void) setFontBold:(NSString*) spec {
    if ([@"true" isEqualToString:spec]) {
        self.mLabelView.font = [UIFont boldSystemFontOfSize:self.mFontSize];
    } else {
        self.mLabelView.font = [UIFont systemFontOfSize:self.mFontSize];
    }
}


-(float) measureWidth {
    if (self.layoutParam.width == UPLayoutConstrainWrap) {
        CGSize size = [self.mLabelView sizeThatFits:CGSizeMake(10240, 10240)];
        size.width += self.layoutParam.padding.hspace;
        if (size.width > self.mMaxWidthValue && self.mMaxWidthValue > 0) {
            return self.mMaxWidthValue;
        }
        return size.width;
    }
    return [super measureWidth];
}

-(float) measureHeight {
    if (self.layoutParam.height == UPLayoutConstrainWrap) {
        CGSize size = [self.mLabelView sizeThatFits:CGSizeMake([self measureWidth]-self.layoutParam.padding.hspace, 10240)];
        size.height += self.layoutParam.padding.vspace;
        return size.height;
    }
    return [super measureHeight];
}

-(void) setText:(NSString*) text {
    self.mLabelView.text = text;
    [self requestLayout];
}

-(NSString*) getText {
    return self.mLabelView.text;
}

-(NSString*) text {
    return self.mLabelView.text;
}

-(void) setMaxLines:(NSString*) spec {
    self.mLabelView.numberOfLines = [spec integerValue];
}

-(void) layoutSubviews {
    if (self.mLabelView != nil) {
        float width = [self measureWidth];
        float height = [self measureHeight];
        CGSize size = [self.mLabelView sizeThatFits:CGSizeMake(width-self.layoutParam.padding.hspace, 102400)];
        CGRect frame = CGRectMake(self.layoutParam.padding.left, self.layoutParam.padding.top, width-self.layoutParam.padding.hspace, size.height);
        if ((self.layoutParam.contentGravity&UPGravityTop)!=0) {
            frame.origin.y = self.layoutParam.padding.top;
        } else if ((self.layoutParam.contentGravity&UPGravityBottom)!=0) {
            frame.origin.y = height - self.layoutParam.padding.bottom - size.height;
        } else if ((self.layoutParam.contentGravity&UPGravityCenterVertical)!=0
                   || (self.layoutParam.contentGravity&UPGravityCenter)!=0
                   ) {
            frame.origin.y = self.layoutParam.padding.top + (height - self.layoutParam.padding.vspace - size.height) / 2;
        } else {
            frame.origin.y = self.layoutParam.padding.top;
        }
        self.mLabelView.frame = frame;
    }
}


@end
