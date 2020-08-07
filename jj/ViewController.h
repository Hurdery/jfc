//
//  ViewController.h
//  jj
//
//  Created by LY_MD on 2020/7/17.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DataManager.h"
#import "NSMenuTableView.h"

@interface ViewController : NSViewController<NSTabViewDelegate,NSTableViewDataSource,MenuHandleDelegate,NSTextFieldDelegate>

@property (weak) IBOutlet NSTextField *codeTf;
@property (weak) IBOutlet NSButton *addBtn;
@property (weak) IBOutlet NSMenuTableView *codeTableV;
@property (weak) IBOutlet NSButton *autoRefreshBtn;
@property (weak) IBOutlet NSTextField *huLabel;
@property (weak) IBOutlet NSTextField *shangLabel;
@property (weak) IBOutlet NSTextField *shenLabel;
@property (weak) IBOutlet NSTextField *hu1Label;
@property (weak) IBOutlet NSTextField *shang1Label;
@property (weak) IBOutlet NSTextField *shen1Label;
@property (weak) IBOutlet NSImageView *huImage;
@property (weak) IBOutlet NSImageView *shangImage;
@property (weak) IBOutlet NSImageView *shenImage;
@property (weak) IBOutlet NSTextField *totolLabel;
@property(nonatomic,assign) SourceType st;

/// 存放持仓数据
@property (nonatomic, strong) NSMutableDictionary *ccDic;

/// 自动刷新
@property (nonatomic, strong) dispatch_source_t timer;

/// 数据
@property(nonatomic,strong)NSMutableArray <FundModel *>*modelsAry;

@end

