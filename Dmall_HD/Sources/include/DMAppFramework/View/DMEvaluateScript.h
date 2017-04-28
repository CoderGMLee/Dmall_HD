//
//  DMEvaluateScript.h
//  DMAppFramework
//
//  Created by chenxinxin on 15/11/16.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DMEvaluateScript <NSObject>
-(NSString*) evaluateScript:(NSString*) script;
@end
