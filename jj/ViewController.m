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

#define GREENCOLOR [NSColor colorWithDeviceRed:140/255.0 green:212/255.0 blue:144/255.0 alpha:1]
#define LIGHTREDCOLOR [NSColor colorWithDeviceRed:177/255.0 green:131/255.0 blue:243/255.0 alpha:1]

#define EYEON @"eyeon"

@implementation ViewController

#pragma mark -------------------- 操作

- (IBAction)eyeBtn:(NSButton *)sender {
    BOOL eyeOn = [[[NSUserDefaults standardUserDefaults]objectForKey:EYEON]boolValue];
    sender.accessibilitySelected = eyeOn;
    if (_st != ObType) {
        sender.accessibilitySelected = !sender.accessibilitySelected;
        if (sender.accessibilitySelected) {
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:EYEON];
            sender.image = [NSImage imageNamed:@"eye"];
            self.allMoneyLabel.stringValue = self.ztzStr;
            self.totolLabel.stringValue = self.zsyStr;
            
        }else{
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:EYEON];
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
            [[DataManager manger]resetDefaultData:self->_st resp:^(id resp) {
                [self refreshData:nil];
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
            [AlertTool showAlert:@"添加过了，老弟！" actionTitle1:@"好的" actionTitle2:nil window:[self.view window] action:nil];
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
    }else{
        sender.title = @"自动刷新";
        dispatch_suspend(self.timer);
    }
}

- (IBAction)refreshClick:(id)sender {
    [self refreshData:nil];
}

- (IBAction)changeSource:(NSButton *)sender {
    sender.enabled = NO;
    if (self.sourceIndex == 1) {
        _st = ObType;
        sender.title = @"观察区";
        self.totolLabel.stringValue = @"刮开有奖";
        self.totolLabel.textColor = [NSColor lightGrayColor];
        self.allMoneyLabel.stringValue = @"清仓保平安";
        self.allMoneyLabel.textColor = [NSColor lightGrayColor];
        self.eyeBtn.hidden = YES;
        self.updateBtn.hidden = YES;
        self.codeTf.editable = YES;
        self.codeTf.placeholderString = @"基码";
        self.codeTf.stringValue = @"";
    }else if (self.sourceIndex == 2) {
        _st = OwnType;
        sender.title = @"持有区";
        self.eyeBtn.hidden = NO;
        self.updateBtn.hidden = NO;
        self.codeTf.editable = YES;
        self.codeTf.placeholderString = @"基码";
        self.codeTf.stringValue = @"";
    }else {
        self.sourceIndex = 0;
        _st = RankType;
        sender.title = @"榜单区";
        self.totolLabel.stringValue = @"刮开有奖";
        self.totolLabel.textColor = [NSColor lightGrayColor];
        self.allMoneyLabel.stringValue = @"清仓保平安";
        self.allMoneyLabel.textColor = [NSColor lightGrayColor];
        self.eyeBtn.hidden = YES;
        self.updateBtn.hidden = YES;
        self.codeTf.editable = NO;
        self.codeTf.placeholderString = @"\\";
        self.codeTf.stringValue = @"";
    }
    self.sourceIndex ++;
    
    [self refreshData:^{
        sender.enabled = YES;
    }];
}

#pragma mark -------------------- 数据

- (IBAction)updateAction:(NSButton *)sender {
    NSString *curWeek = [TimeTool weekdayString];
    if ([curWeek isEqualToString:@"周六"]||[curWeek isEqualToString:@"周末"]) {
        [AlertTool showAlert:@"基市关门，暂停营业" actionTitle1:@"门口候着！" actionTitle2:nil window:[self.view window] action:nil];
        return;
    }
    sender.enabled = NO;
    [AlertTool showAlert:@"单机版目前无法实现持仓净值的自动更新，所以需要诸基民每天自动点击更新，为避免出现什么么蛾子，建议每天只点一次，如点多次，导致数据错误（可以自己手动更正)，自己弄！！！目前无法实现持仓净值的自动更新，所以需要诸基民每天自动点击更新，为避免出现什么么蛾子，建议每天只点一次，如点多次，导致数据错误（可以自己手动更正)，自己弄！！！目前无法实现持仓净值的自动更新，所以需要诸基民每天自动点击更新，为避免出现什么么蛾子，建议每天只点一次，如点多次，导致数据错误（可以自己手动更正)，自己弄！！！" actionTitle1:@"每天更新一次！！！" actionTitle2:@"取消" window:[self.view window] action:^(AlertResponse resp) {
        
        if (resp == FirstResp) {
            
            __block int count =0;
            __block int jzCount =0;
            
            [self.ccDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj,  BOOL * _Nonnull stop) {
                count ++;
                // 30个一组进行请求
                if (count % 30 == 0) {
                    sleep(2);
                }
                [NetTool getFundLastJZ:key resp:^(id  _Nonnull resp) {
                    jzCount ++;
                    CGFloat jzStr = [obj floatValue] + [obj floatValue] * [resp floatValue] / 100;
                    [self.ccDic setValue:[NSString stringWithFormat:@"%.2f",jzStr] forKey:key];
                    [[DataManager manger]saveInvestedMoney:self.ccDic];
                    if (jzCount == self.ccDic.count) {
                        // 得出最后一个持仓净值数据，更新数据源
                        [self refreshData:nil];
                    }
                }];
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 *60 *60 *NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                sender.enabled = YES;
            });
        }else {
            sender.enabled = YES;
        }
    }];
}

