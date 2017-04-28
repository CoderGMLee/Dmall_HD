//
//  UPView.m
//  UPAppFramework
//
//  Created by chenxinxin on 15/11/12.
//  Copyright (c) 2015年 UPall. All rights reserved.
//

#import "UPView.h"
#import "UPPageViewLoader.h"
#import "UPBundleLoader.h"
#import "UPViewParser.h"
#import "UPPathUtil.h"
#import "DMStringUtils.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <objc/runtime.h>
#import "DMNavigator.h"
#import "DMBridgeHelper.h"
#import "UPView+Private.h"
#import "DMJSPageBridge.h"
#import "DMUrlEncoder.h"
#import "DMLog.h"
#import "DMPage.h"
#import "UPAnimation.h"
#import "DMNetwork.h"
#import "UPAnimationConfig.h"

@interface UPViewPageBridge : NSObject <DMJSPageBridgeJSExport>
@end

@implementation UPViewPageBridge
-(void) forward:(NSString*)url {
    [[DMNavigator getInstance] forward:url callback:^(NSDictionary *param) {
        NSString* str = [DMUrlEncoder encodeParams:param];
        [UPView evaluate:[NSString stringWithFormat:@"com.dmall.Bridge.appPageCallback(\"%@\")",str]];
    }];
}
-(void) backward:(NSString*)param {
    [[DMNavigator getInstance] backward:param];
}
-(void) pushFlow {
    [[DMNavigator getInstance] pushFlow];
}
-(void) popFlow:(NSString*)param {
    [[DMNavigator getInstance] popFlow:param];
}
-(void) callback:(NSString*)param {
    [[DMNavigator getInstance] callback:param];
}
-(void) registRedirect:(NSString*)fromUrl :(NSString*)toUrl {
    [DMNavigator registRedirectFromUrl:fromUrl toUrl:toUrl];
}
-(NSString*) topPage:(int)deep {
    return [((DMPage*)[[DMNavigator getInstance] topPage:deep]) pageUrl];
}
-(void) rollup {
    [[DMNavigator getInstance] rollup];
}

-(void) httpGet:(NSString*)requestId :(NSString*)url :(NSDictionary*)headers {
    
}

-(void) httpPost:(NSString*)requestId :(NSString*)url :(NSDictionary*)headers :(NSString*)body {
    NSLog(@"request Recived:%@ url:%@",requestId,url);
    for (NSString* key in headers) {
        NSLog(@"header key:%@ value:%@",key,[headers objectForKey:key]);
    }
    NSLog(@"body:%@",body);
    
    [DMNetwork doPostWithUrl:url headers:headers body:body callback:^(NSInteger statusCode, NSString *result) {
        NSString *code = [NSString stringWithFormat:@"%d",(int)statusCode];
        [self httpCallback:requestId :code :result];
    }];
    
}
-(void) httpCallback:(NSString*)requestId :(NSString*)statusCode :(NSString*)data {
    NSString* str = [DMUrlEncoder escape:data];
    [UPView evaluate:[NSString stringWithFormat:@"com.dmall.Network.httpCallback(\"%@\",\"%@\",\"%@\")",requestId,statusCode,str]];
}
-(void) httpCancel:(NSString*)requestId {
    NSLog(@"request Cancel:%@ ",requestId);
}
@end

@interface UPView()
@property (assign,nonatomic) BOOL mGone;
@property (strong,nonatomic) UIImage* backgroundImage;
@property (strong,nonatomic) UITapGestureRecognizer* tapGestureRecognizer;
@property (strong,nonatomic) NSString* jsOnClickMethod;
@property (strong,nonatomic) NSString* jsOnDoubleClickMethod;
@property (strong,nonatomic) JSValue* jsPageObject;
@property (strong,nonatomic) NSString* jsPageObjectName;
@property (strong,nonatomic) JSValue* jsPageData;
@property (strong,nonatomic) NSMutableDictionary* populateParams;
@property (strong,nonatomic) NSMutableDictionary* params;
@property (assign,nonatomic) NSTimeInterval lastClickTime;
@end

@implementation UPView

DMLOG_DEFINE(UPView)

JSContext* UPView_globalJSContext;
long long UPView_viewCount = 0;

-(instancetype) init {
    if(self = [super init]) {
        self.mGone = NO;
        self.autoresizingMask = UIViewAutoresizingNone;
        [self setBackground:@"#00000000"];
    }
    return self;
}

+(NSString*) getVersion {
    return UPVIEW_VERSION;
}

-(JSValue*) getPage {
    NSArray* subUPViews = [self subUPViews];
    if (subUPViews != nil && subUPViews.count > 0) {
        return ((UPView*)subUPViews[0]).jsPageObject;
    }
    return nil;
}

- (void) startAnimation:(UPAnimationConfig *)config{
    [UPAnimation  animationView:self withConfig:config];
}


-(id) deepClone {
    Class clazz = [self class];
    UPView* copy = [[clazz alloc] init];
    copy.resourceLoader = self.resourceLoader;
    copy.resourceLocator = self.resourceLocator;
    for (NSString* param in self.params) {
        [copy injectValue:[self.params objectForKey:param] forProperty:param];
    }
    for (UPView* view in self.subUPViews) {
        UPView* subCopy = [view deepClone];
        [copy addSubview:subCopy];
    }
    return copy;
}

-(NSMutableDictionary*) params {
    if (self->_params == nil) {
        self->_params = [[NSMutableDictionary alloc] init];
    }
    return self->_params;
}

