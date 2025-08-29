//
//  ViewController.m
//  jj
//
//  Created by LY_MD on 2020/7/17.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import "ViewController.h"
#import "AlertTool.h"
#import "FundJZWC.h"

static NSColor *GreenColor(void) {
    return [NSColor colorWithDeviceRed:140 / 255.0 green:212 / 255.0 blue:144 / 255.0 alpha:1];
}

static NSColor *LightRedColor(void) {
    return [NSColor colorWithDeviceRed:177 / 255.0 green:131 / 255.0 blue:243 / 255.0 alpha:1];
}

static NSString *const kEyeOnKey = @"eyeon";

@implementation ViewController

#pragma mark -------------------- Actions

- (IBAction)eyeBtn:(NSButton *)sender {
    BOOL eyeOn = [[[NSUserDefaults standardUserDefaults] objectForKey:kEyeOnKey] boolValue];
    sender.accessibilitySelected = eyeOn;
    if (_st != ObType) {
        sender.accessibilitySelected = !sender.accessibilitySelected;
        if (sender.accessibilitySelected) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kEyeOnKey];
            sender.image = [NSImage imageNamed:@"eye"];
            self.allMoneyLabel.stringValue = self.ztzStr;
            self.totolLabel.stringValue = self.zsyStr;
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kEyeOnKey];
            sender.image = [NSImage imageNamed:@"eey"];
            self.allMoneyLabel.stringValue = @"******";
            self.totolLabel.stringValue = @"******";
        }
    }
    [self.codeTableV reloadData];
}

- (IBAction)resetClick:(id)sender {
    [AlertTool showAlert:@"数据将恢复至默认基金排行榜（天天基金榜十，跟着榜单走，没准能吃到基肉哦）" actionTitle1:@"好的" actionTitle2:@"取消" window:[self.view window] action:^(AlertResponse resp) {
        if (resp == FirstResp) {
            __weak typeof(self) weakSelf = self;
            [[DataManager manger] resetDefaultData:self->_st resp:^(id resp) {
                [weakSelf refreshData:nil];
            }];
        }
    }];
}

- (IBAction)addClick:(id)sender {
    [self addFund:self.codeTf.stringValue];
}

- (void)addFund:(NSString *)code {
    [[DataManager manger]addData:code source:_st resp:^(id  _Nonnull result, AlertType at) {
        if (at == AlertEmpty) {
            [AlertTool showAlert:@"别点了，鼠标好使！" actionTitle1:@"输入基码" actionTitle2:nil window:[self.view window] action:nil];
        } else if (at == AlertRepeat) {
            [AlertTool showAlert:@"添加过了，鸽鸽！" actionTitle1:@"好的" actionTitle2:nil window:[self.view window] action:nil];
        } else if (at == AlertNull) {
            [AlertTool showAlert:@"未查询到相关基码信息" actionTitle1:@"晓得喽" actionTitle2:nil window:[self.view window] action:nil];
        } else {
            [self refreshData:nil];
        }
    }];
}

- (IBAction)autuRefreshClick:(NSButton *)sender {
    sender.accessibilitySelected = !sender.accessibilitySelected;
    if (sender.accessibilitySelected) {
        sender.title = @"停止自动刷新";
        dispatch_resume(self.timer);
    } else {
        sender.title = @"自动刷新";
        dispatch_suspend(self.timer);
    }
}

- (IBAction)refreshClick:(id)sender {
    [self refreshData:nil];
}

- (IBAction)changeSource:(NSButton *)sender {
    sender.enabled = NO;
    self.sourceIndex = (self.sourceIndex % 3) + 1;

    [self configureUIForSourceIndex:self.sourceIndex button:sender];

    [self refreshData:^{
        sender.enabled = YES;
    }];
}