- (void)loadData {
    
    [self refreshData:nil];
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    
    dispatch_source_set_event_handler(timer, ^{
        [self refreshData:nil];
    });
    
    self.timer = timer;
}

/// 刷新数据
- (void)refreshData:(void(^)(void))isFinish {
    
    [self.indicator startAnimation:nil];
    [[DataManager manger]loadData:_st resp:^(id  _Nonnull resp) {
        [self.modelsAry  removeAllObjects];
        self.modelsAry = resp;
        //                NSLog(@"基数：%ld",self.modelsAry.count);
        [self loadJC];
        [self.codeTableV reloadData];
        [self caculateIncome:self.modelsAry];
        [self.indicator stopAnimation:nil];
        
        !isFinish?:isFinish();
        
    }];
    [NetTool getIndexInfo:^(NSArray <FundModel *>*mArray) {
        [self configureUI:mArray];
        [self.indicator stopAnimation:nil];
    }];
}

/// 加载持仓数据
- (void)loadJC {
    
    NSDictionary *jcDic = [[DataManager manger]getInvestedMoney];
    if (jcDic.count > 0) {
        self.ccDic = [NSMutableDictionary dictionaryWithDictionary:jcDic];
    }else {
        self.ccDic = [NSMutableDictionary dictionary];
    }
}

/// 计算总收益
/// @param mary <#ary description#>
- (void)caculateIncome:(NSArray <FundModel *>*)mary {
    
    // 总收益
    __block  CGFloat zsy = 0.0;
    // 总投资
    __block  CGFloat ztz = 0.0;
    
    NSMutableDictionary *tempD = [NSMutableDictionary dictionary];
    [mary enumerateObjectsUsingBlock:^(FundModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tempD setValue:obj.gszzl forKey:obj.fundcode];
    }];
    
    [tempD enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key1, id  _Nonnull obj1, BOOL * _Nonnull stop) {
        
        [self.ccDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key2, id  _Nonnull obj2, BOOL * _Nonnull stop) {
            
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
            self.zsyStr = [NSString stringWithFormat:@"%.2f",zsy,zsy/ztz * 100];
        }else {
            self.zsyStr = [NSString stringWithFormat:@"%.2f  (%.2f%%%)",zsy,zsy/ztz * 100];
        }
        self.ztzStr = [NSString stringWithFormat:@"%.2f",ztz];
        if ([self.zsyStr containsString:@"-"]) {
            self.totolLabel.textColor = GREENCOLOR;
        }else {
            self.totolLabel.textColor = [NSColor redColor];
        }
        self.allMoneyLabel.textColor = [NSColor redColor];
        
        BOOL eyeOn = [[[NSUserDefaults standardUserDefaults]objectForKey:EYEON]boolValue];
        if (eyeOn) {
            self.allMoneyLabel.stringValue = self.ztzStr;
            self.totolLabel.stringValue = self.zsyStr;
        }else {
            self.allMoneyLabel.stringValue = @"******";
            self.totolLabel.stringValue = @"******";
        }
    }
    
}