-(NSMutableDictionary*) populateParams {
    if (self->_populateParams == nil) {
        self->_populateParams = [[NSMutableDictionary alloc] init];
    }
    return self->_populateParams;
}


-(NSString*) getId {
    return self.id;
}

-(NSString*) getGid {
    return self.gid;
}

-(void) setVisible:(NSString*)spec {
    if ([UPView parseBoolean:spec]) {
        self.hidden = NO;
    } else {
        self.hidden = YES;
    }
}

-(void) setGone:(NSString*)spec {
    if ([UPView parseBoolean:spec]) {
        self.mGone = YES;
        self.hidden = YES;
    } else {
        self.mGone= NO;
        self.hidden = NO;
    }
    [self notifyLayout];
}

-(void) notifyLayout {
    UIView* view = self;
    while (view != nil) {
        [view setNeedsLayout];
        view = view.superview;
    }
}

-(void) requestLayout {
    [self notifyLayout];
}

-(BOOL) isGone {
    return self.mGone;
}

-(BOOL) isVisible {
    return !self.hidden;
}

+(JSContext*) globalJSContext {
    if (UPView_globalJSContext == nil) {
        UPView_globalJSContext = [[JSContext alloc] init];
        UPView_globalJSContext.exceptionHandler = ^(JSContext *con, JSValue *exception) {
            DMError(@"%@", exception);
            con.exception = exception;
        };
        UPView_globalJSContext[@"log"] = ^() {
            DMDebug(@"+++++++Begin JS Log+++++++");
            
            NSArray *args = [JSContext currentArguments];
            for (JSValue *jsVal in args) {
                DMDebug(@"%@", jsVal);
            }
            
            JSValue *this = [JSContext currentThis];
            DMDebug(@"this: %@",this);
            DMDebug(@"-------End JS Log-------");
        };
        
        UPView_globalJSContext[@"decodeURI"] = (JSValue*)^() {
            NSArray *args = [JSContext currentArguments];
            if (args != nil && args.count > 0) {
                NSString* arg = [args[0] description];
                NSString* darg = [DMUrlEncoder unescape:arg];
                return [JSValue valueWithObject:darg inContext:[UPView globalJSContext]];
            }
            return (JSValue*)nil;
        };
        
        UPView_globalJSContext[@"encodeURI"] = (JSValue*)^() {
            NSArray *args = [JSContext currentArguments];
            if (args != nil && args.count > 0) {
                NSString* arg = [args[0] description];
                NSString* darg = [DMUrlEncoder escape:arg];
                return [JSValue valueWithObject:darg inContext:[UPView globalJSContext]];
            }
            return (JSValue*)nil;
        };
        
//        UPView_globalJSContext[@"testX"] = (JSValue*)^(){
//            DMDebug(@"testX called");
//        };
    }
    return UPView_globalJSContext;
}

-(NSString*) evaluateScript:(NSString*) script {
    JSValue* value = [UPView evaluate:script];
    return [value toString];
}


+(JSValue*) evaluate : (NSString*) script {
    return [[UPView globalJSContext] evaluateScript:script];
}

-(void) runEntryJSFunction:(NSString*)entryName{
    UPView_viewCount++;
    self.jsPageObjectName = [NSString stringWithFormat:@"__upview_%lld",UPView_viewCount];
    NSString* scriptWithInstance = [NSString stringWithFormat:@"%@={}",self.jsPageObjectName];
    self.jsPageObject = [UPView evaluate:scriptWithInstance];
    [self injectViewsToJSPageObject:self.jsPageObject withName:self.jsPageObjectName];
    [self injectPopulateMethod:self.jsPageObject];
    [UPView evaluate:[NSString stringWithFormat:@"%@(%@)",entryName,self.jsPageObjectName]];
}


-(void) injectPopulateMethod:(JSValue*) context {
    context[@"populate"] = ^(){
        DMDebug(@"+++++++Begin Populate Log+++++++");
        
        NSArray *args = [JSContext currentArguments];
        for (JSValue *jsVal in args) {
            [self populatePageData:jsVal];
        }
    };
}

-(NSArray*) subUPViews {
    return self.subviews;
}

-(void) populatePageData:(JSValue*) value {
    self.jsPageData = value;
    for (NSString* property in self.populateParams) {
        NSString* expression = [self.populateParams objectForKey:property];
        JSValue* jsValue = [self getValueFromJSObject:value byExpression:expression];
        if (jsValue != nil) {
            [self injectValue:[jsValue toString] forProperty:property];
        }
    }
    if (self.src != nil && [@"UPView" isEqualToString:NSStringFromClass([self class])]) {
        // 防止注入到引用的文件里
        return;
    }
    for (UIView* view in self.subviews) {
        if ([view isKindOfClass:[UPView class]]) {
            [((UPView*)view) populatePageData:value];
        }
    }
}

-(JSValue*) findContextPageData {
    if (self.jsPageData != nil) {
        return self.jsPageData;
    }
    return [[self superUPView] findContextPageData];
}

-(NSString*) genGlobalName:(JSValue*) value {
    JSValue* window = [UPView evaluate:@"window"];
    NSString* name = @"__temp__obj__";
    window[name] = value;
    return [NSString stringWithFormat:@"window.%@",name];
}

