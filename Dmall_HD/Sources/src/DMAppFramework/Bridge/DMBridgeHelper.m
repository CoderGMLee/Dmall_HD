//
//  DMBridgeHelper.m
//  DMTools
//
//  Created by chenxinxin on 15/10/21.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "DMBridgeHelper.h"
#import "DMBridgeObject.h"
#import "UPView.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "DMWeakify.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "DMStringUtils.h"
#import "DMLog.h"

union ArgDef {
    char charValue;
    unsigned char unsignedChar;
    short shortValue;
    unsigned short unsignedShortValue;
    long longValue;
    unsigned long unsignedLongValue;
    int intValue;
    unsigned int unsignedIntValue;
    float floatValue;
    double doubleValue;
    BOOL boolValue;
    long long longLongValue;
    unsigned long long unsignedLongLongValue;
};

@interface DMBridgeHolder : NSObject
@property (strong,nonatomic) id<DMBridgeProtocol> bridgeObject;

@property (strong,nonatomic) NSMutableDictionary* methodMap;
-(void) registBridgeScripts : (UIWebView*) webView ;
-(void) registToUPView:(UPView*) upView ;
-(NSString*) invokeFromJavascript : (NSString*) methodName WithParam:(NSArray*) param;
-(NSString*) key;
@end


@implementation DMBridgeHolder




-(NSMutableDictionary*) methodMap {
    if(self->_methodMap == nil) {
        self.methodMap = [[NSMutableDictionary alloc] init];
    }
    return self->_methodMap;
}

-(NSString*) key {
    return self.bridgeObject.javascriptObjectName;
}

-(NSString*) concat:(NSArray*)components to:(unsigned long)index {
    NSMutableString* buffer = [[NSMutableString alloc] init];
    for (int i = 0 ; i < index; i++) {
        [buffer appendString:components[i]];
        if (i < index - 1) {
            [buffer appendString:@"."];
        }
    }
    return buffer;
}

-(JSValue*) prepareObjectInUPView:(UPView*) upView {
    NSString* key = self.key;
    NSArray* components = [key componentsSeparatedByString:@"."];
    // 最后一个名字的对象不需要生成
    for (int i = 0 ; i < components.count-1; i++) {
        NSString* objname = [self concat:components to:i+1];
        [upView evaluateScript:[NSString stringWithFormat:@"if (\"undefined\" == typeof %@) {%@={};}",objname,objname]];
    }
    return [UPView evaluate:[self concat:components to:components.count-1]];
}

-(void) registToUPView:(UPView*) upView {
    JSValue* value = [self prepareObjectInUPView:upView];
    if (value != nil) {
        NSArray* components = [self.key componentsSeparatedByString:@"."];
        NSString* lastName = [components lastObject];
        value[lastName] = self.bridgeObject;
    }
}

