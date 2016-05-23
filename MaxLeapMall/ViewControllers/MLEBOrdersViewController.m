//
//  MLEBOrdersViewController.m
//  MaxLeapMall
//
//  Created by julie on 15/11/17.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBOrdersViewController.h"
#import "MLEBOnlinePaymentViewController.h"

#define kAutoConfirmReceivalTimeInterval       (3600 * 24 * 7)

#define kOrderStatusCellIdentifier          @"MLEBOrderStatusTableViewCell"
#define kOrderItemCellIdentifier            @"MLEBOrderItemBriefInfoCell"
#define kOrderOverallInfoCellIdentifier     @"MLEBOrderOverallInfoCell"
#define kOrderActionButtonCellIdentifier    @"MLEBOrderActionButtonCell"

@interface MLEBOrdersViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *emptyNotesLabel;

@property (nonatomic, strong) NSMutableArray *orders;
@property (nonatomic, strong) MLEBOrder *selectedOrder;
@property (nonatomic, strong) MLEBOrderItem *selectedOrderItem;

@property (nonatomic, assign) NSUInteger pageNumber;

@end

@implementation MLEBOrdersViewController

#pragma mark - init Method


#pragma mark- View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"我的订单", nil);
    
    [self configureSubViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView triggerPullToRefresh];
}

- (void)fetchDataAndUpdateViewsWithPullTopToRefresh:(BOOL)didPullTopToRefresh {
    NSUInteger pageNumber = didPullTopToRefresh ? self.pageNumber : (self.pageNumber + 1);
    [kSharedWebService fetchOrdersFromPage:pageNumber completion:^(NSArray<MLEBOrder *> *orders, BOOL didReachEnd, NSError *error) {
        execute_after_main_queue(0.2, ^{
            [self.tableView.pullToRefreshView stopAnimating];
            [self.tableView.infiniteScrollingView stopAnimating];
        });
        
        self.tableView.showsInfiniteScrolling = !didReachEnd;
        
        if (error) {
            if (error.code == NSURLErrorTimedOut) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络连接超时", nil)];
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"出错了", nil)];
            }
            DDLogInfo(@"error: %@", [error localizedDescription]);
            return;
        }
        
        if (!didPullTopToRefresh) {
            self.pageNumber++;
        }
        
        if (didPullTopToRefresh) {
            [self.orders removeAllObjects];
        }
        [self.orders addObjectsFromArray:orders];
        [self reloadViews];
        
        [self.orders enumerateObjectsUsingBlock:^(MLEBOrder *  _Nonnull order, NSUInteger idx, BOOL * _Nonnull stop) {
            if (order.orderStatus.integerValue == MLEBOrderStatusInDelivery && [[NSDate date] timeIntervalSinceDate:order.updatedAt] > kAutoConfirmReceivalTimeInterval) {
                [kSharedWebService confirmReceivalForOrder:order completion:^(BOOL succeeded, NSError *error) {
                    order.orderStatus = @(MLEBOrderStatusReceived);
                    
                    if (!self.tableView.isDragging) {
                        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:idx] withRowAnimation:UITableViewRowAnimationNone];
                    }
                }];
            }
        }];
    }];
}


- (void)reloadViews {
    [self.tableView reloadData];
    
    if (self.orders.count > 0) {
        self.emptyNotesLabel.hidden = YES;
        
    } else {
        self.emptyNotesLabel.hidden = NO;
    }
}

#pragma mark- SubView Configuration
- (void)configureSubViews {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    __weak typeof(self) wSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        wSelf.emptyNotesLabel.hidden = YES;
        wSelf.tableView.showsInfiniteScrolling = NO;
        
        self.pageNumber = 0;
        [wSelf fetchDataAndUpdateViewsWithPullTopToRefresh:YES];
    }];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        wSelf.emptyNotesLabel.hidden = YES;
        
        [wSelf fetchDataAndUpdateViewsWithPullTopToRefresh:NO];
    }];
    
    self.emptyNotesLabel.font = [UIFont systemFontOfSize:30];
    self.emptyNotesLabel.textColor = [UIColor lightGrayColor];
    self.emptyNotesLabel.text = NSLocalizedString(@"暂无订单", nil);
    self.emptyNotesLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyNotesLabel.hidden = YES;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
}

#pragma mark- Action