-(JSValue*) getValueFromJSObject:(JSValue*) value byExpression:(NSString*)expression {
    NSString* objName = [self genGlobalName:value];
    NSString* exp = [NSString stringWithFormat:@"%@.%@",objName,expression];
    JSValue* ret = [UPView evaluate:exp];
    [UPView evaluate:[NSString stringWithFormat:@"%@=null",objName]];
    return ret;
}

-(void) setValue:(id)value byKey:(NSString*)name forJSObject:(JSValue*)obj {
    NSRange arrayStart = [name rangeOfString:@"["];
    if (arrayStart.location != NSNotFound) {
        NSRange arrayStop = [name rangeOfString:@"]"];
        if (arrayStop.location != NSNotFound && arrayStart.location > 0) {
            NSString* property = [name substringToIndex:arrayStart.location];
            int index = [[name substringWithRange:NSMakeRange(arrayStart.location+1, arrayStop.location - arrayStart.location - 1)] intValue];
            JSValue* ret = [obj valueForProperty:property];
            if ([ret isUndefined]) {
                ret = [JSValue valueWithNewObjectInContext:[UPView globalJSContext]];
                [obj setValue:ret forProperty:property];
            }
            [ret setValue:value atIndex:index];
            return;
        }
    }
    
    obj[name] = value;
}


-(void) injectViewsToJSPageObject:(JSValue*) jsPageObject withName:(NSString*)jsPageObjectName {
    if (self->_jsPageObject != nil && self->_jsPageObject != jsPageObject) {
        // 如果当前View自己有上下文，则无需再次注册，因为它肯定是include进来的View,自己有局部作用域控制。
        return;
    }
    if (self.id != nil) {
        [self setValue:self byKey:self.id forJSObject:jsPageObject];
//        jsPageObject[self.id] = self;
//        if(self.src != nil) {
//            // 为include的View对象赋值
//            NSString* asignScript = [NSString stringWithFormat:@"%@.%@=%@",jsPageObjectName,self.id,((UPView*)self.subUPViews[0]).jsPageObjectName];
//            [[UPView globalJSContext] evaluateScript:asignScript];
//        }
    }
    for (UIView* view in self.subUPViews) {
        if ([view isKindOfClass:[UPView class]]) {
            [((UPView*)view) injectViewsToJSPageObject:jsPageObject withName:jsPageObjectName];
        }
    }
}


-(DMNavigator*) navigator {
    UIResponder* parent = self.nextResponder;
    while (parent != nil && ![parent isKindOfClass:[DMNavigator class]]) {
        parent = parent.nextResponder;
    }
    if ([parent isKindOfClass:[DMNavigator class]]) {
        return (DMNavigator*)parent;
    }
    return nil;
}


-(UPLayoutParam*) layoutParam {
    if (self->_layoutParam == nil) {
        self->_layoutParam = [[UPLayoutParam alloc] init];
    }
    return self->_layoutParam;
}



-(void) injectValue:(NSString*)value forProperty:(NSString*)name {
    // 如果包含表达式，会同时被加入params和populateParams， 此后如果再复制表达式的字段将不会再放入params
    // 因为params被用于实现deepClone，包含表达式的字段不能被替换，否则会出问题。
    if ([self.populateParams objectForKey:name] == nil) {
        [self.params setObject:value forKey:name];
    }
    
    if ([value hasPrefix:@"${"] && [value hasSuffix:@"}"]) {
        // 包含变量引用的部分延迟在js调用populate时确定值
        [self.populateParams setObject:[value substringWithRange:NSMakeRange(2,value.length-3)] forKey:name];
        return;
    }
    
    if ([self respondsToSelector:NSSelectorFromString([NSString stringWithFormat:@"set%@:",[DMStringUtils firstToUpper:name]])]) {
        [self setValue:value forKey:name];
    }
}


-(UPView*) superUPView {
    UIView* superView = self.superview;
    while (superView != nil && ![superView isKindOfClass:[UPView class]]) {
        superView = superView.superview;
    }
    if ([superView isKindOfClass:[UPView class]]) {
        return (UPView*)superView;
    }
    return nil;
}

-(float) measureContentWidth {
    if(self.mGone){
        return 0;
    }
    return [self measureWidth] - self.layoutParam.padding.hspace;
}

-(float) measureBoxWidth {
    if(self.mGone){
        return 0;
    }
    return [self measureWidth] + self.layoutParam.margin.hspace;
}

