//
//  DMNavigator.m
//  DMAppFramework
//
//  Created by chenxinxin on 15/10/27.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "DMNavigator.h"
#import "DMUrlDecoder.h"
#import "DMPage.h"
#import "DMWebPage.h"
#import "DMPageAnimate.h"
#import "DMPageAnimatePushLeft.h"
#import "DMPageAnimatePopRight.h"
#import "DMPageAnimatePushTop.h"
#import "DMPageAnimatePopBottom.h"
#import "DMPageAnimateMagicMove.h"
#import "DMStringUtils.h"
#import "DMWeakify.h"
#import "DMUrlDecoder.h"
#import "DMLRUCache.h"
#import "UPViewPage.h"
#import "DMLog.h"

#define dmall_dispatch_main_sync_safe(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_sync(dispatch_get_main_queue(), block);\
    }

#define dmall_dispatch_main_async_safe(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }



@interface DMPageHolder : NSObject
@property (strong,nonatomic) DMPage* pageInstance;
/*!
 *  页面参数
 */
@property (strong,nonatomic) NSDictionary* pageParams;

/*!
 *  框架参数
 */
@property (strong,nonatomic) NSDictionary* frameworkParams;

/*!
 *  跳转时传入的url(不包含传递给框架的参数,及@开头的参数)
 */
@property (strong,nonatomic) NSString* pageUrl;

@property (strong,nonatomic) NSString* pageName;
/*!
 *  向上一个页面回传数据的接口
 */
@property (copy,nonatomic) void (^ pageCallback)(NSDictionary*);
@end


@implementation DMPageHolder
-(void) setPageParams:(NSDictionary *)pageParams {
    self->_pageParams = pageParams;
    if ([self.pageInstance respondsToSelector:@selector(setPageParams:)]) {
        [((id<DMPageAware>)self.pageInstance) setPageParams:pageParams];
    }
}
-(void) setFrameworkParams:(NSDictionary *)frameworkParams {
    self->_frameworkParams = frameworkParams;
    if ([self.pageInstance respondsToSelector:@selector(setFrameworkParams:)]) {
        [((id<DMPageAware>)self.pageInstance) setFrameworkParams:frameworkParams];
    }
}
-(void) setPageUrl:(NSString *)pageUrl {
    self->_pageUrl = pageUrl;
    if ([self.pageInstance respondsToSelector:@selector(setPageUrl:)]) {
        [((id<DMPageAware>)self.pageInstance) setPageUrl:pageUrl];
    }
}
-(void) setPageCallback:(void (^)(NSDictionary *))pageCallback {
    self->_pageCallback = pageCallback;
    if ([self.pageInstance respondsToSelector:@selector(setPageCallback:)]) {
        [((id<DMPageAware>)self.pageInstance) setPageCallback:pageCallback];
    }
}

-(void) setPageName:(NSString *)pageName {
    self->_pageName = pageName;
    if ([self.pageInstance respondsToSelector:@selector(setPageName:)]) {
        [((id<DMPageAware>)self.pageInstance) setPageName:pageName];
    }
}



@end


@interface DMNavigator()
/*!
 *  单个页面的堆栈
 *  注意： 页面堆栈中存储的不直接是page实例，而是DMPageHolder对象
 *        存储了关于页面的更多信息
 */
@property (strong,nonatomic) NSMutableArray* pageStack;
/*!
 *  业务流程堆栈（每个对象代表一个业务流程的起点页面）
 */
@property (strong,nonatomic) NSMutableArray* pageFlowStack;
@property (strong,nonatomic) DMLRUCache* pageCache;

@property (assign,nonatomic) BOOL pageAnimationForward;
@property (strong,nonatomic) id<DMPageAnimate> pageAnimation;
@property (strong,nonatomic) DMPage* pageAnimationFrom;
@property (strong,nonatomic) DMPage* pageAnimationTo;
@end

@implementation DMNavigator



DMLOG_DEFINE(DMNavigator)


-(DMLRUCache*) pageCache {
    if (self->_pageCache == nil) {
        self->_pageCache = [[DMLRUCache alloc] initWithCap:12];
    }
    return self->_pageCache;
}

-(NSMutableArray*) pageStack {
    if(self->_pageStack == nil) {
        self->_pageStack = [[NSMutableArray alloc] init];
    }
    return self->_pageStack;
}

