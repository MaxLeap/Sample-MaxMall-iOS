//
//  MLEBOnlinePaymentViewController.m
//  MLAppMaker
//
//  Created by julie on 15/12/31.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//
@import MaxLeapPay;
#import "MLEBOnlinePaymentViewController.h"
#import "WXApi.h"
#import "MaxPaymentManager.h"

@interface MLEBOnlinePaymentViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, assign) NSInteger paymentMethod;
@end

@implementation MLEBOnlinePaymentViewController
#pragma mark - init Method

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"付款方式";
    
    [self configureTableView];
    self.paymentMethod = 0;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}


#pragma mark- Override Parent Methods
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark- SubViews Configuration
- (void)configureTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 129;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        return 20;
    }
    
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

#pragma mark -UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier1 = @"Cell1";
    static NSString *CellIdentifier2 = @"Cell2";
    static NSString *CellIdentifier3 = @"Cell3";
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        UILabel *label = [cell viewWithTag:100];
        NSDecimalNumber *price = [self.order.totalPrice decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100"]];
        label.text = [NSString stringWithFormat:@"支付金额:￥%@", price];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
        return cell;
    }
    
    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];

        UIImageView *imgView = [cell viewWithTag:100];
        UILabel *label = [cell viewWithTag:101];
        UIImageView *checkImageView = [cell viewWithTag:102];
        checkImageView.image = ImageNamed(@"ic_pay_normal");

        
        if (indexPath.row == 0) {
            imgView.image = ImageNamed(@"ic_pay_with_alipay");
            label.text = @"支付宝";
            if (self.paymentMethod == 0) {
                checkImageView.image = [ImageNamed(@"ic_pay_selected") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
        }
        
        if (indexPath.row == 1) {
            imgView.image = ImageNamed(@"ic_pay_with_wechat");
            label.text = @"微信支付";
            if (self.paymentMethod == 1) {
                checkImageView.image = [ImageNamed(@"ic_pay_selected") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
        }
        
        if (indexPath.row == 2) {
            imgView.image = ImageNamed(@"ic_pay_with_unionpay");
            label.text = @"银联支付";
            if (self.paymentMethod == 2) {
                checkImageView.image = [ImageNamed(@"ic_pay_selected") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
        UIButton *btn = [cell viewWithTag:100];
        [btn setTitle:@"确认支付" forState:UIControlStateNormal];
        btn.layer.cornerRadius = 2;
        btn.layer.masksToBounds = YES;

        [btn addTarget:self action:@selector(confirmButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
        return cell;
    }

    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 || section == 2) {
        return 1;
    }
    
    if (section == 1) {
        return 3;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {

        self.paymentMethod = indexPath.row;
        [self.tableView reloadData];
    }
}

#pragma mark- Actions
- (void)confirmButtonPressed:(id)sender {
    
    
    if (self.paymentMethod == 1 && ![WXApi isWXAppInstalled]) {
        [SVProgressHUD showErrorWithStatus:@"尚未安装微信客户端,无法支付"];
        return;
    }
    
    
    NSString *existSchemeStr = NULL;
    NSDictionary *urlTypeDic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];
    NSArray * urlTypes = urlTypeDic[@"CFBundleURLTypes"];
    if (urlTypes.count) {
        existSchemeStr = [[urlTypes firstObject][@"CFBundleURLSchemes"] firstObject];
        MLPayChannel channel = self.paymentMethod?(self.paymentMethod==1?MLPayChannelWxApp:MLPayChannelUnipayApp):MLPayChannelAliApp;
        [[MaxPaymentManager sharedManager]payWithChannel:channel
                                                 subject:@"支付"
                                                  billNo:self.order.orderId
                                                totalFen:self.order.totalPrice.floatValue
                                                  scheme:existSchemeStr
                                               returnUrl:channel==MLPayChannelUnipayApp?@"http://maxleap.cn/returnUrl":nil
                                              extraAttrs:nil
                                              completion:^(BOOL succeeded, MLPayResult *result) {
                                                  NSLog(@"pay result %@", @(succeeded));
                                                  [self.navigationController popViewControllerAnimated:YES];
                                              }];
        
    } else {
        NSLog(@"Error: no url scheme, can not pay");
    }
 
}




@end