#pragma mark --------------------------------- UI

- (void)UISet {
    
    self.codeTableV.delegate = (id)self;
    self.codeTableV.dataSource = self;
    self.codeTableV.mhdelegate = self;
    self.codeTableV.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
    
    [self.codeTableV registerForDraggedTypes:@[NSPasteboardTypeString]];
    self.codeTableV.draggingDestinationFeedbackStyle = NSTableViewDraggingDestinationFeedbackStyleSourceList;
    
    self.codeTf.delegate = self;
    _st = RankType;
    
    self.eyeBtn.hidden = YES;
    self.updateBtn.hidden = YES;
    BOOL eyeOn = [[[NSUserDefaults standardUserDefaults]objectForKey:EYEON]boolValue];
    
    if (eyeOn) {
        self.eyeBtn.accessibilitySelected = YES;
        self.eyeBtn.image = [NSImage imageNamed:@"eye"];
    }else {
        self.eyeBtn.accessibilitySelected = NO;
        self.eyeBtn.image = [NSImage imageNamed:@"eey"];
    }
}

- (void)configureUI:(NSArray <FundModel *>*)ary {
    
    //上证指数
    FundModel *szm = ary[0];
    //沪深300
    FundModel *hsm = ary[1];
    //深证成指
    FundModel *scm = ary[2];
    
    self.shangLabel.stringValue = szm.f2;
    self.huLabel.stringValue = hsm.f2;
    self.shenLabel.stringValue = scm.f2;
    self.shang1Label.stringValue = [NSString stringWithFormat:@"%@/%@",szm.f3,szm.f4];
    self.hu1Label.stringValue = [NSString stringWithFormat:@"%@/%@",hsm.f3,hsm.f4];
    self.shen1Label.stringValue = [NSString stringWithFormat:@"%@/%@",scm.f3,scm.f4];
    
    
    if ([szm.f3 containsString:@"-"]) {
        self.shangLabel.textColor = GREENCOLOR;
        self.shang1Label.textColor = GREENCOLOR;
        self.shangImage.image = [NSImage imageNamed:@"down"];
    } else {
        self.shangLabel.textColor = [NSColor redColor];
        self.shang1Label.textColor = [NSColor redColor];
        self.shangImage.image = [NSImage imageNamed:@"up"];
    }
    if ([hsm.f3 containsString:@"-"]) {
        self.huLabel.textColor = GREENCOLOR;
        self.hu1Label.textColor = GREENCOLOR;
        self.huImage.image = [NSImage imageNamed:@"down"];
    } else {
        self.huLabel.textColor = [NSColor redColor];
        self.hu1Label.textColor = [NSColor redColor];
        self.huImage.image = [NSImage imageNamed:@"up"];
    }
    if ([scm.f3 containsString:@"-"]) {
        self.shenLabel.textColor = GREENCOLOR;
        self.shen1Label.textColor = GREENCOLOR;
        self.shenImage.image = [NSImage imageNamed:@"down"];
        
    } else {
        self.shenLabel.textColor = [NSColor redColor];
        self.shen1Label.textColor = [NSColor redColor];
        self.shenImage.image = [NSImage imageNamed:@"up"];
    }
}