-(NSMutableArray*) pageFlowStack {
    if(self->_pageFlowStack == nil) {
        self->_pageFlowStack = [[NSMutableArray alloc] init];
    }
    return self->_pageFlowStack;
}


NSMutableDictionary* DMNavigator_pageRegistry;

+(NSMutableDictionary*) pageRegistry {
    if(DMNavigator_pageRegistry == nil) {
        DMNavigator_pageRegistry = [[NSMutableDictionary alloc] init];
    }
    return DMNavigator_pageRegistry;
}

NSMutableDictionary* DMNavigator_pageAnimationRegistry;
+(NSMutableDictionary*) pageAnimationRegistry {
    if(DMNavigator_pageAnimationRegistry == nil) {
        DMNavigator_pageAnimationRegistry = [[NSMutableDictionary alloc] init];
    }
    return DMNavigator_pageAnimationRegistry;
}

NSMutableDictionary* DMNavigator_redirectRegistry;
+(NSMutableDictionary*) redirectRegistry {
    if (DMNavigator_redirectRegistry == nil) {
        DMNavigator_redirectRegistry = [[NSMutableDictionary alloc] init];
    }
    return DMNavigator_redirectRegistry;
}

-(instancetype) init {
    if(self = [super init]) {
        [self initSelf];
    }
    return self;
}

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        [self initSelf];
    }
    return self;
}

-(instancetype) initWithUrl:(NSString*)url {
    if(self = [super init]) {
        [self initSelf];
        [self forward:url];
    }
    return self;
}


-(void) loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor whiteColor];
}


DMNavigator* DMNavigator_instance;


+(DMNavigator*) getInstance {
    return DMNavigator_instance;
}

-(void) initSelf {
    DMNavigator_instance = self;
}

+(void) initialize {
    [[DMNavigator pageAnimationRegistry] setObject:[DMPageAnimatePushLeft class] forKey:@"pushleft"];
    [[DMNavigator pageAnimationRegistry] setObject:[DMPageAnimatePopRight class] forKey:@"popright"];
    [[DMNavigator pageAnimationRegistry] setObject:[DMPageAnimatePushTop class] forKey:@"pushtop"];
    [[DMNavigator pageAnimationRegistry] setObject:[DMPageAnimatePopBottom class] forKey:@"popbottom"];
    [[DMNavigator pageAnimationRegistry] setObject:[DMPageAnimateMagicMove class] forKey:@"magicmove"];
}

-(DMPage*) resolvePage:(NSString*)url {
    DMPage* page       = nil;
    Class clazz        = nil;
    DMUrlInfo* urlInfo = [DMUrlDecoder decodeUrl:url];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(navigator:shouldOverridePageClass:)]) {
        clazz = [self.delegate navigator:self shouldOverridePageClass:url];
        if (clazz != nil) {
            DMDebug(@"Navigator will use custom class '%@' return by delegate for url '%@'",NSStringFromClass(clazz),url);
        }
    }
    
    if (clazz == nil) {
        if ([@"app" isEqualToString:urlInfo.protocol]) {
            clazz = [[DMNavigator pageRegistry] objectForKey:[urlInfo.appPageName lowercaseString]];
            // 如果该名称的页面未注册，则直接将名称当做类型名称
            if(clazz == nil) {
                clazz = NSClassFromString(urlInfo.appPageName);
                if (clazz == nil) {
                    //swift项目中  类名全称 = MoudleName + ClassName
                    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                    NSString *appName = [infoDictionary objectForKey:@"CFBundleName"];
                    NSString * className = [NSString stringWithFormat:@"%@.%@",appName,urlInfo.appPageName];
                    clazz = NSClassFromString(className);
                }
            }
        } else if([@"up" isEqualToString:urlInfo.protocol]){
            clazz = [UPViewPage class];
        } else if([@"http" isEqualToString:urlInfo.protocol]
              || [@"https" isEqualToString:urlInfo.protocol]
              || [@"file" isEqualToString:urlInfo.protocol]
              ) {
            clazz = [DMWebPage class];
        }
    }
    
    if (clazz) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(navigator:shouldCachePage:)] && [self.delegate navigator:self shouldCachePage:url]) {
            page = [self.pageCache objectForKey:NSStringFromClass(clazz)];
        }
        
        if (page == nil) {
            page = [[clazz alloc] init];
            if ([page respondsToSelector:@selector(pageInit)]) {
                [((id<DMPageLifeCircle>)page) pageInit];
            }
        } else {
            [self.pageCache remove:NSStringFromClass(clazz)];
        }
        if ([page respondsToSelector:@selector(setNavigator:)]) {
            [((id<DMPageAware>)page) setNavigator:self];
        }
    }

    return page;
}

