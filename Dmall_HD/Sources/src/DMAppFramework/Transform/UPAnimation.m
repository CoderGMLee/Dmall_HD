//
//  UPAnimation.m
//  DMAppFramework
//
//  Created by chris on 16/1/29.
//  Copyright © 2016年 dmall. All rights reserved.
//

#import "UPAnimation.h"

@implementation UPAnimation

+ (void) animationView:(UIView *)view withConfig:(UPAnimationConfig *)config{
    
    NSString *keyPath = [self animationKeyPath:config];
    if(!keyPath)    return;
    
    NSValue *toValue = [self toValue:config inView:view];
    if(!toValue)    return;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.duration = config.duration;
    animation.toValue = toValue;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;

    [view.layer addAnimation:animation forKey:config.animationType];
    
}

+ (NSString*) animationKeyPath:(UPAnimationConfig*)config{
    
    NSString *keyPath = nil;
    if([config.animationType isEqualToString:@"position"]){
        keyPath = @"position";
    }
    else if([config.animationType isEqualToString:@"scale"]){
        keyPath = @"transform";
    }
    else if([config.animationType isEqualToString:@"rotate"]){
        keyPath = @"transform";
    }
    
    return keyPath;
}

+ (NSValue*) toValue:(UPAnimationConfig*)config inView:(UIView*)view{
    
    NSValue *toValue = nil;
    if([config.animationType isEqualToString:@"position"]){
        CGFloat x = [config.position[@"x"] floatValue];
        CGFloat y = [config.position[@"y"] floatValue];
        CGPoint position = view.layer.position;
        position.x += x;
        position.y += y;
        toValue = [NSValue valueWithCGPoint:position];
    }
    else if([config.animationType isEqualToString:@"scale"]){
        CGFloat sx = [config.size[@"width"] floatValue];
        CGFloat sy = [config.size[@"height"] floatValue];
        CATransform3D transform = CATransform3DScale(view.layer.transform, sx, sy, 1.0);
        toValue = [NSValue valueWithCATransform3D:transform];
    }
    else if([config.animationType isEqualToString:@"rotate"]){
        int axis[] = {0,0,0};
        NSDictionary *indexMap = @{@"x":@"0",@"y":@"1",@"z":@"2"};
        int index = [indexMap[config.axis] intValue];
        axis[index] = 1;
        
        CATransform3D transform = CATransform3DRotate(view.layer.transform, config.angle, axis[0], axis[1], axis[2]);
//        CATransform3D transform = CATransform3DMakeRotation(config.angle, axis[0], axis[1], axis[2]);
        toValue = [NSValue valueWithCATransform3D:transform];
    }

    return toValue;
}

@end