-(void) registBridgeScripts : (UIWebView*) webView {
    NSMutableString* buffer = [[NSMutableString alloc] init];
    [buffer appendString:@"(function(){"];
    
    [buffer appendString:@"\n\
     function EncodeUtf8(s1)\n\
     {\n\
         if(s1==null){return "";}\n\
         var s = escape(s1);\n\
         var sa = s.split(\"%\");\n\
         var retV =\"\";\n\
         if(sa[0] != \"\")\n\
         {\n\
             retV = sa[0];\n\
         }\n\
         for(var i = 1; i < sa.length; i ++)\n\
         {\n\
             if(sa[i].substring(0,1) == \"u\")\n\
             {\n\
                 retV += Hex2Utf8(Str2Hex(sa[i].substring(1,5)));\n\
                 if(sa[i].length>=6)\n\
                 {\n\
                     retV += sa[i].substring(5);\n\
                 }\n\
             }\n\
             else retV += \"%\" + sa[i];\n\
         }\n\
         return retV;\n\
     }\n\
     function Str2Hex(s)\n\
     {\n\
         var c = \"\";\n\
         var n;\n\
         var ss = \"0123456789ABCDEF\";\n\
         var digS = \"\";\n\
         for(var i = 0; i < s.length; i ++)\n\
         {\n\
             c = s.charAt(i);\n\
             n = ss.indexOf(c);\n\
             digS += Dec2Dig(eval(n));\n\
         }\n\
         return digS;\n\
     }\n\
     function Dec2Dig(n1)\n\
     {\n\
         var s = \"\";\n\
         var n2 = 0;\n\
         for(var i = 0; i < 4; i++)\n\
         {\n\
             n2 = Math.pow(2,3 - i);\n\
             if(n1 >= n2)\n\
             {\n\
                 s += '1';\n\
                 n1 = n1 - n2;\n\
             }\n\
             else\n\
                 s += '0';\n\
         }\n\
         return s;\n\
     }\n\
     function Dig2Dec(s)\n\
     {\n\
         var retV = 0;\n\
         if(s.length == 4)\n\
         {\n\
             for(var i = 0; i < 4; i ++)\n\
             {\n\
                 retV += eval(s.charAt(i)) * Math.pow(2, 3 - i);\n\
             }\n\
             return retV;\n\
         }\n\
         return -1;\n\
     }\n\
     function Hex2Utf8(s)\n\
     {\n\
         var retS = \"\";\n\
         var tempS = \"\";\n\
         var ss = \"\";\n\
         if(s.length == 16)\n\
         {\n\
             tempS = \"1110\" + s.substring(0, 4);\n\
             tempS += \"10\" +  s.substring(4, 10);\n\
             tempS += \"10\" + s.substring(10,16);\n\
             var sss = \"0123456789ABCDEF\";\n\
             for(var i = 0; i < 3; i ++)\n\
             {\n\
                 retS += \"%\";\n\
                 ss = tempS.substring(i * 8, (eval(i)+1)*8);\n\
                 retS += sss.charAt(Dig2Dec(ss.substring(0,4)));\n\
                 retS += sss.charAt(Dig2Dec(ss.substring(4,8)));\n\
             }\n\
             return retS;\n\
         }\n\
         return \"\";\n\
     }\n\
     function EncodeParam(p){\n\
        if(p==null){\n\
            return "";\n\
        }\n\
        return escape(EncodeUtf8(p));\n\
     }\n\
     "];
    
    
    for (NSUInteger i = 0; i < self.key.length; ) {
        NSRange range = [self.key rangeOfString:@"." options:NSLiteralSearch range:NSMakeRange(i, self.key.length-i)];
        if(range.location == NSNotFound) {
            break;
        }
        NSString* path = [self.key substringToIndex:range.location];
        [buffer appendFormat:@"if(typeof(%@)=='undefined'){%@={};};",path,path];
        i = range.location + 1;
        if(i>self.key.length-1){
            break;
        }
    }
    [buffer appendString:self.key];
    [buffer appendString:@"={"];

    
    __block BOOL first = YES;
    
    @weakify_self
    @weakify(buffer)
    [self walkBridgeSelector:self.bridgeObject callback:^(SEL sel) {
        @strongify_self
        @strongify(buffer)
        int argCount = [self argsCountForSelector:sel];
        
        if (first) {
            first = NO;
        } else {
            [strong_buffer appendString:@",\n"];
        }
        NSMethodSignature* methodSign = [[self.bridgeObject class] instanceMethodSignatureForSelector:sel];
        const char* methodRetType = [methodSign methodReturnType];
        NSString* methodName = [self methodNameFromSelector:sel];
        [strong_buffer appendFormat:@"%@:function(",methodName];
        for(int j = 0 ; j < argCount ; j++) {
            [strong_buffer appendFormat:@"arg%d",j];
            if(j < argCount-1) {
                [strong_buffer appendString:@","];
            }
        }
        [strong_buffer appendString:@"){\n"];
        [strong_buffer appendString:@"var request = new XMLHttpRequest();\n"];
        [strong_buffer appendFormat:@"var arg = \"{\\\"obj\\\":\\\"%@\\\",\\\"method\\\": \\\"%@\\\",\\\"param\\\":[",self.key,methodName];
        for(int j = 0 ; j < argCount ; j++) {
            
            [strong_buffer appendFormat:@"\\\"\"+EncodeParam(arg%d)+\"\\\"",j];
            if(j < argCount-1) {
                [strong_buffer appendString:@","];
            }
        }
        [strong_buffer appendFormat:@"]}\";\n"];
        [strong_buffer appendString:@"request.open('HEAD', \"/!lightapp/\"+arg, false);\n"];
        [strong_buffer appendFormat:@"request.send(null);\n"];
        if (strcmp(methodRetType, "@") == 0) {
            [strong_buffer appendString:@"return \"[[nil]]\"==request.responseText?null:request.responseText;\n"];
        }
        else if(strcmp(methodRetType,"v") != 0){
            [strong_buffer appendString:@"return Number(request.responseText);\n"];
        }
        
        [strong_buffer appendString:@"}\n"];
    }];
    
    [buffer appendString:@"};\n"];
    
    [buffer appendString:@"})();\n"];
    
    [webView stringByEvaluatingJavaScriptFromString:buffer];
}

