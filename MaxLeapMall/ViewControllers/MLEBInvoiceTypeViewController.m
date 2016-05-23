//
//  MLEBInvoiceTypeViewController.m
//  MaxLeapMall
//
//  Created by julie on 15/11/23.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBInvoiceTypeViewController.h"

@interface MLEBInvoiceTypeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) MLEBReceipt *receipt;

@end

@implementation MLEBInvoiceTypeViewController

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

#pragma mark- Action
- (void)nextStepButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"MLEBInvoiceContentControllerSegueIdentifier" sender:nil];
}

#pragma mark- Delegate，DataSource, Callback Method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"商业零售发票(单位)", @"");
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    } else {
        cell.textLabel.text = NSLocalizedString(@"商业零售发票(个人)", @"");
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.receipt.type = (indexPath.row == 0) ? NSLocalizedString(@"商业零售发票(单位)", @"") : NSLocalizedString(@"商业零售发票(个人)", @"");
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    UITableViewCell *nonSelectedCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:!indexPath.row inSection:0]];
    nonSelectedCell.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark- Override Parent Method

#pragma mark- Private Method

#pragma mark- Getter Setter
- (MLEBReceipt *)receipt {
    if (!_receipt) {
        _receipt = [MLEBReceipt MR_createEntityInContext:kSharedWebService.scratchContext];
        _receipt.type = NSLocalizedString(@"商业零售发票(单位)", @"");
        _receipt.content = NSLocalizedString(@"商品明细", @"");
        _receipt.heading = NSLocalizedString(@"不需要发票", @"");
    }
    return _receipt;
}

#pragma mark- Helper Method

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MLEBInvoiceContentController *vcInvoiceContent = [segue destinationViewController];
    vcInvoiceContent.receipt = self.receipt;
}


@end
