//
//  DMLRUCache.m
//  DMAppFramework
//
//  Created by chenxinxin on 15/11/4.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "DMLRUCache.h"


@interface DMLRUEntry : NSObject
@property (strong,nonatomic) NSString* key;
@property (strong,nonatomic) id value;
@end

@implementation DMLRUEntry
@end

@interface DMLRUCache()
@property (strong,nonatomic) NSMutableDictionary* dictionary;
@property (strong,nonatomic) NSMutableArray* entryList;
@property (assign,nonatomic) int cap;
@end

@implementation DMLRUCache

-(instancetype) initWithCap:(int)size {
    if(self = [super init]) {
        self.cap = size;
    }
    return self;
}

-(NSMutableDictionary*) dictionary {
    if(self->_dictionary == nil) {
        self->_dictionary = [[NSMutableDictionary alloc] init];
    }
    return self->_dictionary;
}

-(NSMutableArray*) entryList {
    if (self->_entryList == nil) {
        self->_entryList = [[NSMutableArray alloc] init];
    }
    return self->_entryList;
}


-(void) setObject:(id)value forKey:(NSString*)key {
    // 删除可能重复的数据
    [self remove:key];
    
    if (self.entryList.count >= self.cap) {
        [self removeOldeast];
    }
    
    [self.dictionary setObject:value forKey:key];
    DMLRUEntry* entry = [[DMLRUEntry alloc] init];
    entry.key = key;
    entry.value = value;
    [self.entryList addObject:entry];
}
-(id) objectForKey:(NSString*)key {
    return [self.dictionary objectForKey:key];
}

-(void) removeOldeast {
    if (self.entryList.count == 0) {
        return;
    }
    DMLRUEntry* first = self.entryList[0];
    [self remove:first.key];
}

-(void) remove:(NSString*)key {
    [self.dictionary removeObjectForKey:key];
    for (int i = 0 ; i < self.entryList.count ; i++) {
        DMLRUEntry* entry = self.entryList[i];
        if ([key isEqualToString:entry.key]) {
            [self.entryList removeObjectAtIndex:i];
            break;
        }
    }
}
@end
