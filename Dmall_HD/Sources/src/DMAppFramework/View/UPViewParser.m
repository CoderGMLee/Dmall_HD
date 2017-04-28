//
//  UPViewParser.m
//  UPAppFramework
//
//  Created by chenxinxin on 15/11/12.
//  Copyright (c) 2015年 UPall. All rights reserved.
//

#import "UPViewParser.h"
#import "DMStringUtils.h"
#import "UPPathUtil.h"


@interface UPScriptInfo : NSObject
@property (strong,nonatomic) NSString* resourcePath;
@property (strong,nonatomic) NSString* content;
@end

@implementation UPScriptInfo
@end

@interface UPIncludeViewInfo : NSObject
@property (strong,nonatomic) NSString* resourcePath;
@property (strong,nonatomic) UIView* content;
@property (strong,nonatomic) UIView* container;
@end

@implementation UPIncludeViewInfo
@end

@interface UPViewParser() <NSXMLParserDelegate,UPResourceLocator>
@property (strong,nonatomic) NSXMLParser* xmlParser;
@property (strong,nonatomic) NSMutableArray* viewStack;
@property (strong,nonatomic) UPView* rootView;
@property (strong,nonatomic) NSMutableArray* scriptList;
@property (strong,nonatomic) NSMutableArray* includeViewList;
@end

@implementation UPViewParser

-(instancetype) init {
    if (self= [super init]) {
        self.classPrefix = @"UP";
    }
    return self;
}

-(NSMutableArray*) scriptList {
    if (self->_scriptList == nil) {
        self->_scriptList = [[NSMutableArray alloc] init];
    }
    return self->_scriptList;
}

-(NSMutableArray*) includeViewList {
    if (self->_includeViewList == nil) {
        self->_includeViewList = [[NSMutableArray alloc] init];
    }
    return self->_includeViewList;
}

-(NSMutableArray*) viewStack {
    if (self->_viewStack == nil) {
        self->_viewStack = [[NSMutableArray alloc] init];
    }
    return self->_viewStack;
}

-(NSString*) locateResource : (NSString*)path {
    return [UPPathUtil resolveWithRootPath:self.rootPath contextPath:self.contextPath relativePath:path];
}

- (UPView*) createInstanceFromElement:(NSString*)elementName attributes:(NSDictionary*)attrs {
    NSString* clazzName = [NSString stringWithFormat:@"%@%@",self.classPrefix,elementName];
    Class clazz = NSClassFromString(clazzName);
    if (clazz == nil) {
        return [[UPView alloc] init];
    }
    
    UPView* view = [[clazz alloc] init];
    UPView* currentParent = [self.viewStack lastObject];
    if (currentParent != nil) {
        [currentParent addSubview:view];
    }
    view.resourceLoader = self.resourceLoader;
    view.resourceLocator = self;
    for (NSString* key in attrs) {
        id value = attrs[key];
        [view injectValue:value forProperty:key];
    }
    return view;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([@"Script" isEqualToString:elementName]) {
        UPScriptInfo* script = [[UPScriptInfo alloc] init];
        script.resourcePath = [self locateResource:[attributeDict objectForKey:@"src"]];
        [self.scriptList addObject:script];
        return;
    }

    
    UPView* instance = [self createInstanceFromElement:elementName attributes:attributeDict];
    
    if ([@"View" isEqualToString:elementName] && [attributeDict objectForKey:@"src"] != nil) {
        // 如果是需要include方式加载
        UPIncludeViewInfo* viewInfo = [[UPIncludeViewInfo alloc] init];
        viewInfo.resourcePath = [self locateResource:[attributeDict objectForKey:@"src"]];
        viewInfo.container = instance;
        [self.includeViewList addObject:viewInfo];
    }
    
    UPView* currentParent = [self.viewStack lastObject];
    if (currentParent == nil) {
        self.rootView = instance;
    }
    [self.viewStack addObject:instance];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([@"Script" isEqualToString:elementName]) {
        return;
    }
    [self.viewStack removeLastObject];
}

-(void) parse {
    [self.resourceLoader loadResource:self.contextPath callback:^(NSData * data) {
        [self parseData:data];
    }];
}

-(UPView*) parseData:(NSData*) data{
    if (data == nil) {
        if (self.callback) {
            self.callback(nil);
        }
        return nil;
    }
    
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    [parser parse];
    [self loadIncludedResources];
    return self.rootView;
}

-(void) loadIncludedResources {
    [self loadScripts];
    [self loadIncludeViews];
    
    if (self.includeViewList.count == 0 && self.scriptList.count == 0) {
        [self checkAndCompleteProcess];
    }
}

-(void) loadIncludeViews {
    for (UPIncludeViewInfo* viewInfo in self.includeViewList) {
        UPViewParser* parser = [[UPViewParser alloc] init];
        parser.contextPath = viewInfo.resourcePath;
        parser.rootPath = self.rootPath;
        parser.resourceLoader = self.resourceLoader;
        parser.callback = ^(UIView* view) {
            [viewInfo.container addSubview:view];
            viewInfo.content = view;
            [self checkAndCompleteProcess];
        };
        [parser parse];
    }
}

-(void) loadScripts {
    for (UPScriptInfo* script in self.scriptList) {
        [self.resourceLoader loadResource:script.resourcePath callback:^(NSData *data) {
            script.content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self checkAndCompleteProcess];
        }];
    }
}

-(void) checkAndCompleteProcess {
    for (UPScriptInfo* script in self.scriptList) {
        if (script.content == nil) {
            // script not ready now
            return;
        }
    }
    
    for (UPIncludeViewInfo* viewInfo in self.includeViewList) {
        if (viewInfo.content == nil) {
            // include View not ready
            return;
        }
    }
    
    [self runScripts];
    
    if (self.callback != nil) {
        self.callback(self.rootView);
    }
}

-(void) runScripts {
    for (UPScriptInfo* script in self.scriptList) {
        [UPView evaluate:script.content];
    }
    [self.rootView runEntryJSFunction:[self entryJSFunctionName]];
}

-(NSString*) entryJSFunctionName {
    NSString* lastComponent = [self.contextPath lastPathComponent];
    return [lastComponent substringToIndex:lastComponent.length - 4];
}


@end