//return @"null" 代表animate为空， return nil代表传入了不支持的动画类型.
-(id<DMPageAnimate>) resolveAnimation:(NSMutableDictionary*)frameworkParams
                              forward:(BOOL)forward{
    NSString* animateRegistKey = [frameworkParams objectForKey:@"animate"];
    if (animateRegistKey == nil) {
        if(forward) {
            animateRegistKey = @"pushleft";
        } else {
            animateRegistKey = @"popright";
        }
    }
    
    if ([@"null" isEqualToString:animateRegistKey]) {
        return (id)@"null";
    }
    
    Class animateClass = [[DMNavigator pageAnimationRegistry] objectForKey:animateRegistKey];
    return [[animateClass alloc] init];
}

/*!
 *  跳转到指定的页面
 *
 *  @param url 页面资源定位
 *     可能为app，h5或者RN页面
 */
-(void) forward:(NSString*) url {
    [self forward:url callback:nil];
}


-(void) autoWareParams:(NSDictionary*)params forPage:(UIViewController*)page {
    DMDebug(@"try autoware params to page : %@ ",NSStringFromClass([page class]));
    for (NSString *key in params) {
        NSString* value = params[key];
        DMDebug(@"try autoware param key:%@ value:%@",key,value);
        if ([page isKindOfClass:[DMPage class]]) {
            [((DMPage*)page) warePageParam:value byKey:key];
        }
    }
}


-(DMPageHolder*) prepareNewPage:(DMPage*) page withUrl:(DMUrlInfo*)info andCallback:(void(^)(NSDictionary*)) callback{
    DMPageHolder* holder = [[DMPageHolder alloc] init];
    holder.pageInstance = page;
    holder.pageUrl = info.url;
    holder.pageName = info.appPageName;
    holder.pageParams = info.params;
    holder.frameworkParams = info.params;
    holder.pageCallback = callback;
    
    [self autoWareParams:info.params forPage:page];
    return holder;
}

-(BOOL) isJumpEnable:(DMUrlInfo*) info {
    if (info != nil) {
        NSString* value = [info.frameworkParams objectForKey:@"jump"];
        if (value != nil && [@"true" isEqualToString:value]) {
            return YES;
        }
    }
    return NO;
}

-(void) performPageAnimation {
    if (self.pageAnimation != nil) {
        
        
        DMPage* from = self.pageAnimationFrom;
        DMPage* to = self.pageAnimationTo;
        id<DMPageAnimate> animate = self.pageAnimation;
        
        [self removeAllFromTree];
        if (self.pageAnimationForward) {
            [self addPageToTree:from];
            [self addPageToTree:to];
        } else {
            [self addPageToTree:to];
            [self addPageToTree:from];
        }
        
        
        
        from.view.userInteractionEnabled = NO;
        to.view.userInteractionEnabled = NO;
        @weakify_self
        @weakify(from)
        @weakify(to)
        
        [animate animateFrom:from to:to callback:^{
            @strongify_self
            @strongify(from)
            @strongify(to)
            [self removePageFromTree:from];
            strong_from.view.userInteractionEnabled = YES;
            strong_to.view.userInteractionEnabled = YES;
            if ([strong_from respondsToSelector:@selector(pageDidHidden)]) {
                [((id<DMPageLifeCircle>)strong_from) pageDidHidden];
            }
            if ([strong_from respondsToSelector:@selector(pageDidForwardFromMe)]) {
                if (self.pageAnimationForward) {
                    [((id<DMPageLifeCircle>)strong_from) pageDidForwardFromMe];
                } else {
                    [((id<DMPageLifeCircle>)strong_from) pageDidBackwardFromMe];
                }
            }
            if ([strong_to respondsToSelector:@selector(pageDidShown)]) {
                [((id<DMPageLifeCircle>)strong_to) pageDidShown];
            }
            if ([strong_to respondsToSelector:@selector(pageDidForwardToMe)]) {
                if (self.pageAnimationForward) {
                    [((id<DMPageLifeCircle>)strong_to) pageDidForwardToMe];
                } else {
                    [((id<DMPageLifeCircle>)strong_to) pageDidBackwardToMe];
                }
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(navigator:didChangedPageTo:)]) {
                [self.delegate navigator:self didChangedPageTo:to.pageUrl];
            }
            
            self.pageAnimationFrom = nil;
        }];
        self.pageAnimation = nil;
    }
}

