//
//  UPLayoutParam.m
//  UPAppFramework
//
//  Created by chenxinxin on 15/11/12.
//  Copyright (c) 2015年 UPall. All rights reserved.
//

#import "UPLayoutParam.h"
#import "UPView.h"

@implementation UPSpace
-(void) setTRBL:(NSString*)spec {
    NSArray* components = [spec componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (components.count > 0) {
        self.top = [UPView parseSize:components[0]];
    } else {
        self.top = 0;
    }
    
    if (components.count > 1) {
        self.right = [UPView parseSize:components[1]];
    } else {
        self.right = self.top;
    }
    
    if (components.count > 2) {
        self.bottom = [UPView parseSize:components[2]];
    } else {
        self.bottom = self.right;
    }
    
    if (components.count > 3) {
        self.left = [UPView parseSize:components[3]];
    } else {
        self.left = self.bottom;
    }
}

-(float) hspace {
    return self.left + self.right;
}
-(float) vspace {
    return self.top + self.bottom;
}
@end

@implementation UPLayoutParam
-(instancetype) init {
    if(self = [super init]) {
        self.layout = UPLayoutFrame;
        self.width = UPLayoutConstrainFill;
        self.widthWeight = 1;
        self.height = UPLayoutConstrainFill;
        self.heightWeight = 1;
        self.margin = [[UPSpace alloc] init];
        self.padding = [[UPSpace alloc] init];
        self.gravity = UPGravityNone;
        self.contentGravity = UPGravityNone;
    }
    return self;
}
@end



UPLayout UPLayoutFromString(NSString* spec) {
    if ([@"frame" isEqualToString:spec]) {
        return UPLayoutFrame;
    } else if([@"vertical" isEqualToString:spec]) {
        return UPLayoutVertical;
    } else {
        return UPLayoutHorizontal;
    }
}

UPLayoutConstrain UPLayoutConstrainFromString(NSString* spec) {
    if ([@"fill" isEqualToString:spec]) {
        return UPLayoutConstrainFill;
    }
    
    if ([@"match" isEqualToString:spec]) {
        return UPLayoutConstrainMatch;
    }
    
    if ([@"wrap" isEqualToString:spec]) {
        return UPLayoutConstrainWrap;
    }
    
    if ([@"matchWidth" isEqualToString:spec]) {
        return UPLayoutConstrainMatchWidth;
    }
    
    if ([@"matchHeight" isEqualToString:spec]) {
        return UPLayoutConstrainMatchHeight;
    }
    return UPLayoutConstrainNumber;
}

UPGravity UPGravityElementFromString(NSString* spec) {
    if ([@"top" isEqualToString:spec]) {
        return UPGravityTop;
    }
    if ([@"right" isEqualToString:spec]) {
        return UPGravityRight;
    }
    if ([@"bottom" isEqualToString:spec]) {
        return UPGravityBottom;
    }
    if ([@"left" isEqualToString:spec]) {
        return UPGravityLeft;
    }
    if ([@"centerHorizontal" isEqualToString:spec]) {
        return UPGravityCenterHorizontal;
    }
    if ([@"centerVertical" isEqualToString:spec]) {
        return UPGravityCenterVertical;
    }
    if ([@"center" isEqualToString:spec]) {
        return UPGravityCenter;
    }
    
    return UPGravityNone;
}

UPGravity UPGravityFromString(NSString* spec) {
    UPGravity gravity = UPGravityNone;
    NSArray* words = [spec componentsSeparatedByString:@"|"];
    for (NSString* ele in words) {
        gravity |= UPGravityElementFromString(ele);
    }
    return gravity;
}
