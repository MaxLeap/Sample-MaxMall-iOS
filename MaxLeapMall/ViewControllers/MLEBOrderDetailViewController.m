//
//  MLEBOrderDetailViewController.m
//  MaxLeapMall
//
//  Created by julie on 15/11/20.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBOrderDetailViewController.h"
#import "MLEBOnlinePaymentViewController.h"

#define kOrderStatusCellIdentifier          @"MLEBOrderStatusTableViewCell"
#define kOrderItemCellIdentifier            @"MLEBOrderItemBriefInfoCell"
#define kOrderDetailCellIdentifier          @"MLEBOrderDetailCell"

@interface MLEBOrderDetailViewController () <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *bottomActionButton;

@property (nonatomic, strong) MLEBOrderItem *selectedOrderItem;

@end

@implementation MLEBOrderDetailViewController

#pragma mark - init Method

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title = NSLocalizedString(@"订单详情", @"");
    
    [self configureTableView];
    [self configureBottomView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [self updateBottomViewStatus];
    
    self.navigationController.delegate = self;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.navigationController.delegate = nil;
}

#pragma mark- SubView Configuration
- (void)configureTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 110;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.sectionHeaderHeight = 10;
    self.tableView.sectionFooterHeight = CGFLOAT_MIN;
}

- (void)configureBottomView {
    self.bottomActionButton.backgroundColor = UIColorFromRGB(0xFF7700);
    [self.bottomActionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.bottomActionButton.layer.cornerRadius = 2;
    
    [self updateBottomViewStatus];
}

- (void)updateBottomViewStatus {
    if ([self.order.orderStatus integerValue] == MLEBOrderStatusInDelivery || [self.order.orderStatus integerValue] == MLEBOrderStatusReceived) {
        NSString *buttonTitle = (self.order.orderStatus.integerValue == MLEBOrderStatusInDelivery) ? NSLocalizedString(@"确认送达", @"") : NSLocalizedString(@"去评价", @"");
        [self.bottomActionButton setTitle:buttonTitle forState:UIControlStateNormal];
    } else {
        self.bottomView.hidden = YES;
        self.tableViewBottomConstraint.constant = 0;
    }
}

#pragma mark- Action
- (IBAction)bottomActionButtonPressed:(id)sender {
    if (self.order.orderStatus.integerValue == MLEBOrderStatusInDelivery) {
        
        [kSharedWebService confirmReceivalForOrder:self.order completion:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [SVProgressHUD showSuccessWithStatus:@"确认成功!"];
                [self configureBottomView];
                
            } else {
                if (error.code == 100) {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络连接超时", nil)];
                } else {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"出错了", nil)];
                }
            }
        }];
        
    } else {
        
        [self performSegueWithIdentifier:@"MLEBSubmitCommentViewControllerSegueIdentifier" sender:nil];
    }
}

#pragma mark- Delegate，DataSource, Callback Method
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? 1 + self.order.orderItems.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            MLEBOrderStatusTableViewCell *statusCell = [tableView dequeueReusableCellWithIdentifier:kOrderStatusCellIdentifier forIndexPath:indexPath];
            [statusCell configureCell:self.order];
            
            statusCell.payOrderHandler = ^{
                [self performSegueWithIdentifier:@"MLEBOnlinePaymentViewControllerSegueIdentifier" sender:nil];
            };
            
            statusCell.cancelOrderHandler = ^{
                [SVProgressHUD showWithStatus:@"加载中"];
                
                [kSharedWebService cancelOrder:self.order completion:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        [SVProgressHUD showSuccessWithStatus:@"取消成功!"];
                        
                        [self trackOrderCancellationEvent];
                        
                        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    } else {
                        if (error.code == 100) {
                            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络连接超时", nil)];
                        } else {
                            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"出错了", nil)];
                        }
                    }
                }];
            };
            
            cell = statusCell;
            
        } else {
            MLEBOrderItemBriefInfoCell *orderItemCell = [tableView dequeueReusableCellWithIdentifier:kOrderItemCellIdentifier forIndexPath:indexPath];
            MLEBOrderItem *orderItem = self.order.orderItems[indexPath.row - 1];
            [orderItemCell configureCell:orderItem];
            cell = orderItemCell;
        }
        
    } else {
        
        MLEBOrderDetailCell *orderDetailCell = [tableView dequeueReusableCellWithIdentifier:kOrderDetailCellIdentifier forIndexPath:indexPath];
        [orderDetailCell configureCell:self.order];
        
        cell = orderDetailCell;
    }

    return cell;
}

- (void)trackOrderCancellationEvent {
    __block NSString *productIds = @"", *productNames = @"";
    __block int totalCount = 0;
    __block NSDecimalNumber *price = [NSDecimalNumber decimalNumberWithString:@"0"];
    [self.order.orderItems enumerateObjectsUsingBlock:^(MLEBOrderItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        productIds = [productIds stringByAppendingString:obj.product.mlObjectId];
        productNames = [productNames stringByAppendingString:obj.product.title];
        totalCount += obj.quantity.intValue;
        price = [price decimalNumberByAdding:obj.price];
    }];
    [MLAnalytics trackEvent:@"CancelOrder"
                 parameters:@{@"OrderNo":SAFE_STRING(self.order.orderId),
                              @"ProductIds": SAFE_STRING(productIds),
                              @"ProductNames": SAFE_STRING(productNames),
                              @"TotalBuyCount": [@(totalCount) stringValue],
                              @"Price":price.stringValue,
                              @"UserName":SAFE_STRING(kSharedWebService.currentUser.username)
                              }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row > 0) {
        self.selectedOrderItem = self.order.orderItems[indexPath.row - 1];
        [self performSegueWithIdentifier:@"MLEBProductViewControllerSegueIdentifier" sender:nil];
    }
    
}

#pragma mark - UINavigationControllerDelegate
/*- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSLog(@"will show %@, nav.vcs = %@", viewController, navigationController.viewControllers);
}*/

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    NSArray *viewControllers = navigationController.viewControllers;
    __block BOOL isSubmittingOrder = NO;
    [viewControllers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[MLEBSubmitOrderViewController class]]) {
            isSubmittingOrder = YES;
            *stop = YES;
        }
    }];
    
    if (isSubmittingOrder) {
        navigationController.viewControllers = @[[viewControllers firstObject], [viewControllers lastObject]];
    }
}

#pragma mark- Override Parent Method

#pragma mark- Private Method

#pragma mark- Getter Setter

#pragma mark- Helper Method

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MLEBProductViewControllerSegueIdentifier"]) {
        MLEBProductViewController *vcProduct = [segue destinationViewController];
        vcProduct.product = self.selectedOrderItem.product;
        vcProduct.selectedCustomInfo1 = self.selectedOrderItem.selected_custom_info1;
        vcProduct.selectedCustomInfo2 = self.selectedOrderItem.selected_custom_info2;
        vcProduct.selectedCustomInfo3 = self.selectedOrderItem.selected_custom_info3;
        
    } else if ([segue.identifier isEqualToString:@"MLEBSubmitCommentViewControllerSegueIdentifier"]) {
        MLEBSubmitCommentViewController *vcSubmitOrder = [segue destinationViewController];
        vcSubmitOrder.order = self.order;
    } else if ([segue.identifier isEqualToString:@"MLEBOnlinePaymentViewControllerSegueIdentifier"]) {
        MLEBOnlinePaymentViewController *vc = [segue destinationViewController];
        vc.order = self.order;
    }

}


@end
