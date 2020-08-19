//
//  NSMenuTableView.h
//  jj
//
//  Created by LY_MD on 2020/7/23.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol MenuHandleDelegate <NSObject>

- (void)tableView:(NSTableView *)tableView didClickMenuDelete:(NSInteger)row;
- (void)tableView:(NSTableView *)tableView didClickMenuDetail:(NSInteger)row;

@end

@interface NSMenuTableView : NSTableView
@property(nonatomic,weak)id <MenuHandleDelegate>mhdelegate;
@end

