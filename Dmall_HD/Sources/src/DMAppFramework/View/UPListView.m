//
//  UPListView.m
//  DMAppFramework
//
//  Created by chenxinxin on 15/11/18.
//  Copyright (c) 2015年 dmall. All rights reserved.
//

#import "UPListView.h"
#import "DMPullToRefreshView.h"
#import "UPView+Private.h"
#import <UIKit/UIKit.h>


@interface UPListView() <UITableViewDelegate,UITableViewDataSource,DMPullToRefreshViewDelegate>
@property (nonatomic,strong) NSMutableArray* templateList;
@property (nonatomic,strong) DMPullToRefreshView* pulltoRefreshView;
@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) NSString* data;
@property (nonatomic,strong) JSValue* jsData;
@property (nonatomic,strong) NSString* onPull;
@end

@implementation UPListView


-(instancetype) init {
    if (self = [super init]) {
        
        self.pulltoRefreshView = [[DMPullToRefreshView alloc] init];
        
        self.tableView = [[UITableView alloc] init];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        self.pulltoRefreshView.scrollView = self.tableView;
        self.pulltoRefreshView.delegate = self;
        [super addSubview:self.pulltoRefreshView];
    }
    return self;
}

-(void) setHeaderBackgroundImage : (NSString*) spec {
    NSString* resourcePath = [self.resourceLocator locateResource:spec];
    [self.resourceLoader loadResource:resourcePath callback:^(NSData *data) {
        self.pulltoRefreshView.headerBackgroundImage = [UIImage imageWithData:data];
    }];
}
-(void) setHeaderArrowImage : (NSString*) spec {
    NSString* resourcePath = [self.resourceLocator locateResource:spec];
    [self.resourceLoader loadResource:resourcePath callback:^(NSData *data) {
        self.pulltoRefreshView.headerArrowImage = [UIImage imageWithData:data];
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.jsData == nil) {
        return 0;
    }
    JSValue* length = self.jsData[@"length"];
    return [length toInt32];
}

-(BOOL) isCellMatched:(UPView*)template jsObject:(JSValue*)object {
    NSString* match = template.match;
    NSString* field = nil;
    NSRange start = [match rangeOfString:@"${"];
    NSRange searchRange = NSMakeRange(0, match.length);
    if (start.location != NSNotFound) {
        searchRange.location = start.location + 2;
        searchRange.length = match.length - start.location - 2;
    }
    
    NSRange stop = [match rangeOfString:@"}" options:0 range:searchRange];
    if (start.location == NSNotFound || stop.location == NSNotFound || stop.location < start.location) {
        return NO;
    }
    field = [match substringWithRange:NSMakeRange(start.location+2, stop.location-start.location-2)];
    JSValue* fieldValue = [self getValueFromJSObject:object byExpression:field];
    NSString* valueString = [fieldValue toString];
    if([fieldValue isString]) {
        valueString = [NSString stringWithFormat:@"'%@'",valueString];
    }
    NSString* compareScript = [NSString stringWithFormat:@"%@%@%@",[match substringToIndex:start.location],valueString,[match substringFromIndex:stop.location+1]];
    JSValue* ret = [[UPView globalJSContext] evaluateScript:compareScript];
    return [ret toBool];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JSValue* rowData = self.jsData[indexPath.row];
    
    UPView* template = nil;
    for (UPView* view in self.templateList) {
        if([self isCellMatched:view jsObject:rowData]){
            template = view;
            //[cellView populateByJSData:rowData];
            break;
        }
    }
    
    if (template == nil) {
        // TODO: report error for template not found
        UITableViewCell* cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:template.match];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UPView* cellView = [template deepClone];
        [cellView layoutSubviews];
        [cell.contentView addSubview:cellView];
    }
    
  
    UPView* cellView = cell.contentView.subviews.lastObject;
    [cellView populatePageData:rowData];
    cellView.frame = CGRectMake(0, 0, tableView.frame.size.width, [cellView measureHeight]);
    [cellView layoutSubviews];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    JSValue* rowData = self.jsData[indexPath.row];
    UPView* cellView = nil;
    for (UPView* view in self.templateList) {
        if([self isCellMatched:view jsObject:rowData]){
            cellView = view;
            [cellView populatePageData:rowData];
            break;
        }
    }
    CGFloat height = [cellView measureHeight];
    return height;
}

-(void) populate : (JSValue*)param {
    self.jsData = param;
    [self.tableView reloadData];
}


-(void) populatePageData:(JSValue*) value {
    for (NSString* property in self.populateParams) {
        NSString* expression = [self.populateParams objectForKey:property];
        JSValue* jsValue = [self getValueFromJSObject:value byExpression:expression];
        if (jsValue != nil) {
            if ([@"data" isEqualToString:property]) {
                self.jsData = jsValue;
            } else {
                [self injectValue:[jsValue toString] forProperty:property];
            }
        }
    }
}

-(void) setPullEnable : (NSString*) spec {
    self.pulltoRefreshView.pullEnable = [UPView parseBoolean:spec];
}


-(void)pullToRefreshView:(DMPullToRefreshView*)pullToRefreshView notifyRefresh:(BOOL)refresh {
    if (refresh) {
        if (self.onPull != nil) {
            [self invokeJSMethod:self.onPull];
        }
    }
}


-(void) layoutSubviews {
    self.pulltoRefreshView.frame = self.bounds;
}


-(NSMutableArray*) templateList {
    if (self->_templateList == nil) {
        self->_templateList = [[NSMutableArray alloc] init];
    }
    return self->_templateList;
}

-(void)addSubview:(UIView *)view {
    [self.templateList addObject:view];
}

@end