- (void)configureUIForSourceIndex:(NSInteger)index button:(NSButton *)button {
    // 默认状态
    NSString *totolText = @"刮开有奖";
    NSColor *totolColor = [NSColor lightGrayColor];
    NSString *allMoneyText = @"清仓保平安";
    NSColor *allMoneyColor = [NSColor lightGrayColor];
    BOOL eyeHidden = YES;
    BOOL updateHidden = YES;
    BOOL codeEditable = YES;
    NSString *placeholder = @"基码";
    NSString *codeValue = @"";

    switch (index) {
        case 1: // 榜单区
            _st = RankType;
            button.title = @"榜单区";
            eyeHidden = YES;
            updateHidden = YES;
            codeEditable = NO;
            placeholder = @"\\";
            break;
        case 2: // 观察区
            _st = ObType;
            button.title = @"观察区";
            eyeHidden = YES;
            updateHidden = YES;
            codeEditable = YES;
            placeholder = @"基码";
            break;
        case 3: // 持有区
        default:
            _st = OwnType;
            button.title = @"持有区";
            eyeHidden = NO;
            updateHidden = NO;
            codeEditable = YES;
            placeholder = @"基码";
            break;
    }

    self.totolLabel.stringValue = totolText;
    self.totolLabel.textColor = totolColor;
    self.allMoneyLabel.stringValue = allMoneyText;
    self.allMoneyLabel.textColor = allMoneyColor;
    self.eyeBtn.hidden = eyeHidden;
    self.updateBtn.hidden = updateHidden;
    self.codeTf.editable = codeEditable;
    self.codeTf.placeholderString = placeholder;
    self.codeTf.stringValue = codeValue;
}

#pragma mark -------------------- 数据

- (IBAction)updateAction:(NSButton *)sender {
    NSString *curWeek = [TimeTool weekdayString];
    if ([curWeek isEqualToString:@"周六"] || [curWeek isEqualToString:@"周末"]) {
        [AlertTool showAlert:@"基市关门，暂停营业" actionTitle1:@"门口候着！" actionTitle2:nil window:[self.view window] action:nil];
        return;
    }
    sender.enabled = NO;
    [AlertTool showAlert:@"单机版目前无法实现持仓净值的自动更新，所以需要诸基民每天自动点击更新，为避免出现什么么蛾子，建议每天只点一次，如点多次，导致数据错误（可以自己手动更正)，自己弄！！！目前无法实现持仓净值的自动更新，所以需要诸基民每天自动点击更新，为避免出现什么么蛾子，建议每天只点一次，如点多次，导致数据错误（可以自己手动更正)，自己弄！！！目前无法实现持仓净值的自动更新，所以需要诸基民每天自动点击更新，为避免出现什么么蛾子，建议每天只点一次，如点多次，导致数据错误（可以自己手动更正)，自己弄！！！" actionTitle1:@"每天更新一次！！！" actionTitle2:@"取消" window:[self.view window] action:^(
            AlertResponse resp) {

        if (resp == FirstResp) {

            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            queue.maxConcurrentOperationCount = 3;

            __block int completedCount = 0;
            __weak typeof(self) weakSelf = self;

            for (NSString *code in self.ccDic.allKeys) {
                [queue addOperationWithBlock:^{
                    [NetTool getFundLastJZ:code resp:^(id resp) {
                        @synchronized (weakSelf) {
                            CGFloat currentValue = [weakSelf.ccDic[code] floatValue];
                            CGFloat newValue = currentValue + currentValue * [resp floatValue] / 100;
                            weakSelf.ccDic[code] = [NSString stringWithFormat:@"%.2f", newValue];

                            completedCount++;

                            if (completedCount == weakSelf.ccDic.count) {
                                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                    [[DataManager manger] saveInvestedMoney:weakSelf.ccDic];
                                    [weakSelf refreshData:nil];
                                }];
                            }
                        }
                    }];
                }];
            }

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * 60 * 60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                sender.enabled = YES;
            });
        } else {
            sender.enabled = YES;
        }
    }];
}