-(float) measureWidth {
    if (self.mGone) {
        return 0;
    }
    
    if (self.layoutParam.width == UPLayoutConstrainMatch) {
        if (self.superUPView == nil) {
            return self.frame.size.width;
        }
        return [self.superUPView measureContentWidth] * self.layoutParam.widthWeight;
    }
    
    if (self.layoutParam.width == UPLayoutConstrainFill) {
        if (self.superUPView == nil) {
            return self.frame.size.width;
        }
        if (self.superUPView.layoutParam.layout == UPLayoutFrame
            ||  self.superUPView.layoutParam.layout == UPLayoutVertical
            ){
            return [self.superUPView measureContentWidth] - self.layoutParam.margin.hspace;
        }
        
        // it has to be horizontal
        float totalWidth = [self.superUPView measureContentWidth];
        float fixedWidth = 0;
        float totalWeight = 0;
        for (int i = 0 ; i < self.superUPView.subUPViews.count; i++) {
            UPView* subview = self.superUPView.subUPViews[i];
            if(subview.isGone) {
                continue;
            }
            if (subview.layoutParam.width == UPLayoutConstrainFill) {
                totalWeight += subview.layoutParam.widthWeight;
            } else {
                fixedWidth += [subview measureBoxWidth];
            }
        }
        return (totalWidth - fixedWidth) * self.layoutParam.widthWeight / totalWeight - self.layoutParam.margin.hspace;
    }
    
    if (self.layoutParam.width == UPLayoutConstrainWrap) {
        float mwidth = 0;
        if (self.layoutParam.layout == UPLayoutFrame
            || self.layoutParam.layout == UPLayoutVertical) {
            bool widthCalculated = false;
            for (int i = 0 ; i < self.subUPViews.count; i++) {
                UPView* subview = (UPView*)self.subUPViews[i];
                if (subview.layoutParam.width != UPLayoutConstrainFill
                    && subview.layoutParam.width != UPLayoutConstrainMatch) {
                    float boxWidth = [subview measureBoxWidth];
                    widthCalculated = true;
                    if (boxWidth > mwidth) {
                        mwidth = boxWidth;
                    }
                }
            }
            
            if (!widthCalculated) {
                DMError(@"宽度布局错误，出现循环依赖.");
            }
            return mwidth + self.layoutParam.padding.hspace;
        }
        
        // it has to be horizontal
        for (int i = 0 ; i < self.subUPViews.count; i++) {
            UPView* subview = self.subUPViews[i];
            if (subview.layoutParam.width != UPLayoutConstrainFill
                && subview.layoutParam.width != UPLayoutConstrainMatch) {
                float boxWidth = [subview measureBoxWidth];
                mwidth += boxWidth;
            } else {
                DMError(@"宽度布局错误，出现循环依赖.");
            }
        }
        return mwidth + self.layoutParam.padding.hspace;
    }
    
    if (self.layoutParam.width == UPLayoutConstrainMatchHeight) {
        float mheight = [self measureHeight];
        return mheight * self.layoutParam.widthWeight;
    }
    
    return self.layoutParam.width;
}


-(float) measureHeight {
    if (self.mGone) {
        return 0;
    }
    
    if (self.layoutParam.height == UPLayoutConstrainMatch) {
        if (self.superUPView == nil) {
            return self.frame.size.height;
        }
        return [self.superUPView measureContentHeight] * self.layoutParam.heightWeight;
    }
    
    if (self.layoutParam.height == UPLayoutConstrainFill) {
        if (self.superUPView == nil) {
            return self.frame.size.height;
        }
        if (self.superUPView.layoutParam.layout == UPLayoutFrame
            || self.superUPView.layoutParam.layout == UPLayoutHorizontal) {
            return [self.superUPView measureContentHeight] - self.layoutParam.margin.vspace;
        }
        // it has to be vertical
        float totalHeight = [self.superUPView measureContentHeight];
        float fixedHeight = 0;
        float totalWeight = 0;
        for (int i = 0 ; i < self.superUPView.subUPViews.count; i++) {
            UPView* subview = (UPView*)self.superUPView.subUPViews[i];
            if (subview.isGone) {
                continue;
            }
            if (subview.layoutParam.height == UPLayoutConstrainFill) {
                totalWeight += subview.layoutParam.heightWeight;
            } else {
                fixedHeight += [subview measureBoxHeight];
            }
        }
        return (totalHeight - fixedHeight) * self.layoutParam.heightWeight / totalWeight - self.layoutParam.margin.vspace;
    }
    
    if (self.layoutParam.height == UPLayoutConstrainWrap) {
        float mheight = 0;
        if (self.layoutParam.layout == UPLayoutFrame
            || self.layoutParam.layout == UPLayoutHorizontal) {
            BOOL heightCalculated = false;
            for (int i = 0; i < self.subUPViews.count; i++) {
                UPView* subview = self.subUPViews[i];
                if (subview.layoutParam.height != UPLayoutConstrainFill
                    && subview.layoutParam.height != UPLayoutConstrainMatch) {
                    float boxHeight = [subview measureBoxHeight];
                    heightCalculated = true;
                    if (boxHeight > mheight) {
                        mheight = boxHeight;
                    }
                }
            }
            if (!heightCalculated) {
                DMError(@"高度布局错误，出现循环依赖");
            }
            return mheight + self.layoutParam.padding.vspace;
        }
        // it has to be vertical
        for (int i = 0; i < self.subUPViews.count; i++) {
            UPView* subview = self.subUPViews[i];
            if (subview.layoutParam.height != UPLayoutConstrainFill
                && subview.layoutParam.height != UPLayoutConstrainMatch
                ) {
                float boxHeight = [subview measureBoxHeight];
                mheight += boxHeight;
            } else {
                DMError(@"高度布局错误，出现循环依赖");
            }
        }
        return mheight + self.layoutParam.padding.vspace;
    }
    
    if (self.layoutParam.height == UPLayoutConstrainMatchWidth) {
        float mwidth = [self measureWidth];
        return mwidth * self.layoutParam.heightWeight;
    }
    
    return self.layoutParam.height;
}

-(float) measureContentHeight {
    if(self.mGone){
        return 0;
    }
    return [self measureHeight] - self.layoutParam.padding.vspace;
}

-(float) measureBoxHeight {
    if(self.mGone){
        return 0;
    }
    return [self measureHeight] + self.layoutParam.margin.vspace;
}