/*!
 *  跳转到指定的页面并且获取页面返回
 *
 *  @param url      页面资源定位
 *  @param callback 页面回调结果
 */
-(void) forward:(NSString*)url
       callback:(void(^)(NSDictionary*)) callback {
    if (!url || url.length < 1) {
        return ;
    }
    __block NSString    *fowUrl = url;
    @weakify_self
    dmall_dispatch_main_async_safe((^{
        @strongify_self
        DMUrlInfo* info = [DMUrlDecoder decodeUrl:fowUrl];
        // 重定向
        NSString* redirectUrlPath = [[DMNavigator redirectRegistry] objectForKey:info.urlPath];
        if (redirectUrlPath != nil) {
            fowUrl = [NSString stringWithFormat:@"%@%@",redirectUrlPath,[fowUrl substringFromIndex:info.urlPath.length]];
            info = [DMUrlDecoder decodeUrl:fowUrl];
        }
        
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(navigator:shouldForwardTo:)]) {
            BOOL shouldForward = [self.delegate navigator:self shouldForwardTo:fowUrl];
            if (!shouldForward) {
                DMDebug(@"Navigator should not forward to url according to delegate : %@",fowUrl);
                return;
            }
        }
        
        if ([self isJumpEnable:info]) {
            [self jump:fowUrl callback:callback];
            return;
        }
        DMDebug(@"Navigator will forward to url : %@",fowUrl)
        
        DMPage* from    = (DMPage*)[self topPage];
        DMPage* to      = (DMPage*)[self resolvePage:fowUrl];
        id<DMPageAnimate> animate = [self resolveAnimation:info.frameworkParams forward:YES];
        if (!to || !animate) {
            DMDebug(@"can not resolve page for url : %@",fowUrl)
            if ([from respondsToSelector:@selector(canNotForwardUrl:)]) {
                [from canNotForwardUrl:fowUrl];
            }
            return;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(initPageArguments:toPage:)]) {
            [self.delegate initPageArguments:from toPage:to];
        }
        DMPageHolder* page = [self prepareNewPage:to withUrl:info andCallback:callback];
        
        [self pushPageToStack:page];
        
        if ([from respondsToSelector:@selector(pageWillBeHidden)]) {
            [((id<DMPageLifeCircle>)from) pageWillBeHidden];
        }
        if ([from respondsToSelector:@selector(pageWillForwardFromMe)]) {
            [((id<DMPageLifeCircle>)from) pageWillForwardFromMe];
        }
        if ([to respondsToSelector:@selector(pageWillBeShown)]) {
            [((id<DMPageLifeCircle>)to) pageWillBeShown];
        }
        if ([to respondsToSelector:@selector(pageWillForwardToMe)]) {
            [((id<DMPageLifeCircle>)to) pageWillForwardToMe];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(navigator:willChangePageTo:)]) {
            [self.delegate navigator:self willChangePageTo:to.pageUrl];
        }
        
        BOOL isRealAnimateClass = YES;
        if ([animate isKindOfClass:[NSString class]] && [(NSString *)animate isEqualToString:@"null"]) {
            isRealAnimateClass = NO;
        }
        DMDebug(@"isRealAnimateClass:%d", isRealAnimateClass);
        
        if (from != nil && to != nil && isRealAnimateClass) {
            self.pageAnimationForward = YES;
            self.pageAnimation = animate;
            if (self.pageAnimationFrom == nil) {
                self.pageAnimationFrom = from;
            }
            self.pageAnimationTo = to;
            [self performPageAnimation];
        } else {
            [self removeAllFromTree];
            [self addPageToTree:to];
            if ([from respondsToSelector:@selector(pageDidHidden)]) {
                [((id<DMPageLifeCircle>)from) pageDidHidden];
            }
            if ([from respondsToSelector:@selector(pageDidForwardFromMe)]) {
                [((id<DMPageLifeCircle>)from) pageDidForwardFromMe];
            }
            
            if ([to respondsToSelector:@selector(pageDidShown)]) {
                [((id<DMPageLifeCircle>)to) pageDidShown];
            }
            if ([to respondsToSelector:@selector(pageDidForwardToMe)]) {
                [((id<DMPageLifeCircle>)to) pageDidForwardToMe];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(navigator:didChangedPageTo:)]) {
                [self.delegate navigator:self didChangedPageTo:to.pageUrl];
            }
        } 
    }));
}