- (void)loadData {

    [self refreshData:nil];

    dispatch_queue_t queue = dispatch_get_main_queue();

    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);

    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(timer, ^{
        [weakSelf refreshData:nil];
    });

    self.timer = timer;
}

/// 刷新数据
- (void)refreshData:(void (^)(void))isFinish {

    [self.indicator startAnimation:nil];
    [[DataManager manger] loadData:_st resp:^(id _Nonnull resp) {
        [self.modelsAry removeAllObjects];
        self.modelsAry = resp;
        //                NSLog(@"基数：%ld",self.modelsAry.count);
        [self loadJC];
        [self.codeTableV reloadData];
        [self caculateIncome:self.modelsAry];
        [self.indicator stopAnimation:nil];

        !isFinish ?: isFinish();

    }];
    [NetTool getIndexInfo:^(NSArray <FundModel *> *mArray) {
        [self configureIndexUI:mArray];
        [self.indicator stopAnimation:nil];
    }];
}

/// 加载持仓数据
- (void)loadJC {

    NSDictionary *jcDic = [[DataManager manger] getInvestedMoney];
    if (jcDic.count > 0) {
        self.ccDic = [NSMutableDictionary dictionaryWithDictionary:jcDic];
    } else {
        self.ccDic = [NSMutableDictionary dictionary];
    }
    
}

/// 计算总收益
/// @param mary <#ary description#>
- (void)caculateIncome:(NSArray <FundModel *>*)mary {

    // 总收益
    __block CGFloat zsy = 0.0;
    // 总投资
    __block CGFloat ztz = 0.0;

    NSMutableDictionary *tempD = [NSMutableDictionary dictionary];
    [mary enumerateObjectsUsingBlock:^(FundModel *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [tempD setValue:obj.gszzl forKey:obj.fundcode];
    }];

    [tempD enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key1, id _Nonnull obj1, BOOL *_Nonnull stop) {

        [self.ccDic enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key2, id _Nonnull obj2, BOOL *_Nonnull stop) {

            if (key1 == key2) {
                zsy += [obj1 floatValue] / 100 * [obj2 floatValue];
                ztz += [obj2 floatValue];
            }
        }];

    }];

    if (_st == ObType || _st == RankType) {
        self.totolLabel.stringValue = @"刮开有奖";
        self.totolLabel.textColor = [NSColor lightGrayColor];
        self.allMoneyLabel.stringValue = @"清仓保平安";
        self.allMoneyLabel.textColor = [NSColor lightGrayColor];
    } else {
        if (zsy == 0.00) {
            self.zsyStr = [NSString stringWithFormat:@"%.2f", zsy, zsy / ztz * 100];
        } else {
            self.zsyStr = [NSString stringWithFormat:@"%.2f  (%.2f%%%)", zsy, zsy / ztz * 100];
        }
        self.ztzStr = [NSString stringWithFormat:@"%.2f", ztz];
        if ([self.zsyStr containsString:@"-"]) {
            self.totolLabel.textColor = GreenColor();
        } else {
            self.totolLabel.textColor = [NSColor redColor];
        }
        self.allMoneyLabel.textColor = [NSColor redColor];

        BOOL eyeOn = [[[NSUserDefaults standardUserDefaults] objectForKey:kEyeOnKey] boolValue];
        if (eyeOn) {
            self.allMoneyLabel.stringValue = self.ztzStr;
            self.totolLabel.stringValue = self.zsyStr;
        } else {
            self.allMoneyLabel.stringValue = @"******";
            self.totolLabel.stringValue = @"******";
        }
    }

}

#pragma mark --------------------------------- UI

