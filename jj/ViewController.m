//
//  ViewController.m
//  jj
//
//  Created by LY_MD on 2020/7/17.
//  Copyright © 2020 LY_MD. All rights reserved.
//

#import "ViewController.h"
#import "AlertTool.h"
#import "DataManager.h"

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
    
}

- (IBAction)resetClick:(id)sender {
    
    [AlertTool showAlert:@"数据将恢复至默认基金排行榜（天天基金榜十，跟着榜单走，没准能吃到基肉哦）" actionTitle1:@"好的" actionTitle2:@"取消" window:[self.view window] action:^(AlertResponse resp) {
        if (resp == FirstResp) {
            [[DataManager manger]resetDefaultData:^(id resp) {
                [self refreshData];
            }];
        }
    }];
    
}

- (IBAction)addClick:(id)sender {
    
    NSString *codeStr = self.codeTf.stringValue;
    
    [[DataManager manger]addData:codeStr resp:^(id  _Nonnull result, AlertType at) {
        
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
    [[DataManager manger]loadData:^(id  _Nonnull resp) {
          self.modelsAry = resp;
          [self.codeTableV reloadData];
    }];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.modelsAry.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    FundModel *model = self.modelsAry[row];
    if (tableColumn == tableView.tableColumns[0]) {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell1" owner:nil];
        cell.textField.stringValue = model.name;
        return cell;

    }else if (tableColumn == tableView.tableColumns[1]) {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"cell2" owner:nil];
        cell.textField.stringValue = model.gszzl;
        if ([model.gszzl containsString:@"-"]) {
            cell.textField.textColor = [NSColor greenColor];
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

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 40;
}
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    NSLog(@"shouldSelectRow==%ld",(long)row);
    return YES;
}
- (void)tableView:(NSTableView *)tableView didClickMenuDelete:(NSInteger)row {
    NSLog(@"didClickMenuDelete===%ld",(long)row);
    [[DataManager manger]deleteData:row resp:^(id resp) {
        [self refreshData];
    }];
}
- (void)viewWillDisappear {
    dispatch_source_cancel(self.timer);
}
@end