-(void) jump:(NSString*)url {
    [self jump:url callback:nil];
}

-(void) putToCache:(DMPage*)page {
    if ([page isKindOfClass:[UPViewPage class]] || [page isKindOfClass:[DMWebPage class]]) {
        if ([page respondsToSelector:@selector(pageDestroy)]) {
            [((id<DMPageLifeCircle>)page) pageDestroy];
        }
        return;
    }
    
    // 如果无delegate不缓存任何页面
    if (self.delegate == nil) {
        return;
    }
    
    // 如果delegate明确返回不缓存此页面
    if (self.delegate != nil
        && [self.delegate respondsToSelector:@selector(navigator:shouldCachePage:)]
        && ![self.delegate navigator:self shouldCachePage:page.pageUrl]) {
        if ([page respondsToSelector:@selector(pageDestroy)]) {
            [((id<DMPageLifeCircle>)page) pageDestroy];
        }
        return;
    }
    
    [self.pageCache setObject:page forKey:NSStringFromClass(page.class)];
}

-(void) jumpStackTo:(DMPageHolder*) page {
    for (DMPageHolder* pageHolder in self.pageStack) {
        [self putToCache:pageHolder.pageInstance];
    }
    [self.pageFlowStack removeAllObjects];
    [self.pageStack removeAllObjects];
    [self.pageStack addObject:page];
}

-(void) jump:(NSString*)url
    callback:(void(^)(NSDictionary* ))callback {
    DMUrlInfo* info = [DMUrlDecoder decodeUrl:url];
    DMPage* from    = [self topPage];
    DMPage* to      = [self resolvePage:url];
    id<DMPageAnimate> animate = [self resolveAnimation:info.frameworkParams forward:YES];

    if (!to || !animate) {
        DMDebug(@"Navigator can not jump due to unresolved page instance for url: %@",url);
        if ([from respondsToSelector:@selector(canNotForwardUrl:)]) {
            [from canNotForwardUrl:url];
        }
        return;
    }
    
    DMDebug(@"Navigator will jump to url : %@",url);
    
    DMPageHolder* page = [self prepareNewPage:to withUrl:info andCallback:callback];
    
    [self pushPageToStack:page];
    
    
    if ([from respondsToSelector:@selector(pageWillBeHidden)]) {
        [((id<DMPageLifeCircle>)from) pageWillBeHidden];
    }
    if ([from respondsToSelector:@selector(pageWillForwardFromMe)]) {
        [((id<DMPageLifeCircle>)from) pageWillForwardFromMe];
    }
    if ([to respondsToSelector:@selector(pageWillBeShown)]) {
        [((id<DMPageLifeCircle>)to) pageWillBeShown];
    }
    if ([to respondsToSelector:@selector(pageWillForwardToMe)]) {
        [((id<DMPageLifeCircle>)to) pageWillForwardToMe];
    }

    
    if (self.delegate && [self.delegate respondsToSelector:@selector(navigator:willChangePageTo:)]) {
        [self.delegate navigator:self willChangePageTo:to.pageUrl];
    }
    
    BOOL isRealAnimateClass = YES;
    if ([animate isKindOfClass:[NSString class]] && [(NSString *)animate isEqualToString:@"null"]) {
        isRealAnimateClass = NO;
    }
    if (from != nil && to != nil && isRealAnimateClass) {
        self.pageAnimationForward = YES;
        self.pageAnimation = animate;
        if (self.pageAnimationFrom == nil) {
            self.pageAnimationFrom = from;
        }
        self.pageAnimationTo = to;
        
        [self performPageAnimation];

    } else {
        [self removeAllFromTree];
        [self addPageToTree:to];
        [self jumpStackTo:page];
        if ([from respondsToSelector:@selector(pageDidHidden)]) {
            [((id<DMPageLifeCircle>)from) pageDidHidden];
        }
        if ([from respondsToSelector:@selector(pageDidForwardFromMe)]) {
            [((id<DMPageLifeCircle>)from) pageDidForwardFromMe];
        }
        if ([to respondsToSelector:@selector(pageDidShown)]) {
            [((id<DMPageLifeCircle>)to) pageDidShown];
        }
        if ([to respondsToSelector:@selector(pageDidForwardToMe)]) {
            [((id<DMPageLifeCircle>)to) pageDidForwardToMe];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(navigator:didChangedPageTo:)]) {
            [self.delegate navigator:self didChangedPageTo:to.pageUrl];
        }
    }

}

