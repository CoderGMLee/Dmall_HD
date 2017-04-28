//
//  UPViewUpdator.m
//  DMAppFramework
//
//  Created by chenxinxin on 15/12/16.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "UPViewUpdator.h"
#import "UPView.h"
#import "UPPathUtil.h"
#import "DMLog.h"
#import "UPNetLoader.h"

@interface UPUpdateScriptInfo : NSObject
@property (strong,nonatomic) NSString* resourcePath;
@property (strong,nonatomic) NSString* content;
@end

@implementation UPUpdateScriptInfo
@end

@interface UPUpdateIncludeViewInfo : NSObject
@property (strong,nonatomic) NSString* resourcePath;
@property (assign,nonatomic) BOOL success;
@end

@implementation UPUpdateIncludeViewInfo
@end

@interface UPViewUpdator() <NSXMLParserDelegate,UPResourceLocator>
@property (strong,nonatomic) NSXMLParser* xmlParser;
@property (strong,nonatomic) NSMutableDictionary* scriptList;
@property (strong,nonatomic) NSMutableDictionary* includeViewList;
@end

@implementation UPViewUpdator


DMLOG_DEFINE(UPViewUpdator)

-(NSMutableDictionary*) scriptList {
    if (self->_scriptList == nil) {
        self->_scriptList = [[NSMutableDictionary alloc] init];
    }
    return self->_scriptList;
}

-(NSMutableDictionary*) includeViewList {
    if (self->_includeViewList == nil) {
        self->_includeViewList = [[NSMutableDictionary alloc] init];
    }
    return self->_includeViewList;
}


-(NSString*) locateResource : (NSString*)path {
    return [UPPathUtil resolveWithRootPath:self.rootPath contextPath:self.contextPath relativePath:path];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([@"Script" isEqualToString:elementName]) {
        UPUpdateScriptInfo* script = [[UPUpdateScriptInfo alloc] init];
        script.resourcePath = [self locateResource:[attributeDict objectForKey:@"src"]];
        [self.scriptList setObject:script forKeyedSubscript:script.resourcePath];
        return;
    }
    
    if ([@"View" isEqualToString:elementName] && [attributeDict objectForKey:@"src"] != nil) {
        // 如果是需要include方式加载
        UPUpdateIncludeViewInfo* viewInfo = [[UPUpdateIncludeViewInfo alloc] init];
        viewInfo.resourcePath = [self locateResource:[attributeDict objectForKey:@"src"]];
        [self.includeViewList setObject:viewInfo forKeyedSubscript:viewInfo.resourcePath];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
}

-(void) update {
    [self.resourceLoader loadResponse:self.contextPath callback:^(DMBytesResponse *res) {
        if (res.statusCode == 200) {
            [self parseData:res.data];
        }
    }];
}

-(void) parseData:(NSData*) data{
    if (data == nil) {
        DMError(@"load root xml failed %@",self.contextPath);
        [self reportFailed];
        return;
    }
    
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    [parser parse];
    [self loadIncludedResources];
}

-(void) loadIncludedResources {
    if (DMDebugEnabled()) {
        NSMutableString* buffer = [[NSMutableString alloc] init];
        [buffer appendFormat:@"will load resource list for : %@\n",self.contextPath];
        for (NSString* key in self.scriptList) {
            UPUpdateScriptInfo* scriptInfo = [self.scriptList objectForKey:key];
            [buffer appendFormat:@"    Script => %@\n",scriptInfo.resourcePath];
        }
        for (NSString* key in self.includeViewList) {
            UPUpdateIncludeViewInfo* viewInfo = [self.includeViewList objectForKey:key];
            [buffer appendFormat:@"    View => %@\n",viewInfo.resourcePath];
        }
        DMDebug(buffer);
    }
    
    [self loadScripts];
    [self loadIncludeViews];
    
    if (self.includeViewList.count == 0 && self.scriptList.count == 0) {
        [self checkAndCompleteProcess];
    }
}

-(void) loadIncludeViews {
    for (NSString* key in self.includeViewList) {
        UPUpdateIncludeViewInfo* viewInfo = [self.includeViewList objectForKey:key];
        UPViewUpdator* updator = [[UPViewUpdator alloc] init];
        updator.contextPath = viewInfo.resourcePath;
        updator.rootPath = self.rootPath;
        updator.resourceLoader = self.resourceLoader;
        updator.callback = ^(BOOL succ) {
            viewInfo.success = succ;
            if (!succ) {
                DMError(@"load include view failed : %@",viewInfo.resourcePath);
                [self reportFailed];
                return;
            }
            [self checkAndCompleteProcess];
        };
        [updator update];
    }
}

-(void) reportFailed {
    if (self.callback) {
        self.callback(NO);
    }
}

-(void) loadScripts {
    for (NSString* key in self.scriptList) {
        UPUpdateScriptInfo* script = [self.scriptList objectForKey:key];
        [self.resourceLoader loadResource:script.resourcePath callback:^(NSData *data) {
            if (data == nil) {
                DMError(@"load include script failed : %@",script.resourcePath);

                [self reportFailed];
                return;
            }
            script.content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self checkAndCompleteProcess];
        }];
    }
}

-(void) checkAndCompleteProcess {
    for (NSString* key in self.scriptList) {
        UPUpdateScriptInfo* script = [self.scriptList objectForKey:key];
        if (script.content == nil) {
            // script not ready now
            return;
        }
    }
    
    for (NSString* key in self.includeViewList) {
        UPUpdateIncludeViewInfo* viewInfo = [self.includeViewList objectForKey:key];
        if (!viewInfo.success) {
            // include View not ready
            return;
        }
    }
    
    DMDebug(@"update page success => %@",self.contextPath);
    
    if (self.callback != nil) {
        self.callback(YES);
    }
}


@end