- (void)UISet {
    self.codeTableV.delegate = (id) self;
    self.codeTableV.dataSource = self;
    self.codeTableV.mhdelegate = self;
    self.codeTableV.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;

    [self.codeTableV registerForDraggedTypes:@[NSPasteboardTypeString]];
    self.codeTableV.draggingDestinationFeedbackStyle = NSTableViewDraggingDestinationFeedbackStyleSourceList;

    self.codeTf.delegate = self;
    _st = RankType;

    self.eyeBtn.hidden = YES;
    self.updateBtn.hidden = YES;
    BOOL eyeOn = [[[NSUserDefaults standardUserDefaults] objectForKey:kEyeOnKey] boolValue];

    if (eyeOn) {
        self.eyeBtn.accessibilitySelected = YES;
        self.eyeBtn.image = [NSImage imageNamed:@"eye"];
    } else {
        self.eyeBtn.accessibilitySelected = NO;
        self.eyeBtn.image = [NSImage imageNamed:@"eey"];
    }
}

- (void)configureIndexUI:(NSArray <FundModel *>*)ary {
    if (ary.count < 3) return;
    ///上证指数
    FundModel *szm = ary[0];
    ///沪深300
    FundModel *hsm = ary[1];
    ///深证成指
    FundModel *scm = ary[2];

    [self updateSZRecord:szm];
    [self showSZRecord];

    self.shangLabel.stringValue = szm.f2;
    self.huLabel.stringValue = hsm.f2;
    self.shenLabel.stringValue = scm.f2;
    self.shang1Label.stringValue = [NSString stringWithFormat:@"%@/%@", szm.f3, szm.f4];
    self.hu1Label.stringValue = [NSString stringWithFormat:@"%@/%@", hsm.f3, hsm.f4];
    self.shen1Label.stringValue = [NSString stringWithFormat:@"%@/%@", scm.f3, scm.f4];

    [self updateIndexColorAndImage:self.shangLabel valueLabel:self.shang1Label imageView:self.shangImage value:szm.f3];
    [self updateIndexColorAndImage:self.huLabel valueLabel:self.hu1Label imageView:self.huImage value:hsm.f3];
    [self updateIndexColorAndImage:self.shenLabel valueLabel:self.shen1Label imageView:self.shenImage value:scm.f3];
}

- (void)updateIndexColorAndImage:(NSTextField *)label valueLabel:(NSTextField *)valueLabel imageView:(NSImageView *)imageView value:(NSString *)value {
    if ([value containsString:@"-"]) {
        label.textColor = GreenColor();
        valueLabel.textColor = GreenColor();
        imageView.image = [NSImage imageNamed:@"down"];
    } else {
        label.textColor = [NSColor redColor];
        valueLabel.textColor = [NSColor redColor];
        imageView.image = [NSImage imageNamed:@"up"];
    }
}

- (void)updateSZRecord:(FundModel *)model {
    [[DataManager manger] updateSZ:model.f_f2];
}

- (void)showSZRecord {
    NSString *highR = [[DataManager manger] getRecordSZHigh];
    NSString *lowR = [[DataManager manger] getRecordSZLow];
    [self.shangLabel setToolTip:[NSString stringWithFormat:@"%@\n%@", highR, lowR]];
}

#pragma mark -------------------- NSTableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.modelsAry.count;
}

//设置某个元素的具体视图
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    FundModel *model = self.modelsAry[row];
    if (model.zoneType == 2) {
        return [self rankTableView:tableView viewForTableColumn:tableColumn row:row model:model];
    } else {
        return [self normalTableView:tableView viewForTableColumn:tableColumn row:row model:model];
    }
}