-(void) backward {
    [self backward:nil];
}

-(void) callback:(NSString*)param {
    DMPageHolder* topPage = [self topPageHolder];
    if(topPage.pageCallback != nil) {
        DMUrlInfo* info = [DMUrlDecoder decodeParams:param];
        topPage.pageCallback(info.params);
    }
}

-(void) backwardFrom:(DMPageHolder*)fromHolder to:(DMPageHolder*)toHolder param:(NSString*) param {
    DMDebug(@"backwardFrom %@ to %@",NSStringFromClass(fromHolder.pageInstance.class),NSStringFromClass(toHolder.pageInstance.class));
    
    
    DMUrlInfo* info = [DMUrlDecoder decodeParams:param];
    [self popPageFromStackTo:toHolder.pageInstance];
    id<DMPageAnimate> animate = [self resolveAnimation:info.frameworkParams forward:NO];
    
    
    DMPage* from = fromHolder.pageInstance;
    DMPage* to = toHolder.pageInstance;
    
    /**
     * 确保在页面的事件通知之前将参数传递出去
     */
    if (from != nil
        && fromHolder.pageCallback != nil
        && info != nil
        && info.params != nil
        && info.params.count > 0) {
            fromHolder.pageCallback(info.params);
    }
    
    if ([to respondsToSelector:@selector(pageWillBeShown)]) {
        [((id<DMPageLifeCircle>)to) pageWillBeShown];
    }
    if ([to respondsToSelector:@selector(pageWillBackwardToMe)]) {
        [((id<DMPageLifeCircle>)to) pageWillBackwardToMe];
    }
    if ([from respondsToSelector:@selector(pageWillBeHidden)]) {
        [((id<DMPageLifeCircle>)from) pageWillBeHidden];
    }
    if ([from respondsToSelector:@selector(pageWillBackwardFromMe)]) {
        [((id<DMPageLifeCircle>)from) pageWillBackwardFromMe];
    }

    
    if (self.delegate && [self.delegate respondsToSelector:@selector(navigator:willChangePageTo:)]) {
        [self.delegate navigator:self willChangePageTo:to.pageUrl];
    }
    BOOL isRealAnimateClass = YES;
    if ([animate isKindOfClass:[NSString class]] && [(NSString *)animate isEqualToString:@"null"]) {
        isRealAnimateClass = NO;
    }
    if (from != nil && to != nil && isRealAnimateClass) {
        self.pageAnimationForward = NO;
        self.pageAnimation = animate;
        if (self.pageAnimationFrom == nil) {
            self.pageAnimationFrom = from;
        }
        self.pageAnimationTo = to;
        
        [self performPageAnimation];
    } else {
        [self removeAllFromTree];
        [self addPageToTree:toHolder.pageInstance];
        if ([to respondsToSelector:@selector(pageDidShown)]) {
            [((id<DMPageLifeCircle>)to) pageDidShown];
        }
        if ([to respondsToSelector:@selector(pageDidBackwardToMe)]) {
            [((id<DMPageLifeCircle>)to) pageDidBackwardToMe];
        }
        if ([from respondsToSelector:@selector(pageDidHidden)]) {
            [((id<DMPageLifeCircle>)from) pageDidHidden];
        }
        if ([from respondsToSelector:@selector(pageDidBackwardFromMe)]) {
            [((id<DMPageLifeCircle>)from) pageDidBackwardFromMe];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(navigator:didChangedPageTo:)]) {
            [self.delegate navigator:self didChangedPageTo:to.pageUrl];
        }
    }

}