-(BOOL) isAlignLeft {
    if ((self.layoutParam.gravity & UPGravityLeft) != 0) {
        return true;
    }
    if ((self.layoutParam.gravity & UPGravityRight) != 0
        || (self.layoutParam.gravity & UPGravityCenterHorizontal) != 0
        || (self.layoutParam.gravity & UPGravityCenter) != 0
        ) {
        return false;
    }
    UPView* superView = self.superUPView;
    if (superView == nil) {
        return true;
    }
    if ((superView.layoutParam.contentGravity & UPGravityLeft) != 0) {
        return true;
    }
    if ((superView.layoutParam.contentGravity & UPGravityRight) != 0
        || (superView.layoutParam.contentGravity & UPGravityCenterHorizontal) != 0
        || (superView.layoutParam.contentGravity & UPGravityCenter) != 0
        ) {
        return false;
    }
    return true;
}

-(BOOL) isAlignTop {
    if ((self.layoutParam.gravity & UPGravityTop) != 0) {
        return true;
    }
    if ((self.layoutParam.gravity & UPGravityBottom) != 0
        || (self.layoutParam.gravity & UPGravityCenterVertical) != 0
        || (self.layoutParam.gravity & UPGravityCenter) != 0
        ) {
        return false;
    }
    UPView* superView = self.superUPView;
    if (superView == nil) {
        return true;
    }
    if ((superView.layoutParam.contentGravity & UPGravityTop) != 0) {
        return true;
    }
    if ((superView.layoutParam.contentGravity & UPGravityBottom) != 0
        || (superView.layoutParam.contentGravity & UPGravityCenterVertical) != 0
        || (superView.layoutParam.contentGravity & UPGravityCenter) != 0
        ) {
        return false;
    }
    return true;
}

-(BOOL) isAlignRight {
    if ((self.layoutParam.gravity & UPGravityRight) != 0) {
        return true;
    }
    if ((self.layoutParam.gravity & UPGravityLeft) != 0
        || (self.layoutParam.gravity & UPGravityCenterHorizontal) != 0
        || (self.layoutParam.gravity & UPGravityCenter) != 0
        ) {
        return false;
    }
    UPView* superView = self.superUPView;
    if (superView == nil) {
        return false;
    }
    if ((superView.layoutParam.contentGravity & UPGravityRight) != 0) {
        return true;
    }
   
    return false;
}

-(BOOL) isAlignBottom{
    if ((self.layoutParam.gravity & UPGravityBottom) != 0) {
        return true;
    }
    if ((self.layoutParam.gravity & UPGravityTop) != 0
        || (self.layoutParam.gravity & UPGravityCenterVertical) != 0
        || (self.layoutParam.gravity & UPGravityCenter) != 0
        ) {
        return false;
    }
    UPView* superView = self.superUPView;
    if (superView == nil) {
        return false;
    }
    if ((superView.layoutParam.contentGravity & UPGravityBottom) != 0) {
        return true;
    }
    
    return false;
}


-(void) layoutChildrenByFrame {
    float frameWidth = self.frame.size.width;
    float frameHeight = self.frame.size.height;
    float contentWidth = frameWidth - self.layoutParam.padding.hspace;
    float contentHeight = frameHeight - self.layoutParam.padding.vspace;
    for (int i = 0; i < self.subUPViews.count; i++) {
        UPView* subview = self.subUPViews[i];
        float subviewWidth = [subview measureWidth];
        float subviewHeight = [subview measureHeight];
        
        CGRect frame = CGRectMake(0, 0, subviewWidth, subviewHeight);
        
        // set x
        if ([subview isAlignLeft]) {
            frame.origin.x = self.layoutParam.padding.left + subview.layoutParam.margin.left;
        } else if([subview isAlignRight]) {
            frame.origin.x = frameWidth - self.layoutParam.padding.right - subview.layoutParam.margin.right - subviewWidth;
        } else {
            frame.origin.x = self.layoutParam.padding.left + (contentWidth - subviewWidth - subview.layoutParam.margin.hspace) / 2 + subview.layoutParam.margin.left;
        }
        
        // set y
        if ([subview isAlignTop]) {
            frame.origin.y = subview.layoutParam.margin.top + self.layoutParam.padding.top;
        } else if([subview isAlignBottom]) {
            frame.origin.y = frameHeight - self.layoutParam.padding.bottom - subview.layoutParam.margin.bottom - subviewHeight;
        } else {
            frame.origin.y = self.layoutParam.padding.top + (contentHeight - subviewHeight - subview.layoutParam.margin.vspace) / 2 + subview.layoutParam.margin.top;
        }
        
        subview.frame = frame;
    }
}

