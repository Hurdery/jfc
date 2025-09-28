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
#import "LocalFundParser.h"
#import "LocalFundModel.h"
#import "AlertTool.h"
#import "FundJZWC.h"

@interface ViewController : NSViewController<NSTableViewDelegate,NSTableViewDataSource,MenuHandleDelegate,NSTextFieldDelegate,NSControlTextEditingDelegate>

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
@property (weak) IBOutlet NSTextField *allMoneyLabel;
@property (weak) IBOutlet NSButton *eyeBtn;
@property (weak) IBOutlet NSButton *updateBtn;

/// 当前选区索引
@property(nonatomic,assign) NSInteger sourceIndex;
/// 选区
@property(nonatomic,assign) SourceType st;
/// 总收益
@property(nonatomic,copy) NSString *zsyStr;
/// 总投资
@property(nonatomic,copy) NSString *ztzStr;
/// 存放持仓数据
@property (nonatomic, strong) NSMutableDictionary *ccDic;
/// 自动刷新
@property (nonatomic, strong) dispatch_source_t timer;
/// 数据
@property(nonatomic,strong)NSMutableArray <FundModel *>*modelsAry;
/// 指示器
@property(nonatomic,strong)NSProgressIndicator *indicator;
/// 本地基金数据
@property (nonatomic, strong) NSMutableArray<LocalFundModel *> *allSuggestions;
/// 匹配到的基金数据
@property (nonatomic,strong) NSArray<LocalFundModel *> *matchSuggestions;
/// 根据输入词实时显示建议
@property (nonatomic,strong) NSPopover *suggestionPopover;
/// 智能匹配列表
@property (nonatomic,strong) NSTableView *suggestionTableV;
@end