-(void) walkBridgeSelector:(id<DMBridgeProtocol>)bridgeObject  callback: (void(^)(SEL select)) walker {
    unsigned int protocolCount = 0;
    Protocol *__unsafe_unretained* protocols = class_copyProtocolList([bridgeObject class], &protocolCount);
    
    for (int i = 0; i < protocolCount; i++) {
        Protocol* protocol = protocols[i];
        
        if (!protocol_conformsToProtocol(protocol, @protocol(JSExport))) {
            continue;
        }
        
        unsigned int methodCount = 0;
        struct objc_method_description * methods = protocol_copyMethodDescriptionList(protocol,YES,YES,&methodCount);
        for (int j = 0 ; j < methodCount; j++) {
            SEL sel = methods[j].name;
            walker(sel);
        }
        free(methods);
    }
    free(protocols);
}

-(NSString*) methodNameFromSelector:(SEL)selector {
    NSString* selectorName = NSStringFromSelector(selector);
    NSString* javascriptMethodName = [self javascriptMethodNameForSelect:selector];
    [self.methodMap setObject:selectorName forKey:javascriptMethodName];
    return javascriptMethodName;
}

-(NSString*) javascriptMethodNameForSelect:(SEL) selector {
    NSString* selectorName = NSStringFromSelector(selector);
    NSMutableString* buffer = [[NSMutableString alloc] init];
    NSArray* eles = [selectorName componentsSeparatedByString:@":"];
    for (int i = 0 ; i < eles.count ; i++) {
        NSString* ele = eles[i];
        if (i == 0) {
            [buffer appendString:ele];
        } else {
            [buffer appendString:[DMStringUtils firstToUpper:ele]];
        }
    }
    return buffer;
}

-(SEL) methodFromName : (NSString*) name {
    NSString* selectorName = [self.methodMap objectForKey:name];
    return NSSelectorFromString(selectorName);
}

-(NSString*) argDefToString:(union ArgDef)arg With:(const char*) type {
    if (strcmp(type, "c") == 0) {
        return [NSString stringWithFormat:@"%c",arg.charValue];
    }
    if (strcmp(type, "i") == 0) {
        return [NSString stringWithFormat:@"%d",arg.intValue];
    }
    if (strcmp(type, "I") == 0) {
        return [NSString stringWithFormat:@"%u",arg.unsignedIntValue];
    }
    if (strcmp(type, "s") == 0) {
        return [NSString stringWithFormat:@"%d",arg.shortValue];
    }
    if (strcmp(type, "S") == 0) {
        return [NSString stringWithFormat:@"%u",arg.unsignedShortValue];
    }
    if (strcmp(type, "l") == 0) {
        return [NSString stringWithFormat:@"%ld",arg.longValue];
    }
    if (strcmp(type, "L") == 0) {
        return [NSString stringWithFormat:@"%lu",arg.unsignedLongValue];
    }
    if (strcmp(type, "f") == 0) {
        return [NSString stringWithFormat:@"%f",arg.floatValue];
    }
    if (strcmp(type, "d") == 0) {
        return [NSString stringWithFormat:@"%f",arg.doubleValue];
    }
    if (strcmp(type, "B") == 0) {
        return [NSString stringWithFormat:@"%d",arg.boolValue];
    }
    if (strcmp(type, "q") == 0) {
        return [NSString stringWithFormat:@"%lld",arg.longLongValue];
    }
    if (strcmp(type, "Q") == 0) {
        return [NSString stringWithFormat:@"%llu",arg.unsignedLongLongValue];
    }
    return @"";
}