-(void) layoutChildrenByHorizontal {
    float frameWidth = self.frame.size.width;
    float frameHeight = self.frame.size.height;
    float contentWidth = frameWidth - self.layoutParam.padding.hspace;
    float contentHeight = frameHeight - self.layoutParam.padding.vspace;
    float offsetX = self.layoutParam.padding.left;
    
    NSMutableArray* frames = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.subUPViews.count; i++) {
        UPView* subview = self.subUPViews[i];
        float subviewWidth = [subview measureWidth];
        float subviewHeight = [subview measureHeight];
        
        CGRect frame = CGRectMake(0, 0, subviewWidth, subviewHeight);
        
    
        // set x
        frame.origin.x = offsetX + subview.layoutParam.margin.left;
        offsetX += subviewWidth + subview.layoutParam.margin.hspace;
        
        // set y
        if ([subview isAlignTop]) {
            frame.origin.y = self.layoutParam.padding.top + subview.layoutParam.margin.top;
        } else if([subview isAlignBottom]) {
            frame.origin.y = frameHeight - self.layoutParam.padding.bottom - subview.layoutParam.margin.bottom - subviewHeight;
        } else {
            frame.origin.y = self.layoutParam.padding.top + (contentHeight - subviewHeight - subview.layoutParam.margin.vspace) / 2 + subview.layoutParam.margin.top;
        }
        [frames addObject:[NSValue valueWithCGRect:frame]];
    }
    
    if ((self.layoutParam.contentGravity & UPGravityLeft) != 0) {
        for (int i = 0 ; i < self.subUPViews.count; i++) {
            UIView* view = self.subUPViews[i];
            CGRect frame = [frames[i] CGRectValue];
            view.frame = frame;
        }
        return;
    }

    
    if ((self.layoutParam.contentGravity & UPGravityRight) != 0) {
        float deltaX = frameWidth - self.layoutParam.padding.right - offsetX;
        for (int i = 0 ; i < self.subUPViews.count; i++) {
            UIView* view = self.subUPViews[i];
            CGRect frame = [frames[i] CGRectValue];
            frame.origin.x += deltaX;
            view.frame = frame;
        }
        return;
    }
    
    if ((self.layoutParam.contentGravity & UPGravityCenter) != 0
        || (self.layoutParam.contentGravity & UPGravityCenterHorizontal) != 0
        ) {
        float deltaX = (contentWidth - offsetX + self.layoutParam.padding.left) / 2;
        for (int i = 0 ; i < self.subUPViews.count; i++) {
            UIView* view = self.subUPViews[i];
            CGRect frame = [frames[i] CGRectValue];
            frame.origin.x += deltaX;
            view.frame = frame;
        }
        return;
    }
    
    for (int i = 0 ; i < self.subUPViews.count; i++) {
        UIView* view = self.subUPViews[i];
        CGRect frame = [frames[i] CGRectValue];
        view.frame = frame;
    }
    return;
}

-(void) layoutChildrenByVertical {
    float frameWidth = self.frame.size.width;
    float frameHeight = self.frame.size.height;
    float contentWidth = frameWidth - self.layoutParam.padding.hspace;
    float contentHeight = frameHeight - self.layoutParam.padding.vspace;
    float offsetY = self.layoutParam.padding.top;
    
    NSMutableArray* frames = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.subUPViews.count; i++) {
        UPView* subview = self.subUPViews[i];
        float subviewWidth = [subview measureWidth];
        float subviewHeight = [subview measureHeight];
        
        CGRect frame = CGRectMake(0, 0, subviewWidth, subviewHeight);
        
        
        // set y
        frame.origin.y = offsetY + subview.layoutParam.margin.top;
        offsetY += subviewHeight + subview.layoutParam.margin.vspace;
        
        // set x
        if ([subview isAlignLeft]) {
            frame.origin.x = self.layoutParam.padding.left + subview.layoutParam.margin.left;
        } else if([subview isAlignRight]) {
            frame.origin.x = frameWidth - self.layoutParam.padding.right - subview.layoutParam.margin.right - subviewWidth;
        } else {
            frame.origin.x = self.layoutParam.padding.left + (contentWidth - subviewWidth - subview.layoutParam.margin.hspace) / 2 + subview.layoutParam.margin.left;
        }
        [frames addObject:[NSValue valueWithCGRect:frame]];
    }
    
    if ((self.layoutParam.contentGravity & UPGravityTop) != 0) {
        for (int i = 0 ; i < self.subUPViews.count; i++) {
            UIView* view = self.subUPViews[i];
            CGRect frame = [frames[i] CGRectValue];
            view.frame = frame;
        }
        return;
    }
    
    
    if ((self.layoutParam.contentGravity & UPGravityBottom) != 0) {
        float deltaY = frameHeight - self.layoutParam.padding.bottom - offsetY;
        for (int i = 0 ; i < self.subUPViews.count; i++) {
            UIView* view = self.subUPViews[i];
            CGRect frame = [frames[i] CGRectValue];
            frame.origin.y += deltaY;
            view.frame = frame;
        }
        return;
    }
    
    if ((self.layoutParam.contentGravity & UPGravityCenter) != 0
        || (self.layoutParam.contentGravity & UPGravityCenterVertical) != 0
        ) {
        float deltaY = (contentHeight - offsetY + self.layoutParam.padding.top) / 2;
        for (int i = 0 ; i < self.subUPViews.count; i++) {
            UIView* view = self.subUPViews[i];
            CGRect frame = [frames[i] CGRectValue];
            frame.origin.y += deltaY;
            view.frame = frame;
        }
        return;
    }
    
    for (int i = 0 ; i < self.subUPViews.count; i++) {
        UIView* view = self.subUPViews[i];
        CGRect frame = [frames[i] CGRectValue];
        view.frame = frame;
    }
    return;
}


-(void) layoutSubviews {
    if (self.layoutParam.layout == UPLayoutFrame) {
        [self layoutChildrenByFrame];
    } else if(self.layoutParam.layout == UPLayoutHorizontal) {
        [self layoutChildrenByHorizontal];
    } else if(self.layoutParam.layout == UPLayoutVertical) {
        [self layoutChildrenByVertical];
    }
    [self setNeedsDisplay];
}