#pragma mark -------------------- NSTableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.modelsAry.count;
}

//设置某个元素的具体视图
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    FundModel *model = self.modelsAry[row];
    if (model.zoneType == 2) {
        if (tableColumn == tableView.tableColumns[0]) {
            NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell1" owner:nil];
            cell.textField.stringValue = [NSString stringWithFormat:@"%@(%@)",model.name,model.fundcode];
            return cell;
        }else if (tableColumn == tableView.tableColumns[1]) {
            NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell1" owner:nil];
            tableColumn.title = @"基月";
            cell.textField.stringValue = [model.SYL_Y isEqualToString:@"--"] ? @"--" : [model.SYL_Y stringByAppendingString:@"%"];
            cell.textField.textColor = LIGHTREDCOLOR;
            return cell;
        }else if (tableColumn == tableView.tableColumns[2]) {
            tableColumn.title = @"基年";
            NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell2" owner:nil];
            cell.textField.stringValue = [model.SYL_1N isEqualToString:@"--"] ? @"--" : [model.SYL_1N stringByAppendingString:@"%"];
            return cell;
        }else if (tableColumn == tableView.tableColumns[3]) {
            tableColumn.title = @"基昨";
            NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell3" owner:nil];
            cell.textField.stringValue = [model.RZDF isEqualToString:@"--"] ? @"--" : [model.RZDF stringByAppendingString:@"%"];
            if ([model.RZDF containsString:@"-"]) {
                cell.textField.textColor = GREENCOLOR;
            }else {
                cell.textField.textColor = [NSColor redColor];
            }
            return cell;
        }else if (tableColumn == tableView.tableColumns[5]) {
            tableColumn.title = @"基规";
            NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell3" owner:nil];
            cell.textField.stringValue = [NSString stringWithFormat:@"%@元",model.ENDNAV];
            return cell;
        }else{
            NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell3" owner:nil];
            cell.textField.stringValue = model.FSRQ;
            return cell;
        }
    }else {
        if (tableColumn == tableView.tableColumns[0]) {
            NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell1" owner:nil];
            cell.textField.stringValue = [NSString stringWithFormat:@"%@(%@)",model.name,model.fundcode];
            return cell;
        }else if (tableColumn == tableView.tableColumns[1]) {
            tableColumn.title = @"基净";
            NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell1" owner:nil];
            cell.textField.stringValue = model.dwjz;
            cell.textField.textColor = [NSColor blackColor];
            return cell;
        }else if (tableColumn == tableView.tableColumns[2]) {
            tableColumn.title = @"基估";
            NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell2" owner:nil];
            cell.textField.stringValue = model.gsz;
            return cell;
        }else if (tableColumn == tableView.tableColumns[3]) {
            tableColumn.title = @"基幅";
            NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell3" owner:nil];
            cell.textField.stringValue = model.gszzl;
            if ([model.gszzl containsString:@"-"]) {
                cell.textField.textColor = GREENCOLOR;
            }else {
                cell.textField.textColor = [NSColor redColor];
            }
            return cell;
        }else if (tableColumn == tableView.tableColumns[5]) {
            tableColumn.title = @"基持";
            NSView * view = [tableView makeViewWithIdentifier:@"cellId" owner:self];
            if (view==nil) {
                view = [[NSView alloc]initWithFrame:CGRectZero];
                NSTextField *jct = [[NSTextField alloc]initWithFrame:CGRectMake(10, 10, 100, 20)];
                jct.alignment = NSTextAlignmentCenter;
                if (_st == ObType) {
                    jct.editable = NO;
                    jct.placeholderString = @"\\";
                }else if(_st == OwnType) {
                    jct.editable = YES;
                    jct.delegate = self;
                    jct.tag = row;
                    NSString *jcStr =  [self.ccDic objectForKey:model.fundcode];
                    
                    if (jcStr.length > 0) {
                        BOOL eyeOn = [[[NSUserDefaults standardUserDefaults]objectForKey:EYEON]boolValue];
                        if (eyeOn) {
                            jct.stringValue = jcStr;
                        }else {
                            jct.stringValue = @"******";
                        }
                    }else {
                        jct.placeholderString = @"基金持有金额";
                    }
                }
                [view addSubview:jct];
            }
            return view;
        }else{
            NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell3" owner:nil];
            cell.textField.stringValue = model.gztime;
            return cell;
        }
    }
    
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 40;
}