- (NSView *)rankTableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row model:(FundModel *)model {
    if (tableColumn == tableView.tableColumns[0]) {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell1" owner:nil];
        cell.textField.stringValue = [NSString stringWithFormat:@"%@(%@)", model.name, model.fundcode];
        return cell;
    } else if (tableColumn == tableView.tableColumns[1]) {
        tableColumn.title = @"基月";
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell1" owner:nil];
        cell.textField.stringValue = [model.SYL_Y isEqualToString:@"--"] ? @"--" : [model.SYL_Y stringByAppendingString:@"%"];
        cell.textField.textColor = LightRedColor();
        return cell;
    } else if (tableColumn == tableView.tableColumns[2]) {
        tableColumn.title = @"基年";
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell2" owner:nil];
        cell.textField.stringValue = [model.SYL_1N isEqualToString:@"--"] ? @"--" : [model.SYL_1N stringByAppendingString:@"%"];
        return cell;
    } else if (tableColumn == tableView.tableColumns[3]) {
        tableColumn.title = @"基昨";
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell3" owner:nil];
        cell.textField.stringValue = [model.RZDF isEqualToString:@"--"] ? @"--" : [model.RZDF stringByAppendingString:@"%"];
        cell.textField.textColor = [model.RZDF containsString:@"-"] ? GreenColor() : [NSColor redColor];
        return cell;
    } else if (tableColumn == tableView.tableColumns[5]) {
        tableColumn.title = @"基规";
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell3" owner:nil];
        cell.textField.stringValue = [NSString stringWithFormat:@"%@元", model.ENDNAV];
        return cell;
    } else {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell3" owner:nil];
        cell.textField.stringValue = model.FSRQ;
        return cell;
    }
}

- (NSView *)normalTableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row model:(FundModel *)model {
    if (tableColumn == tableView.tableColumns[0]) {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell1" owner:nil];
        cell.textField.stringValue = [NSString stringWithFormat:@"%@(%@)", model.name, model.fundcode];
        return cell;
    } else if (tableColumn == tableView.tableColumns[1]) {
        tableColumn.title = @"基净";
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell1" owner:nil];
        cell.textField.stringValue = model.dwjz;
        cell.textField.textColor = [NSColor blackColor];
        return cell;
    } else if (tableColumn == tableView.tableColumns[2]) {
        tableColumn.title = @"基估";
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell2" owner:nil];
        cell.textField.stringValue = model.gsz;
        return cell;
    } else if (tableColumn == tableView.tableColumns[3]) {
        tableColumn.title = @"基幅";
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell3" owner:nil];
        cell.textField.stringValue = model.gszzl;
        cell.textField.textColor = [model.gszzl containsString:@"-"] ? GreenColor() : [NSColor redColor];
        return cell;
    } else if (tableColumn == tableView.tableColumns[5]) {
        tableColumn.title = @"基持";
        NSView *view = [tableView makeViewWithIdentifier:@"cellId" owner:self];
        if (view == nil) {
            view = [[NSView alloc] initWithFrame:CGRectZero];
            NSTextField *jct = [[NSTextField alloc] initWithFrame:CGRectMake(10, 10, 100, 20)];
            jct.alignment = NSTextAlignmentCenter;

            if (_st == ObType) {
                jct.editable = NO;
                jct.placeholderString = @"\\";
            } else if (_st == OwnType) {
                jct.editable = YES;
                jct.delegate = self;
                jct.tag = row;

                NSString *jcStr = self.ccDic[model.fundcode];
                BOOL eyeOn = [[NSUserDefaults standardUserDefaults] boolForKey:kEyeOnKey];

                if (jcStr.length > 0) {
                    jct.stringValue = eyeOn ? jcStr : @"******";
                } else {
                    jct.placeholderString = @"基金持有金额";
                }
            }
            [view addSubview:jct];
        }
        return view;
    } else {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell3" owner:nil];
        cell.textField.stringValue = model.gztime;
        return cell;
    }
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 40;
}