#pragma mark- Delegate，DataSource, Callback Method
#pragma mark - Table view data source
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == self.orders.count - 1) {
        return 10;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MLEBOrder *order = self.orders[indexPath.section];
    if (indexPath.row == 0) {
        return 48;
        
    } else if (indexPath.row > 0 && indexPath.row <= order.orderItems.count) {
        return 110;
        
    } else if (indexPath.row == order.orderItems.count + 1) {
        return 78;
        
    } else {
        return 60;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.orders.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    MLEBOrder *order = self.orders[section];
    NSUInteger rowCount = order.orderItems.count + 2;
    if ([order.orderStatus integerValue] == MLEBOrderStatusInDelivery || [order.orderStatus integerValue] == MLEBOrderStatusReceived) {
        rowCount++;
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MLEBOrder *order = self.orders[indexPath.section];
    UITableViewCell *cell = nil;
   
    if (indexPath.row == 0) {
        MLEBOrderStatusTableViewCell *statusCell = [tableView dequeueReusableCellWithIdentifier:kOrderStatusCellIdentifier forIndexPath:indexPath];
        [statusCell configureCell:order];
        
        statusCell.payOrderHandler = ^{
            self.selectedOrder = self.orders[indexPath.section];
            [self performSegueWithIdentifier:@"MLEBOnlinePaymentViewControllerSegueIdentifier" sender:nil];
        };
        
        statusCell.cancelOrderHandler = ^{
            [SVProgressHUD showWithStatus:@"加载中"];
            
            [kSharedWebService cancelOrder:order completion:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [SVProgressHUD showSuccessWithStatus:@"取消成功!"];
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
        
        
    } else if (indexPath.row > 0 && indexPath.row <= order.orderItems.count) {
        MLEBOrderItemBriefInfoCell *orderItemCell = [tableView dequeueReusableCellWithIdentifier:kOrderItemCellIdentifier forIndexPath:indexPath];
        MLEBOrderItem *orderItem = order.orderItems[indexPath.row - 1];
        [orderItemCell configureCell:orderItem];
        cell = orderItemCell;
        
    } else if (indexPath.row == order.orderItems.count + 1) {
        MLEBOrderOverallInfoCell *orderInfoCell = [tableView dequeueReusableCellWithIdentifier:kOrderOverallInfoCellIdentifier forIndexPath:indexPath];
        NSDecimalNumber *totalPriceNumber = [order.totalPrice decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:100]];
        orderInfoCell.totalPriceLabel.text = [NSString stringWithFormat:@"%@: ￥%@", NSLocalizedString(@"总额", @""), totalPriceNumber];
        orderInfoCell.orderTimeLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"下单时间", @""), [order.createdAt detailedHumanDateString]];
        cell = orderInfoCell;
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    } else if (indexPath.row == order.orderItems.count + 2) {
        MLEBOrderActionButtonCell *actionButtonCell = [tableView dequeueReusableCellWithIdentifier:kOrderActionButtonCellIdentifier forIndexPath:indexPath];
        NSString *buttonTitle = (order.orderStatus.integerValue == MLEBOrderStatusInDelivery) ? NSLocalizedString(@"确认送达", @"") : NSLocalizedString(@"去评价", @"");
        [actionButtonCell.actionButton setTitle:buttonTitle forState:UIControlStateNormal];
        actionButtonCell.actionHandler = ^{
            
            if (order.orderStatus.integerValue == MLEBOrderStatusInDelivery) {
                [kSharedWebService confirmReceivalForOrder:order completion:^(BOOL succeeded, NSError *error) {
                    if (succeeded && !error) {
                        [SVProgressHUD showSuccessWithStatus:@"已确认送达"];
                        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
                        
                    } else {
                        if (error.code == NSURLErrorTimedOut) {
                            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络连接超时", nil)];
                        } else {
                            [SVProgressHUD showErrorWithStatus:@"出错了"];
                        }
                    }
                }];
            } else {
                self.selectedOrder = order;
                [self performSegueWithIdentifier:@"MLEBSubmitCommentViewControllerSegueIdentifier" sender:nil];
            }
        };
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell = actionButtonCell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedOrder = self.orders[indexPath.section];
    
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"MLEBOrderDetailViewControllerSegueIdentifier" sender:nil];
        
    } else if (indexPath.row <= self.selectedOrder.orderItems.count) {
        self.selectedOrderItem = self.selectedOrder.orderItems[indexPath.row - 1];
        [self performSegueWithIdentifier:@"MLEBProductViewControllerSegueIdentifier" sender:nil];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.tableView reloadData];
}

#pragma mark- Override Parent Method
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *vc = [segue destinationViewController];
    if ([vc isKindOfClass:[MLEBOrderDetailViewController class]]) {
        MLEBOrderDetailViewController *vcOrderDetail = (MLEBOrderDetailViewController *)vc;
        vcOrderDetail.order = self.selectedOrder;
        
    } else if ([vc isKindOfClass:[MLEBSubmitCommentViewController class]]) {
        MLEBSubmitCommentViewController *vcSubmitComment = (MLEBSubmitCommentViewController *)vc;
        vcSubmitComment.order = self.selectedOrder;
        
    } else if ([vc isKindOfClass:[MLEBProductViewController class]]) {
        MLEBProductViewController *vcProduct = (MLEBProductViewController *)vc;
        vcProduct.product = self.selectedOrderItem.product;
        vcProduct.selectedCustomInfo1 = self.selectedOrderItem.selected_custom_info1;
        vcProduct.selectedCustomInfo2 = self.selectedOrderItem.selected_custom_info2;
        vcProduct.selectedCustomInfo3 = self.selectedOrderItem.selected_custom_info3;
    } else if ([vc isKindOfClass:[MLEBOnlinePaymentViewController class]]) {
        MLEBOnlinePaymentViewController *vcPayment = [segue destinationViewController];
        vcPayment.order = self.selectedOrder;
    }
}

#pragma mark- Private Method

#pragma mark- Getter Setter
- (NSMutableArray *)orders {
    if (!_orders) {
        _orders = [NSMutableArray array];
    }
    return _orders;
}

#pragma mark- Helper Method


@end
