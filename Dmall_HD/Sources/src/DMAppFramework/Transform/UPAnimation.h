//
//  UPAnimation.h
//  DMAppFramework
//
//  Created by chris on 16/1/29.
//  Copyright © 2016年 dmall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UPAnimationConfig.h"

@interface UPAnimation : NSObject

+ (void) animationView:(UIView*)view withConfig:(UPAnimationConfig*)config;

@end