-(void) backward:(NSString *)param {
    
    @weakify_self
    dmall_dispatch_main_async_safe(
       ^{
           @strongify_self
           DMPageHolder* from    = [self topPageHolder];
           DMPageHolder* to      = [self topPageHolder:1];
           
           if (to == nil) {
               DMDebug(@"Navigator can not backward due to empty page stack");
               return;
           }
           DMDebug(@"Navigator will backward with return param : %@",param);
           [self backwardFrom:from to:to param:param];
       }
   );
}

-(void) removePageFromTree:(UIViewController*) page {
    if (page == nil) {
        return;
    }
    [page.view removeFromSuperview];
    [page removeFromParentViewController];
}

/*!
 *  开启一个子业务流程
 */
-(void) pushFlow {
    DMPageHolder* topPage = [self topPageHolder];
    if (topPage == nil) {
        DMError(@"push flow failed due to top page nil");
        return;
    }
    DMError(@"push flow => page : %@",NSStringFromClass(topPage.pageInstance.class));
    [self.pageFlowStack addObject:topPage];
}

/*!
 *  结束当前子业务流程，同时页面跳转回之前pushFlow的地方
 */
-(void) popFlow:(NSString*)param {
    @weakify_self
    dmall_dispatch_main_async_safe(
       ^{
           @strongify_self
           DMPageHolder* from    = [self topPageHolder];
           DMPageHolder* to      = [self topFlowPageHolder:0];
           if (from == nil || to == nil) {
               if (from == nil) {
                   DMError(@"popFlow failed due to frompage nil");
               } else {
                   DMError(@"popFlow failed due to topage nil");
               }
               return;
           }
           DMDebug(@"popFlow from %@ to %@",NSStringFromClass(from.pageInstance.class),NSStringFromClass(to.pageInstance.class));
           [self.pageFlowStack removeLastObject];
           [self backwardFrom:from to:to param:param];
       }
   );
}


-(void) removeAllFromTree {
    for (UIViewController* sub in self.childViewControllers) {
        [sub.view removeFromSuperview];
        [sub removeFromParentViewController];
    }
}

-(void) addPageToTree:(UIViewController*) page {
    if(page == nil) {
        return;
    }
    [self addChildViewController:page];
    [self.view addSubview:page.view];
}


-(DMPageHolder*) topPageHolder {
    DMPageHolder* holder = [self.pageStack lastObject];
    return holder;
}

-(DMPageHolder*) topPageHolder:(int) deep {
    if (self.pageStack.count < deep + 1) {
        return nil;
    }
    DMPageHolder* holder = self.pageStack[self.pageStack.count-deep-1];
    return holder;
}

-(DMPage*) topPage {
    return self.topPageHolder.pageInstance;
}

-(DMPage*) topPage:(int) deep {
    return [self topPageHolder:deep].pageInstance;
}

-(void) rollup {
    DMPage* page = self.topPage;;
    if (page) {
        [page pageRollup];
    }
}

-(DMPage*) topFlowPage:(int) deep {
    return [self topFlowPageHolder:deep].pageInstance;
}

-(DMPageHolder*) topFlowPageHolder:(int) deep {
    if (self.pageFlowStack.count < deep + 1) {
        return nil;
    }
    return self.pageFlowStack[self.pageFlowStack.count-deep-1];
}

-(void) pushPageToStack : (DMPageHolder*) pageHolder {
    [self.pageStack addObject:pageHolder];
}

-(void) popPageFromStackTo: (UIViewController*) targetPage {
    while (self.topPage != targetPage && self.pageStack.count > 0) {
        DMPageHolder* pageHolder = self.pageStack.lastObject;
        [self putToCache:pageHolder.pageInstance];
        [self.pageStack removeLastObject];
    }
}

/*!
 *  注册本地页面
 *
 *  @param name      本地页面的标识符(例如标识符:Payment, 其他页面通过app://Payment来访问)
 *  @param pageClass 页面实现类的class属性(例如Payment如果实现类为DMPayment的话，通过[DMPayment class]来指定)
 */
+(void) registAppPage:(NSString*)name
            pageClass:(Class)pageClass {
    
    [self.pageRegistry setValue:pageClass forKey:[name lowercaseString]];
}

+(void) registRedirectFromUrl:(NSString*)fromUrl toUrl:(NSString*)toUrl {
    [[DMNavigator redirectRegistry] setObject:toUrl forKey:fromUrl];
}

@end
