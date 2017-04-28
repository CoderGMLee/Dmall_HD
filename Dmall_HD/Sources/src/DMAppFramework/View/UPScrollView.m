//
//  UPScrollView.m
//  DMAppFramework
//
//  Created by chris on 16/2/3.
//  Copyright © 2016年 dmall. All rights reserved.
//

#import "UPScrollView.h"

@interface UPScrollView ()<UIScrollViewDelegate>

@property(nonatomic, strong)    UIScrollView        *scrollView;

@property(nonatomic, assign)    CGFloat             contentWidth;
@property(nonatomic, assign)    CGFloat             contentHeight;
@property(nonatomic, assign)    CGFloat             touchEdgeX;

@property(nonatomic, strong)    NSMutableArray      *contentViews;

@end

@implementation UPScrollView

- (instancetype) init{
    
    if(self=[super init]){
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.delegate = self;
        [super addSubview:self.scrollView];
        
        self.contentViews = [NSMutableArray array];
    }
    
    return self;
}

- (void) setPageScrollEnable:(NSString *)spec{
    
    BOOL pageEnable = [UPView parseBoolean:spec];
    self.scrollView.pagingEnabled = pageEnable;
}


- (void) setScrollContentWidth:(NSString *)spec{
    
    self.contentWidth = [UPView parseSize:spec];
    self.scrollView.contentSize = CGSizeMake(self.contentWidth, self.scrollView.contentSize.height);
}

- (void) setScrollContentHeight:(NSString *)spec{
    
    self.contentHeight = [UPView parseSize:spec];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.contentHeight);
}

- (void) setscrollTouchEdgeX:(NSString *)spec{
    
    self.touchEdgeX = [UPView parseSize:spec];
}

- (void) addSubview:(UIView *)view{
    
    [self.scrollView addSubview:view];
    [self.contentViews addObject:view];
    
}

- (NSArray*) subUPViews{
    
    return self.contentViews;
}

- (void) layoutSubviews{
    
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
}

@end
