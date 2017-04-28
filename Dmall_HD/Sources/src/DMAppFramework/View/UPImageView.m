//
//  UPImageView.m
//  DMAppFramework
//
//  Created by chenxinxin on 15/11/13.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "UPImageView.h"
#import "DMGifView.h"
#import "DMWeakify.h"
#import "DMLog.h"

@interface UPImageView()
@property (strong,nonatomic) UIImageView* imageView;
@property (strong,nonatomic) DMGifView* gifView;
@property (assign,nonatomic) CGSize imageSize;
@property (assign,nonatomic) BOOL playOnceRequest;
@property (assign,nonatomic) BOOL playLoopRequest;
@end

@implementation UPImageView

@synthesize src = _src;


DMLOG_DEFINE(UPImageView)


-(NSArray*) subUPViews {
    return nil;
}

-(void) clearOldSubviews {
    for (UIView* view in self.subviews) {
        [view removeFromSuperview];
    }
}

-(BOOL) isGif:(NSData*) data {
    if (data == nil || data.length < 3) {
        return NO;
    }
    if(((char*)data.bytes)[0] == 'G'
       &&((char*)data.bytes)[1] == 'I'
       &&((char*)data.bytes)[2] == 'F'){
        return YES;
    }
    return NO;
}

-(void) setSrc:(NSString*) spec {
    self->_src = spec;
    NSString* resourcePath = [self.resourceLocator locateResource:spec];
    
    @weakify_self
    [self.resourceLoader loadResource:resourcePath callback:^(NSData *bytes) {
        @strongify_self
        
        if ([self isGif:bytes]) {
            self.gifView = [[DMGifView alloc] init];
            [self.gifView loadFromData:bytes];
            self.gifView.backgroundColor = [UPView parseColor:@"#00000000"];
            self.imageSize = self.gifView.imageSize;
            [self clearOldSubviews];
            [self addSubview:self.gifView];
            [self updateFrame];
            
            if (self.playOnceRequest) {
                [self.gifView playOnce];
            }
            if (self.playLoopRequest) {
                [self.gifView playLoop];
            }
            
        } else {
            self.imageView = [[UIImageView alloc] init];
            self.imageView.image =  [UIImage imageWithData:bytes];
            self.imageView.contentMode = UIViewContentModeScaleToFill;
            self.imageView.backgroundColor = [UPView parseColor:@"#00000000"];
            float dpWidth = self.imageView.image.size.width * self.imageView.image.scale / 3;
            float dpHeight = self.imageView.image.size.height * self.imageView.image.scale / 3;
            self.imageSize = CGSizeMake(dpWidth, dpHeight);
            [self clearOldSubviews];
            [self addSubview:self.imageView];
            [self updateFrame];

        }
    }];
}

-(void) updateFrame {
    UIView* view = self;
    while (view != nil) {
        [view setNeedsLayout];
        view = view.superview;
    }
   
    
   // DMDebug(@"image:%@ frame:%d,%d,%d,%d",self.src,(int)frame.origin.x,(int)frame.origin.y,(int)frame.size.width,(int)frame.size.height);
}

-(float) measureWidth {
    if (self.layoutParam.width == UPLayoutConstrainWrap) {
        if (self.imageSize.height > 0) {
            if (self.layoutParam.height == UPLayoutConstrainWrap) {
                return self.imageSize.width;
            } else {
                float rate = self.imageSize.width / self.imageSize.height;
                float mheight = [self measureHeight];
                return mheight * rate;
            }
        }
        return 0;
    }
    return [super measureWidth];
}

-(float) measureHeight {
    if (self.layoutParam.height == UPLayoutConstrainWrap) {
        if (self.imageSize.width > 0) {
            if (self.layoutParam.width == UPLayoutConstrainWrap) {
                return self.imageSize.height;
            } else {
                float rate = self.imageSize.height / self.imageSize.width;
                float mwidth = [self measureWidth];
                return mwidth * rate;
            }
        }
        return 0;
    }
    return [super measureHeight];
}

-(void) layoutSubviews {
    [super layoutSubviews];
    CGRect frame = CGRectMake(self.layoutParam.padding.left, self.layoutParam.padding.top, self.frame.size.width-self.layoutParam.padding.hspace, self.frame.size.height-self.layoutParam.padding.vspace);
    if (self.gifView != nil) {
        self.gifView.frame = frame;
    }
    if (self.imageView != nil) {
        self.imageView.frame = frame;
    }
}

-(void) playOnce {
    self.playOnceRequest = YES;
    if (self.gifView) {
        [self.gifView playOnce];
    }
}

-(void) playLoop {
    self.playLoopRequest = YES;
    if (self.gifView) {
        [self.gifView playLoop];
    }
}

@end
