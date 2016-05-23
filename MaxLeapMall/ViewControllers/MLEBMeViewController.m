//
//  MLEBMeViewController.m
//  MaxLeapMall
//
//  Created by julie on 15/11/16.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBMeViewController.h"

@interface MLEBMeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MLEBMeViewController

#pragma mark - init Method

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.parentController.title = NSLocalizedString(@"我的", nil);
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark- SubView Configuration

#pragma mark- Action

#pragma mark- Delegate，DataSource, Callback Method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 || section == 2) {
        return 1;
    } else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = NSLocalizedString(@"帐户信息", @"");
        
    } else if (indexPath.section == 1) {
        cell.textLabel.text = (indexPath.row == 0) ? NSLocalizedString(@"我的喜欢", @"") : NSLocalizedString(@"我的订单", @"");
        [cell addBottomBorderWithColor:UIColorFromRGB(0xE2E1E6) width:0.5];
    } else {
        cell.textLabel.text = NSLocalizedString(@"服务中心", @"");
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *segueIdentifier = nil;
    
    if ( ! [kSharedWebService isLoggedIn]) {
        segueIdentifier = (indexPath.section == 2) ? @"MLEBWebViewControllerSegueIdentifier" : @"MLEBLoginControllerSegueIdentifier";
        
    } else {
        if (indexPath.section == 0) {
            segueIdentifier = @"MLEBAccountInfoControllerSegueIdentifier";
            
        } else if (indexPath.section == 1) {
            segueIdentifier = (indexPath.row == 0) ? @"MLEBFavoritesViewControllerSegueIdentifier" : @"MLEBOrdersViewControllerSegueIdentifier";
            
        } else {
            segueIdentifier = @"MLEBWebViewControllerSegueIdentifier";
        }
    }
 
    [self performSegueWithIdentifier:segueIdentifier sender:nil];
}

#pragma mark- Override Parent Method

#pragma mark- Private Method

#pragma mark- Getter Setter

#pragma mark- Helper Method

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *vc = [segue destinationViewController];
    if ([vc isKindOfClass:[MLEBWebViewController class]]) {
        MLEBWebViewController *vcWebView = (MLEBWebViewController *)vc;
        vcWebView.urlString = @"https://maxleap.cn/zh_cn/index.html";
        vcWebView.titleString = @"MaxLeap";
    }
}

@end