-(union ArgDef) convertBasicArg:(NSString*)value With:(const char*) type {
    union ArgDef ret;
    if (strcmp(type, "c") == 0) {
        ret.charValue = [value characterAtIndex:0];
        if ([@"true" isEqualToString:value] || [@"false" isEqualToString:value]) {
            ret.boolValue = [value boolValue];
        }
        return ret;
    }
    if (strcmp(type, "i") == 0) {
        ret.intValue = [value intValue];
        return ret;
    }
    if (strcmp(type, "I") == 0) {
        ret.unsignedIntValue = (unsigned int)[value intValue];
        return ret;
    }
    if (strcmp(type, "s") == 0) {
        ret.shortValue = [value intValue];
        return ret;
    }
    if (strcmp(type, "S") == 0) {
        ret.unsignedShortValue = [value intValue];
        return ret;
    }
    if (strcmp(type, "l") == 0) {
        ret.longValue = [value longLongValue];
        return ret;
    }
    if (strcmp(type, "L") == 0) {
        ret.unsignedLongLongValue = [value longLongValue];
        return ret;
    }
    if (strcmp(type, "f") == 0) {
        ret.floatValue = [value floatValue];
        return ret;
    }
    if (strcmp(type, "d") == 0) {
        ret.doubleValue = [value doubleValue];
        return ret;
    }
    if (strcmp(type, "B") == 0) {
        ret.boolValue = [value boolValue];
        return ret;
    }
    if (strcmp(type, "q") == 0) {
        ret.longLongValue = [value longLongValue];
        return ret;
    }
    
    return ret;
}

-(int) argsCountForSelector:(SEL) selector {
    NSMethodSignature* methodSign = [[self.bridgeObject class] instanceMethodSignatureForSelector:selector];
    return (int)(methodSign.numberOfArguments - 2);
}

+ (NSString *)decodeFromPercentEscapeString: (NSString *) input
{
    return [input stringByRemovingPercentEncoding];
}

-(NSString*) invokeFromJavascript : (NSString*) methodName WithParam:(NSArray*) param {
    SEL selector = [self methodFromName:methodName];
    NSMethodSignature* methodSign = [[self.bridgeObject class] instanceMethodSignatureForSelector:selector];
    NSInvocation* invo = [NSInvocation invocationWithMethodSignature:methodSign];
    [invo setSelector:selector];
    NSMutableArray* buffer = [[NSMutableArray alloc] init];
    unsigned long argCount = methodSign.numberOfArguments - 2;
    for(int i = 0; i < argCount ; i++) {
        unsigned int index = i + 2;
        const char * argType = [methodSign getArgumentTypeAtIndex:index];
        NSString* argValue = [DMBridgeHolder decodeFromPercentEscapeString:param[i]];
        if (!argValue) {
            continue;
        }
        if (strcmp(argType, "@") == 0) {
            NSString* arg = argValue;
            [invo setArgument:&arg atIndex:index];
            [buffer addObject:arg];
        } else {
            [buffer addObject:argValue];
            union ArgDef arg = [self convertBasicArg:argValue With:argType];
            [invo setArgument:&arg atIndex:index];
        }
    }
    
    [invo invokeWithTarget:self.bridgeObject];
    const char* methodRetType = [methodSign methodReturnType];
    if (strcmp(methodRetType, "@") == 0) {
        void* retObject;
        [invo getReturnValue:&retObject];
        NSString* ret = (__bridge NSString*)retObject;
        return ret;
    }
    else if(strcmp(methodRetType,"v") != 0){
        union ArgDef value;
        [invo getReturnValue:&value];
        return [self argDefToString:value With:methodRetType];
    }
    return @"";
}
@end

