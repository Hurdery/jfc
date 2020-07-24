//
//  ViewController.h
//  jj
//
//  Created by LY_MD on 2020/7/17.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NetTool.h"
#import "NSMenuTableView.h"

@interface ViewController : NSViewController<NSTabViewDelegate,NSTableViewDataSource,MenuHandleDelegate>
@property (weak) IBOutlet NSTextField *codeTf;
@property (weak) IBOutlet NSButton *addBtn;
@property (weak) IBOutlet NSMenuTableView *codeTableV;
@property (weak) IBOutlet NSButton *autoRefreshBtn;
@property (nonatomic, strong) dispatch_source_t timer;

/// 数据
@property(nonatomic,strong)NSMutableArray <FundModel *>*modelsAry;

@end

