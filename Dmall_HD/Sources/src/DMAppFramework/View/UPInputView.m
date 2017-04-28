//
//  UPInputView.m
//  DMAppFramework
//
//  Created by chenxinxin on 15/11/13.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "UPInputView.h"

@interface UPInputView()
@property (strong,nonatomic) UITextField* mTextField;
@property (assign,nonatomic) float mFontSize;
@property (strong,nonatomic) NSString* mType;
@end

@implementation UPInputView

-(instancetype) init {
    if(self = [super init]) {
        self.mTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        self.mTextField.placeholder = @"";
        self.mFontSize = [UPView parseSize:@"18dp"];
        self.mTextField.font = [UIFont systemFontOfSize:self.mFontSize];
        [self.mTextField setBorderStyle:UITextBorderStyleNone];
        self.mType = @"text";
        [self addSubview:self.mTextField];
    }
    return self;
}

-(NSArray*) subUPViews {
    return nil;
}


-(void) setPlaceholder:(NSString*)placeholder {
    self.mTextField.placeholder = placeholder;
}
-(NSString*) getPlaceholder {
    return self.mTextField.placeholder;
}
-(void) setPlaceholderColor:(NSString*)spec {
    [self.mTextField setValue:[UPView parseColor:spec] forKeyPath:@"_placeholderLabel.textColor"];
}

-(void) setText:(NSString *)text {
    self.mTextField.text = text;
}

-(NSString*) getText {
    return self.mTextField.text;
}

-(void) setType:(NSString*) spec {
    self.mType = spec;
    if ([@"text" isEqualToString:spec]) {
        self.mTextField.keyboardType = UIKeyboardTypeDefault;
        return;
    }
    
    if ([@"number" isEqualToString:spec]) {
        self.mTextField.keyboardType = UIKeyboardTypeNumberPad;
    }
    
    if ([@"email" isEqualToString:spec]) {
        self.mTextField.keyboardType = UIKeyboardTypeEmailAddress;
    }
    
    if ([@"password" isEqualToString:spec]) {
        self.mTextField.keyboardType = UIKeyboardTypeDefault;
        self.mTextField.secureTextEntry = YES;
    }
}

-(NSString*) getType {
    return self.mType;
}


-(void) setFontColor:(NSString*) spec {
    self.mTextField.textColor = [UPView parseColor:spec];
}

-(void) setFontSize:(NSString*) spec {
    self.mFontSize = [UPView parseSize:spec];
    self.mTextField.font = [UIFont fontWithName:self.mTextField.font.fontName size:self.mFontSize];
}

-(void) setFontBold:(NSString*) spec {
    if ([@"true" isEqualToString:spec]) {
        self.mTextField.font = [UIFont boldSystemFontOfSize:self.mFontSize];
    } else {
        self.mTextField.font = [UIFont systemFontOfSize:self.mFontSize];
    }
}

-(void) layoutSubviews {
    CGRect frame = self.bounds;
    self.mTextField.frame = CGRectMake(self.layoutParam.padding.left, self.layoutParam.padding.top, frame.size.width - self.layoutParam.padding.hspace, frame.size.height-self.layoutParam.padding.vspace);
}

@end
