//
//  UPAnimationConfig.m
//  DMAppFramework
//
//  Created by chris on 16/1/29.
//  Copyright © 2016年 dmall. All rights reserved.
//

#import "UPAnimationConfig.h"

@implementation UPAnimationConfig

@synthesize duration;
@synthesize position;
@synthesize size;
@synthesize angle;
@synthesize axis;

@synthesize animationType;

+ (UPAnimationConfig*) animationConfig{
    
    UPAnimationConfig *config = [[UPAnimationConfig alloc] init];
    return config;
}

@end