#pragma mark -------------------- 拖拽

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
    NSData *indexSetData = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes requiringSecureCoding:YES error:nil];
    [pboard declareTypes:@[NSPasteboardTypeString] owner:self];
    [pboard setData:indexSetData forType:NSPasteboardTypeString];
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    if (dropOperation == NSTableViewDropAbove) {
        return NSDragOperationMove;
    }
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
{
    NSPasteboard *pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType:NSPasteboardTypeString];
    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSIndexSet class] fromData:rowData error:nil];
    NSInteger sourceRow = rowIndexes.firstIndex;
    
    if (sourceRow < row) {
        // 从上往下移
        [self.modelsAry insertObject:[self.modelsAry objectAtIndex:sourceRow] atIndex:row];
        [self.modelsAry removeObjectAtIndex:sourceRow];
        [self.codeTableV reloadData];
        [[DataManager manger]dragReset:_st modelsAry:self.modelsAry];
        return YES;
    }else {
        FundModel *smodel = [self.modelsAry objectAtIndex:sourceRow];
        [self.modelsAry removeObjectAtIndex:sourceRow];
        [self.modelsAry insertObject:smodel atIndex:row];
        [self.codeTableV reloadData];
        [[DataManager manger]dragReset:_st modelsAry:self.modelsAry];
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
    FundJZWC *jzwc = [[FundJZWC alloc]initWithWindowNibName:@"FundJZWC"];
    if (_st == RankType) {
        FundModel *model = self.modelsAry[row];
        jzwc.fundCode = model.fundcode;
    }else {
        jzwc.fundCode = [[DataManager manger]getCode:row source:_st];
    }
    jzwc.fundName = fm.name;
    [jzwc.window orderFront:nil];
    [jzwc.window center];
}

- (void)tableView:(NSTableView *)tableView didClickMenuDelete:(NSInteger)row {
    [[DataManager manger]deleteData:row source:_st resp:^(id resp) {
        [self refreshData:nil];
    }];
}

#pragma mark -------------------- NSControl

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor {
    //    NSLog(@"textShouldBeginEditing");
    return YES;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor{
    NSString *jcStr = fieldEditor.string;
    if (control == self.codeTf) {
        [self addFund:self.codeTf.stringValue];
    }else {
        FundModel *model = self.modelsAry[control.tag];
        //    NSLog(@"control==%ld",control.tag);
        if (jcStr.length > 0) {
            if ([jcStr containsString:@"*"]) {
                [AlertTool showAlert:@"不要盲输哦" actionTitle1:@"请打开金额显示" actionTitle2:@"" window:[self.view window] action:nil];
            }else if (![JTool isPureFloat:jcStr]) {
                [AlertTool showAlert:@"请输入正确金额[0123456789.]，兄弟" actionTitle1:@"明白" actionTitle2:@"" window:[self.view window] action:nil];
            }else {
                [self.ccDic setValue:[NSString stringWithFormat:@"%@",jcStr] forKey:model.fundcode];
                [[DataManager manger]saveInvestedMoney:self.ccDic];
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
    dispatch_source_cancel(self.timer);
}

- (NSProgressIndicator *)indicator {
    
    if (!_indicator) {
        _indicator = [[NSProgressIndicator alloc]initWithFrame:CGRectZero];
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