+(float) parseSize:(NSString*) spec {
    // 尝试按照枚举变量来解析
    UPLayoutConstrain layoutConstrain = UPLayoutConstrainFromString(spec);
    if (layoutConstrain != UPLayoutConstrainNumber) {
        return layoutConstrain;
    }
    if ([spec hasSuffix:@"px"]) {
        return [[spec substringToIndex:spec.length-2] floatValue] / [UIScreen mainScreen].scale;
    }
    if ([spec hasSuffix:@"dp"]) {
        return [[spec substringToIndex:spec.length-2] floatValue];
    }
    return [spec floatValue];
}

-(void) setAlphaRate:(NSString*)alpha {
    self.alpha = [alpha floatValue];
}

-(void) setLayout:(NSString *)layoutSpec {
    self.layoutParam.layout = UPLayoutFromString(layoutSpec);
}

-(void) setWidth:(NSString *)widthSpec {
    NSArray* components = [widthSpec componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (components == nil || components.count < 1) {
        return;
    }
    
    // 尝试解析weight
    if (components.count > 1) {
        self.layoutParam.widthWeight = [components[1] floatValue];
    }
    
    // 尝试按照枚举变量来解析
    self.layoutParam.width = [UPView parseSize:components[0]];
}


-(void) setHeight:(NSString *)heightSpec {
    NSArray* components = [heightSpec componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (components == nil || components.count < 1) {
        return;
    }
    
    // 尝试解析weight
    if (components.count > 1) {
        self.layoutParam.heightWeight = [components[1] floatValue];
    }
    
    // 尝试按照枚举变量来解析
    self.layoutParam.height = [UPView parseSize:components[0]];
}

-(void) setMargin:(NSString*) marginSpec {
    [self.layoutParam.margin setTRBL:marginSpec];
}
-(void) setMarginTop:(NSString*) spec {
    self.layoutParam.margin.top = [UPView parseSize:spec];
}
-(void) setMarginRight:(NSString*) spec {
    self.layoutParam.margin.right = [UPView parseSize:spec];
}
-(void) setMarginBottom:(NSString*) spec {
    self.layoutParam.margin.bottom = [UPView parseSize:spec];
}
-(void) setMarginLeft:(NSString*) spec {
    self.layoutParam.margin.left = [UPView parseSize:spec];
}
-(void) setPadding:(NSString*) paddingSpec {
    [self.layoutParam.padding setTRBL:paddingSpec];
}
-(void) setPaddingTop:(NSString*) spec {
    self.layoutParam.padding.top = [UPView parseSize:spec];
}
-(void) setPaddingRight:(NSString*) spec {
    self.layoutParam.padding.right = [UPView parseSize:spec];
}
-(void) setPaddingBottom:(NSString*) spec {
    self.layoutParam.padding.bottom = [UPView parseSize:spec];
}
-(void) setPaddingLeft:(NSString*) spec {
    self.layoutParam.padding.left = [UPView parseSize:spec];
}
-(void) setGravity:(NSString*) spec {
    self.layoutParam.gravity = UPGravityFromString(spec);
}
-(void) setContentGravity:(NSString*) spec {
    self.layoutParam.contentGravity = UPGravityFromString(spec);
}
-(void) setBackground:(NSString*) spec {
    if ([spec hasPrefix:@"#"]) {
        UIColor* color = [UPView parseColor:spec];
        self.backgroundColor = color;
        return;
    }
    
    // TODO: 支持渐变色和9宫格图片背景
    
    NSString* resourcePath = [self.resourceLocator locateResource:spec];
    [self.resourceLoader loadResource:resourcePath callback:^(NSData *data) {
        self.backgroundImage = [UIImage imageWithData:data];
    }];
}
-(void) setBorderWidth:(NSString*)spec {
    self.layer.borderWidth = [UPView parseSize:spec];
}
-(void) setBorderColor:(NSString*)spec {
    self.layer.borderColor = [UPView parseColor:spec].CGColor;
}
-(void) setBorderCorner:(NSString*)spec {
    self.layer.cornerRadius = [UPView parseSize:spec];
}

-(void) setBorderClip:(NSString*)spec {
    self.layer.masksToBounds = [@"true" isEqualToString:spec];
}

-(UITapGestureRecognizer*) tapGestureRecognizer {
    if (self->_tapGestureRecognizer == nil) {
        self->_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onViewClicked:)];
        [self addGestureRecognizer:self->_tapGestureRecognizer];
    }
    return self->_tapGestureRecognizer;
}

-(NSString*) extractVarname:(NSString*) from {
    NSRange start = [from rangeOfString:@"${"];
    NSRange stop = [from rangeOfString:@"}"];
    if (start.location != NSNotFound && stop.location != NSNotFound) {
        return [from substringWithRange:NSMakeRange(start.location+2, stop.location-start.location-2)];
    }
    return nil;
}

-(JSValue*) resolveValue:(NSString*)name from:(JSValue*)obj {
    if ([name isEqualToString:@"this"]) {
        return obj;
    }
    return obj[name];
}

-(JSValue*) resolveValueFromPageData:(NSString*)name {
    if ([@"this" isEqualToString:name]) {
        return self.jsPageData;
    }
    return [self getValueFromJSObject:self.jsPageData byExpression:name];
}

