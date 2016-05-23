//
//  MLEBInvoiceContentController.m
//  MaxLeapMall
//
//  Created by julie on 15/11/23.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBInvoiceContentController.h"

@interface MLEBInvoiceContentController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MLEBInvoiceContentController

#pragma mark - init Method

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"下一步", @"") style:UIBarButtonItemStyleDone target:self action:@selector(nextStepButtonPressed:)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark- SubView Configuration
- (void)nextStepButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"MLEBInvoiceHeadingViewControllerSegueIdentifier" sender:nil];
}

#pragma mark- Action

#pragma mark- Delegate，DataSource, Callback Method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [self textForCellAtIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

- (NSString *)textForCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = nil;
    switch (indexPath.row) {
        case 0: text = NSLocalizedString(@"商品明细", @""); break;
        case 1: text = NSLocalizedString(@"办公用品", @""); break;
        case 2: text = NSLocalizedString(@"电脑配件", @""); break;
        case 3: text = NSLocalizedString(@"耗材", @""); break;
        default:
            break;
    }
    return text;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.receipt.content = [self textForCellAtIndexPath:indexPath];
    
    for (NSUInteger i = 0; i < 4; i++) {
        NSIndexPath *indexP = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexP];
        if (indexP.row == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

#pragma mark- Override Parent Method

#pragma mark- Private Method

#pragma mark- Getter Setter

#pragma mark- Helper Method

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MLEBInvoiceHeadingViewController *vcInvoiceContent = [segue destinationViewController];
    vcInvoiceContent.receipt = self.receipt;
}


@end
