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

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self UISet];
    [self loadData];
}
- (void)UISet {
    
    self.codeTableV.delegate = (id)self;
    self.codeTableV.dataSource = self;
    self.codeTableV.mhdelegate = self;

    [self.codeTableV registerForDraggedTypes:@[NSPasteboardTypeString]];
    self.codeTableV.draggingDestinationFeedbackStyle = NSTableViewDraggingDestinationFeedbackStyleSourceList;

    _st = RecommedType;
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
    self.shang1Label.stringValue = szhm.f4;
    self.hu1Label.stringValue = hsm.f4;
    self.shen1Label.stringValue = scm.f4;
    
    
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
    
    NSString *codeStr = self.codeTf.stringValue;
    
    [[DataManager manger]addData:codeStr source:_st resp:^(id  _Nonnull result, AlertType at) {
        
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
       }else{
        _st = RecommedType;
        sender.title = @"推荐源";
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
- (void)refreshData {
    [[DataManager manger]loadData:_st resp:^(id  _Nonnull resp) {
          self.modelsAry = resp;
          [self.codeTableV reloadData];
    }];
    [NetTool getIndexInfo:^(NSArray <FundModel *>*mArray) {
            
           [self configureUI:mArray];
                   
    }];
}

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
    }else{
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell3" owner:nil];
        cell.textField.stringValue = model.gztime;
        return cell;
    }
  
}
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

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 40;
}
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    NSLog(@"shouldSelectRow==%ld",(long)row);
    return YES;
}
- (void)tableView:(NSTableView *)tableView didClickMenuDelete:(NSInteger)row {
    NSLog(@"didClickMenuDelete===%ld",(long)row);
    [[DataManager manger]deleteData:row source:_st resp:^(id resp) {
        [self refreshData];
    }];
}
- (void)viewWillDisappear {
    dispatch_source_cancel(self.timer);
}
@end
