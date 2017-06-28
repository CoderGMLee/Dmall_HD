//
//  DMNibController.m
//  DMAppFramework
//
//  Created by chenxinxin on 15/11/3.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "DMNibController.h"
#import "DMLog.h"
#import "Dmall_HD-Swift.h"
@implementation DMNibController

DMLOG_DEFINE(DMNibController)

-(NSBundle*) nibFileBundle {
    return [NSBundle mainBundle];
}

-(NSString*) nibFileName {
    return NSStringFromClass(self.class);
}

-(NSArray*) loadNibs:(NSString*)fileName bundle:(NSBundle*)bundle {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[bundle pathForResource:fileName ofType:@"nib"]]
        ) {
        return [bundle loadNibNamed:fileName owner:self options:nil];
    } else {
        DMWarn(@"[Warn] can't load nib file %@ in main bundle",fileName);
    }
    return nil;
}

- (void) loadView {

    MinePage * minePage = [[MinePage alloc] init];
    NSString * className = NSStringFromClass([minePage class]);
    NSLog(@"name : %@",className);


    NSString* fileName  = [self nibFileName];
    NSArray* nib        = [self loadNibs:fileName bundle:[self nibFileBundle]];
    if (nib == nil || nib.count == 0) {
        [super loadView];
        return;
    }
    UIView* view  = [nib objectAtIndex:0];
    view.frame    = [UIScreen mainScreen].bounds;
    [view setNeedsLayout];
    self.view     = view;
}

@end