-(NSString*) resolveDataExpress:(NSString*) origin {
    NSRange index;
    while((index = [origin rangeOfString:@"${"]).location != NSNotFound) {
        NSRange start = [origin rangeOfString:@"${"];
        NSRange stop = [origin rangeOfString:@"}"];
        if (start.location != NSNotFound && stop.location != NSNotFound && stop.location > start.location) {
            NSString* varname = [origin substringWithRange:NSMakeRange(start.location+2, stop.location-start.location-2)];
            JSValue* value = [self resolveValueFromPageData:varname];
            if (value != nil) {
                origin = [NSString stringWithFormat:@"%@%@%@",[origin substringWithRange:NSMakeRange(0, start.location)],[value description],[origin substringFromIndex:stop.location+1]];
            }
        }
    }
    return origin;
}

-(void) invokeJSMethod:(NSString*)methodSpec {
    
    if ([methodSpec rangeOfString:@"("].location == NSNotFound) {
        methodSpec = [NSString stringWithFormat:@"%@()",methodSpec];
    }
    
    UPView* rootUPView = [self findRootUPView];
    NSString* objName = rootUPView.jsPageObjectName;
    
    NSString* method = [self resolveDataExpress:methodSpec];
    
    [UPView evaluate:[NSString stringWithFormat:@"%@.%@",objName,method]];
    
    //    NSRange methodLeftBracket = [methodSpec rangeOfString:@"("];
//    NSString* methodName = methodSpec;
//    if (methodLeftBracket.location != NSNotFound) {
//        methodName = [methodSpec substringToIndex:methodLeftBracket.location];
//    }
//    
//    JSValue* func = [self findRootUPView].jsPageObject[methodName];
//
//    JSValue* param = nil;
//    NSString* varname = [self extractVarname:methodSpec];
//    if (varname != nil) {
//        JSValue* value = [self findContextPageData];
//        param = [self resolveValue:varname from:value];
//    }
//    if (param) {
//        [func callWithArguments:[NSArray arrayWithObject:param]];
//    } else {
//        [func callWithArguments:nil];
//    }
//    
}

-(void) onViewClicked:(id)view {
    if (self->_jsOnClickMethod != nil) {
        [self invokeJSMethod:self.jsOnClickMethod];
    }
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    if (now - self.lastClickTime < 0.5) {
        if (self->_jsOnDoubleClickMethod != nil) {
            [self invokeJSMethod:self.jsOnDoubleClickMethod];
        }
    }
    self.lastClickTime = now;
}

-(UPView*) findRootUPView {
    if (self->_jsPageObject != nil) {
        return self;
    }
    return [[self superUPView] findRootUPView];
}

-(void) setOnClick:(NSString*)spec {
    self.jsOnClickMethod = spec;
    [self tapGestureRecognizer];
}

-(void) setOnDoubleClick:(NSString*) spec {
    self.jsOnDoubleClickMethod = spec;
}

-(void) drawRect:(CGRect)rect {
    [self drawBackground];
    [super drawRect:rect];
    
}

-(void) drawBackground {
    if (self.backgroundImage == nil) {
        return;
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(ctx);
    [self.backgroundImage drawInRect:self.bounds];
    UIGraphicsPopContext();
}

+(BOOL) parseBoolean:(NSString*) spec {
    return [@"true" isEqualToString:spec];
}


+ (UIColor *) parseColor: (NSString *)color
{
    NSString *cString = color;
    // String should be 6 or 8 characters
    if ([cString length] < 7 || ![color hasPrefix:@"#"]) {
        return [UIColor clearColor];
    }
    
    cString = [cString substringFromIndex:1];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //a
    NSString *aString = @"FF";
    if (color.length == 9) {
        aString = [cString substringWithRange:range];
        range.location += 2;
    }
    
    //r
    NSString *rString = [cString substringWithRange:range];
    range.location += 2;
    
    //g
    NSString *gString = [cString substringWithRange:range];
    range.location += 2;
    
    //b
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b,a;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    [[NSScanner scannerWithString:aString] scanHexInt:&a];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:((float) a / 255.0f)];
}


-(UPView*) findViewByGid:(NSString*)gid {
    if ([gid isEqualToString:self.gid]) {
        return self;
    }
    NSArray* subUPViews = [self subUPViews];
    for (int i = 0 ; i < subUPViews.count; i++) {
        UPView* subview = subUPViews[i];
        UPView* finded = [subview findViewByGid:gid];
        if (finded != nil) {
            return finded;
        }
    }
    return nil;
}


+(void) loadViewFromPath:(NSString*)path callback:(void(^)(UPView*))callback {
    [UPView loadViewFromPath:path
                  resourceLoader:[[UPPageViewLoader alloc] initWithRootPath:path]
                        callback:callback];
}


+(void) loadViewFromPath:(NSString*)path resourceLoader:(id<UPResourceLoader>)resourceLoader callback:(void(^)(UPView*))callback {
    UPViewParser* parser = [[UPViewParser alloc] init];
    parser.resourceLoader = resourceLoader;
    parser.contextPath = [UPPathUtil resolveWithRootPath:@"/" contextPath:nil relativePath:path];
    parser.rootPath = @"/";
    parser.callback = ^(UPView*obj){
        callback(obj);
        if (obj != nil) {
            if ([resourceLoader isKindOfClass:[UPPageViewLoader class]]) {
                UPPageViewLoader* ploader = (UPPageViewLoader*)resourceLoader;
                [ploader checkAndUpdate:callback];
            }
        }
    };
    [parser parse];
}

+(void) initialize {
    [UPView globalJSContext];
    
    JSValue* windowObject = [UPView evaluate:@"window={}"];
    windowObject[@"pageBridge"] = [[UPViewPageBridge alloc] init];
}



@end
