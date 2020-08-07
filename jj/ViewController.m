//
//  ViewController.m
//  jj
//
//  Created by LY_MD on 2020/7/17.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import "ViewController.h"
#import "AlertTool.h"

#define GREENCOLOR [NSColor colorWithDeviceRed:140/255.0 green:212/255.0 blue:144/255.0 alpha:1]
#define EYEON @"eyeon"

@implementation ViewController

#pragma mark -------------------- 数据

- (IBAction)eyeBtn:(NSButton *)sender {
    BOOL eyeOn = [[[NSUserDefaults standardUserDefaults]objectForKey:EYEON]boolValue];
    sender.accessibilitySelected = eyeOn;
    if (_st != RecommedType) {
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
    
}

- (IBAction)resetClick:(id)sender {
    
    [AlertTool showAlert:@"数据将恢复至默认基金排行榜（天天基金榜十，跟着榜单走，没准能吃到基肉哦）" actionTitle1:@"好的" actionTitle2:@"取消" window:[self.view window] action:^(AlertResponse resp) {
        if (resp == FirstResp) {
            [[DataManager manger]resetDefaultData:self->_st resp:^(id resp) {
                [self refreshData];
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
              [self refreshData];
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
    [self refreshData];
}
- (IBAction)changeSource:(NSButton *)sender {
    
    sender.accessibilitySelected = !sender.accessibilitySelected;
    if (sender.accessibilitySelected) {
          _st = OtherType;
          sender.title = @"自选源";
          self.eyeBtn.hidden = NO;
    }else{
        _st = RecommedType;
        sender.title = @"推荐源";
        self.totolLabel.stringValue = @"刮开有奖";
        self.eyeBtn.hidden = YES;
    }
    
       [self refreshData];

}

- (void)loadData {
    
    [self refreshData];
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    
    dispatch_source_set_event_handler(timer, ^{
        [self refreshData];
    });
    
    self.timer = timer;
    
}

/// 刷新数据
- (void)refreshData {
    
    [self loadJC];
    [[DataManager manger]loadData:_st resp:^(id  _Nonnull resp) {
          self.modelsAry = resp;
       
          [self.codeTableV reloadData];
        
          [self caculateIncome:self.modelsAry];
    }];
    [NetTool getIndexInfo:^(NSArray <FundModel *>*mArray) {
            
           [self configureUI:mArray];
                   
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
    if (_st == RecommedType) {
        self.totolLabel.stringValue = @"刮开有奖";
        self.totolLabel.textColor = [NSColor lightGrayColor];
        self.allMoneyLabel.stringValue = @"清仓保平安";
        self.allMoneyLabel.textColor = [NSColor lightGrayColor];
    }else {
        self.zsyStr = [NSString stringWithFormat:@"%.2f",zsy];
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
#pragma mark -------------------- UI

- (void)UISet {
    
    self.codeTableV.delegate = (id)self;
    self.codeTableV.dataSource = self;
    self.codeTableV.mhdelegate = self;
    self.codeTableV.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
    
    [self.codeTableV registerForDraggedTypes:@[NSPasteboardTypeString]];
    self.codeTableV.draggingDestinationFeedbackStyle = NSTableViewDraggingDestinationFeedbackStyleSourceList;
    
    self.codeTf.delegate = self;
    _st = RecommedType;
    
    self.eyeBtn.hidden = YES;
    
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
    FundModel *szhm = ary[0];
    //沪深300
    FundModel *hsm = ary[1];
    //深证成指
    FundModel *scm = ary[2];

    self.shangLabel.stringValue = szhm.f2;
    self.huLabel.stringValue = hsm.f2;
    self.shenLabel.stringValue = scm.f2;
    self.shang1Label.stringValue = [NSString stringWithFormat:@"%@/%@",szhm.f3,szhm.f4];
    self.hu1Label.stringValue = [NSString stringWithFormat:@"%@/%@",hsm.f3,hsm.f4];
    self.shen1Label.stringValue = [NSString stringWithFormat:@"%@/%@",scm.f3,scm.f4];
    
    
    if ([szhm.f3 containsString:@"-"]) {
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
           self.huLabel.textColor = [NSColor redColor];
           self.shen1Label.textColor = [NSColor redColor];
           self.shenImage.image = [NSImage imageNamed:@"up"];
    }
    
}
#pragma mark -------------------- NSTableView
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.modelsAry.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    FundModel *model = self.modelsAry[row];
    if (tableColumn == tableView.tableColumns[0]) {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell1" owner:nil];
        cell.textField.stringValue = [NSString stringWithFormat:@"%@(%@)",model.name,model.fundcode];
        return cell;
    }else if (tableColumn == tableView.tableColumns[1]) {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell1" owner:nil];
        cell.textField.stringValue = model.dwjz;
        return cell;
    }else if (tableColumn == tableView.tableColumns[2]) {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell2" owner:nil];
        cell.textField.stringValue = model.gsz;
        return cell;
    }else if (tableColumn == tableView.tableColumns[3]) {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell3" owner:nil];
        cell.textField.stringValue = model.gszzl;
        if ([model.gszzl containsString:@"-"]) {
            cell.textField.textColor = GREENCOLOR;
        }else {
            cell.textField.textColor = [NSColor redColor];
        }
        return cell;
    }else if (tableColumn == tableView.tableColumns[5]) {
        NSView * view = [tableView makeViewWithIdentifier:@"cellId" owner:self];
        if (view==nil) {
            view = [[NSView alloc]initWithFrame:CGRectZero];
            NSTextField *jct = [[NSTextField alloc]initWithFrame:CGRectMake(0, 10, 100, 20)];
            jct.alignment = NSTextAlignmentCenter;
            if (_st == RecommedType) {
                jct.editable = NO;
                jct.placeholderString = @"\\";

            }else {
                jct.editable = YES;
                jct.delegate = self;
                jct.tag = row;
                NSString *jcStr =  [self.ccDic objectForKey:model.fundcode];

                if (jcStr.length > 0) {
                              jct.stringValue = jcStr;
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
- (void)tableView:(NSTableView *)tableView didClickMenuDelete:(NSInteger)row {
//    NSLog(@"didClickMenuDelete===%ld",(long)row);
    [[DataManager manger]deleteData:row source:_st resp:^(id resp) {
        [self refreshData];
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
     if (![self isPureFloat:jcStr]) {
        [AlertTool showAlert:@"请输入正确金额[0123456789.]，兄弟" actionTitle1:@"明白" actionTitle2:@"" window:[self.view window] action:nil];
     }else {
         [self.ccDic setValue:[NSString stringWithFormat:@"%@",jcStr] forKey:model.fundcode];
         [[DataManager manger]saveInvestedMoney:self.ccDic];
         [self refreshData];
     }
    }
    }
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self UISet];
    [self loadData];
}

- (void)viewWillDisappear {
    dispatch_source_cancel(self.timer);
}

- (BOOL)isPureFloat:(NSString*)string {
    NSScanner *scan = [NSScanner scannerWithString:string];
 
    float val;
 
    return [scan scanFloat:&val] && [scan isAtEnd];
}

@end