@interface DMBridgeHelper()
@property (strong,nonatomic) NSMutableDictionary* bridgeMap;
@property (strong,nonatomic) UIWebView* webView;
@property (strong,nonatomic) UPView* upView;
@end

@implementation DMBridgeHelper


DMLOG_DEFINE(DMBridgeHelper)

+(void) initialize {
    [NSURLProtocol registerClass:[self class]];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

-(instancetype) init {
    if(self = [super init]) {
        self.bridgeMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void) registBridge:(id<DMBridgeProtocol>) bridgeObject  {
    DMBridgeHolder* helper = [[DMBridgeHolder alloc] init];
    helper.bridgeObject = bridgeObject;
    [self.bridgeMap setObject:helper forKey:helper.key];
}

-(void) bindWebView:(UIWebView*) webView {
    self.webView = webView;
    NSDictionary *bridgeMap = [self bridgeMap];
    for (id key in bridgeMap) {
        DMBridgeHolder *helper = [bridgeMap objectForKey:key]; 
        if (self.webView != nil){
            [helper registBridgeScripts:self.webView];
        }
    }
}

-(void) bindUPView:(UPView*) upView {
    self.upView = upView;
    NSDictionary *bridgeMap = [self bridgeMap];
    for (id key in bridgeMap) {
        DMBridgeHolder *helper = [bridgeMap objectForKey:key];
        if (self.upView != nil){
            [helper registToUPView:self.upView];
        }
    }
}

-(instancetype) initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client {
    if(self = [super initWithRequest:request cachedResponse:cachedResponse client:client]){
    }
    return self;
}

-(void) startLoading {
    NSString *responseData  = nil;
    NSString* url           = self.request.URL.absoluteString;
    
    if (url == nil) {
        return;
    }
    
    NSRange range           = [url rangeOfString:@"/!lightapp/"];
    

    
    if (range.location != NSNotFound) {
        DMDebug(@"I Got URL: %@",url);
        NSString* content = [DMBridgeHolder decodeFromPercentEscapeString:[url substringFromIndex:(range.location+range.length)]];
        NSError* error;
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic != nil) {
            NSString* obj       = [dic objectForKey:@"obj"];
            NSString* method    = [dic objectForKey:@"method"];
            NSArray* param      = [dic objectForKey:@"param"];
            
            DMBridgeHolder* bridgeHelper = [[[DMBridgeHelper getInstance] bridgeMap] objectForKey:obj];
            if (bridgeHelper) {
                responseData = [bridgeHelper invokeFromJavascript:method WithParam:param];
            }
        }
    }
    
    NSData* data = [@"[[nil]]" dataUsingEncoding:NSUTF8StringEncoding];
    if(responseData != nil) {
        data = [responseData dataUsingEncoding:NSUTF8StringEncoding];
    }
    NSURLResponse* response = [[NSURLResponse alloc] initWithURL:self.request.URL MIMEType:@"text/plain" expectedContentLength:data.length textEncodingName:@"UTF-8"];
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [self.client URLProtocol:self didLoadData:data];
    [self.client URLProtocolDidFinishLoading:self];
}

-(void) stopLoading {
}

+(BOOL) canInitWithRequest:(NSURLRequest *)request {
    NSString* url = request.URL.absoluteString;
    
    if (url == nil) {
        return NO;
    }
    
    NSRange range = [url rangeOfString:@"/!lightapp/"];
    if (range.location != NSNotFound) {
        return YES;
    }
    return NO;
}

DMBridgeHelper* DMBridgeHelper_instance = nil;

+(DMBridgeHelper*) getInstance {
    if (DMBridgeHelper_instance == nil) {
        DMBridgeHelper_instance = [[DMBridgeHelper alloc] init];
    }
    return DMBridgeHelper_instance;
}

@end
