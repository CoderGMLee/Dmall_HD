//
//  DMLRUCache.h
//  DMAppFramework
//
//  Created by chenxinxin on 15/11/4.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMLRUCache : NSObject
-(instancetype) initWithCap:(int)size;

-(void) setObject:(id)value forKey:(NSString*)key;
-(id) objectForKey:(NSString*)key;
-(void) remove:(NSString*)key;
@end
