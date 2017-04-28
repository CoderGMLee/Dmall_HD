//
//  DMDateUtil.m
//  DMAppFramework
//
//  Created by chenxinxin on 15/12/16.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "DMDateUtil.h"

@implementation DMDateUtil

+(NSString*) formatTimeMillsSince1970:(long long)time {
    NSDate* date = [[NSDate alloc] initWithTimeIntervalSince1970:time/1000];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    return currentDateStr;
}

@end
