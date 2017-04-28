//
//  UPLayoutParam.h
//  UPAppFramework
//
//  Created by chenxinxin on 15/11/12.
//  Copyright (c) 2015年 UPall. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UPLayout) {
    UPLayoutVertical,
    UPLayoutHorizontal,
    UPLayoutFrame
};

UPLayout UPLayoutFromString(NSString* spec);

typedef NS_OPTIONS(NSUInteger, UPGravity) {
    UPGravityNone               = 0,
    UPGravityLeft               = 1 << 0,
    UPGravityTop                = 1 << 1,
    UPGravityRight              = 1 << 2,
    UPGravityBottom             = 1 << 3,
    UPGravityCenterHorizontal   = 1 << 4,
    UPGravityCenterVertical     = 1 << 5,
    UPGravityCenter             = 1 << 6
};

UPGravity UPGravityFromString(NSString* spec);

typedef NS_ENUM(NSInteger, UPLayoutConstrain) {
    UPLayoutConstrainFill           = -1,
    UPLayoutConstrainMatch          = -2,
    UPLayoutConstrainWrap           = -3,
    UPLayoutConstrainMatchHeight    = -4,
    UPLayoutConstrainMatchWidth     = -5,
    UPLayoutConstrainNumber         = -6
};

UPLayoutConstrain UPLayoutConstrainFromString(NSString* spec);


@interface UPSpace : NSObject
@property (assign,nonatomic) float left;
@property (assign,nonatomic) float top;
@property (assign,nonatomic) float right;
@property (assign,nonatomic) float bottom;
-(void) setTRBL:(NSString*)spec;

-(float) hspace;
-(float) vspace;
@end


@interface UPLayoutParam : NSObject
@property (assign,nonatomic) enum UPLayout layout;
@property (assign,nonatomic) float width;
@property (assign,nonatomic) float widthWeight;
@property (assign,nonatomic) float height;
@property (assign,nonatomic) float heightWeight;
@property (strong,nonatomic) UPSpace* margin;
@property (strong,nonatomic) UPSpace* padding;
@property (assign,nonatomic) enum UPGravity gravity;
@property (assign,nonatomic) enum UPGravity contentGravity;
@end