#pragma mark -------------------- 拖拽

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    NSData *indexSetData = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes requiringSecureCoding:YES error:nil];
    [pboard declareTypes:@[NSPasteboardTypeString] owner:self];
    [pboard setData:indexSetData forType:NSPasteboardTypeString];
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    if (dropOperation == NSTableViewDropAbove) {
        return NSDragOperationMove;
    }
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
    NSPasteboard *pboard = [info draggingPasteboard];
    NSData *rowData = [pboard dataForType:NSPasteboardTypeString];
    NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSIndexSet class] fromData:rowData error:nil];
    NSInteger sourceRow = rowIndexes.firstIndex;

    if (sourceRow < row) {
        // 从上往下移
        [self.modelsAry insertObject:[self.modelsAry objectAtIndex:sourceRow] atIndex:row];
        [self.modelsAry removeObjectAtIndex:sourceRow];
        [self.codeTableV reloadData];
        [[DataManager manger] dragReset:_st modelsAry:self.modelsAry];
        return YES;
    } else {
        FundModel *smodel = [self.modelsAry objectAtIndex:sourceRow];
        [self.modelsAry removeObjectAtIndex:sourceRow];
        [self.modelsAry insertObject:smodel atIndex:row];
        [self.codeTableV reloadData];
        [[DataManager manger] dragReset:_st modelsAry:self.modelsAry];
        return YES;
    }
}

#pragma mark -------------------- 点击

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    //    NSLog(@"shouldSelectRow==%ld",(long)row);
    return YES;
}

- (void)tableView:(NSTableView *)tableView didClickMenuDetail:(NSInteger)row {

    FundModel *fm = self.modelsAry[row];
    FundJZWC *jzwc = [[FundJZWC alloc] initWithWindowNibName:@"FundJZWC"];
    if (_st == RankType) {
        FundModel *model = self.modelsAry[row];
        jzwc.fundCode = model.fundcode;
    } else {
        jzwc.fundCode = [[DataManager manger] getCode:row source:_st];
    }
    jzwc.fundName = fm.name;
    [jzwc.window orderFront:nil];
    [jzwc.window center];
}

- (void)tableView:(NSTableView *)tableView didClickMenuDelete:(NSInteger)row {
    [[DataManager manger] deleteData:row source:_st resp:^(id resp) {
        [self refreshData:nil];
    }];
}

#pragma mark -------------------- NSControl

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor {
    //    NSLog(@"textShouldBeginEditing");
    return YES;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    NSString *jcStr = fieldEditor.string;
    if (control == self.codeTf) {
        [self addFund:self.codeTf.stringValue];
    } else {
        FundModel *model = self.modelsAry[control.tag];
        //    NSLog(@"control==%ld",control.tag);
        if (jcStr.length > 0) {
            if ([jcStr containsString:@"*"]) {
                [AlertTool showAlert:@"不要盲输哦" actionTitle1:@"请打开金额显示" actionTitle2:@"" window:[self.view window] action:nil];
            } else if (![JTool isPureFloat:jcStr]) {
                [AlertTool showAlert:@"请输入正确金额[0123456789.]，伙计" actionTitle1:@"收到" actionTitle2:@"" window:[self.view window] action:nil];
            } else {
                [self.ccDic setValue:[NSString stringWithFormat:@"%@", jcStr] forKey:model.fundcode];
                [[DataManager manger] saveInvestedMoney:self.ccDic];
                [self refreshData:nil];
            }
        }
    }
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self UISet];
    [self loadData];
}

- (void)initData {
    self.sourceIndex = 1;
    self.codeTf.editable = NO;
    self.codeTf.placeholderString = @"\\";
}

- (void)viewWillDisappear {
    [super viewWillDisappear];
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        dispatch_source_set_event_handler(self.timer, ^{});
    }
}

- (NSProgressIndicator *)indicator {
    if (!_indicator) {
        _indicator = [[NSProgressIndicator alloc] initWithFrame:CGRectZero];
        _indicator.style = NSProgressIndicatorSpinningStyle;
        _indicator.controlSize = NSControlSizeRegular;
        _indicator.displayedWhenStopped = NO;
        [self.view addSubview:_indicator];
    }
    return _indicator;
}

- (void)viewDidLayout {
    [super viewDidLayout];
    self.indicator.frame = CGRectMake(self.view.frame.size.width / 2 - 25, self.view.frame.size.height / 2 - 25, 50, 50);
}

@end
