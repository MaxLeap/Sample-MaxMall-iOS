//
//  MLEBSubmitOrderViewController.m
//  MaxLeapMall
//
//  Created by julie on 15/11/20.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBSubmitOrderViewController.h"

@interface MLEBSubmitOrderViewController () <UITableViewDelegate, UITableViewDataSource, MLEBAddressesViewControllerProtocol, MLEBRemarksViewControllerProtocol>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (nonatomic, strong) MLEBOrder *order; //scratch context
@property (nonatomic, strong) MLEBShoppingItem *selectedShoppingItem;

@end

@implementation MLEBSubmitOrderViewController
#pragma mark - init Method

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title = NSLocalizedString(@"规格参数", @"");
    
    [self configureTableView];
    [self configureBottomView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiptConfirmed:) name:@"confirmReceiptNotification" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
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
    self.submitButton.backgroundColor = UIColorFromRGB(0xFF7700);
    [self.submitButton setTitle:NSLocalizedString(@"提交订单", @"") forState:UIControlStateNormal];
    [self.submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.submitButton.layer.cornerRadius = 2;
    
    [self.totalPriceLabel setTextColor:UIColorFromRGB(0xFF7700)];
   
    NSDecimalNumber *totalPriceNumber = [[self totalPrice] decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:100]];
    self.totalPriceLabel.text = [NSString stringWithFormat:@"￥%@", totalPriceNumber];;
}

#pragma mark- Action
- (IBAction)submitButtonPressed:(id)sender {
    if ( ! [kSharedWebService isLoggedIn]) {
        [self performSegueWithIdentifier:@"PresentLoginViewControllerIdentifier" sender:nil];
        return;
    }
    
    if (self.order.address) {
        [SVProgressHUD showWithStatus:@"正在提交..." maskType:SVProgressHUDMaskTypeBlack];
        
        [kSharedWebService submitOrder:self.order completion:^(BOOL succeeded, NSError *error) {
            [SVProgressHUD dismiss];
            
            if (succeeded && !error) {
                [SVProgressHUD showSuccessWithStatus:@"提交成功!"];
                [self trackOrderSubmitEvent];
                
                [self performSegueWithIdentifier:@"MLEBOrderDetailViewControllerSegueIdentifier" sender:nil];
                
                //delete shoppingItems
                [MLEBShoppingItem MR_truncateAllInContext:kSharedWebService.defaultContext];
                [kSharedWebService.defaultContext MR_saveToPersistentStoreAndWait];
                
                [kSharedWebService syncShoppingItemsToMaxLeapWithCompletion:nil];
                
            } else {
                if (error.code == NSURLErrorTimedOut) {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络连接超时", nil)];
                } else {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"出错了", nil)];
                }
            }
        }];
        
    } else {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请完善收货地址信息", nil)];
    }
}

- (void)trackOrderSubmitEvent {
    __block NSString *productIds = @"", *productNames = @"";
    __block int totalCount = 0;
    __block NSDecimalNumber *price = [NSDecimalNumber decimalNumberWithString:@"0"];
    [self.order.orderItems enumerateObjectsUsingBlock:^(MLEBOrderItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        productIds = [productIds stringByAppendingString:obj.product.mlObjectId];
        productNames = [productNames stringByAppendingString:obj.product.title];
        totalCount += obj.quantity.intValue;
        price = [price decimalNumberByAdding:obj.price];
    }];
    NSDictionary *par = @{@"OrderNo":SAFE_STRING(self.order.orderId),
                          @"ProductIds": SAFE_STRING(productIds),
                          @"ProductNames": SAFE_STRING(productNames),
                          @"TotalBuyCount": [@(totalCount) stringValue],
                          @"Price":price.stringValue,
                          @"Receiver":SAFE_STRING(self.order.address.name),
                          @"Phone":SAFE_STRING(self.order.address.tel),
                          @"Address":SAFE_STRING(self.order.address.street),
                          @"DeliveryType":SAFE_STRING(self.order.deliveryMethod),
                          @"NeedBill":self.order.receipt?@"ture":@"false",
                          @"UserName":SAFE_STRING(kSharedWebService.currentUser.username)
                          };
    [MLAnalytics trackEvent:@"SubmitOrder" parameters:par];
}

- (void)onReceiptConfirmed:(NSNotification *)noti {
    MLEBReceipt *receipt = (MLEBReceipt *)noti.object;
    self.order.receipt = receipt;
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark- Delegate，DataSource, Callback Method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section <= 1) {
        return 1;
    } else if (section == 2) {
        return 2;
    } else {
        return self.shoppingItems.count + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"rightDetailCellWithAccessory" forIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"请填写地址", @"");
        cell.detailTextLabel.text = self.order.address.street;
        
    } else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"rightDetailCell" forIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"付款方式", @"");
        cell.detailTextLabel.text = NSLocalizedString(@"在线支付", @"");
        
    } else if (indexPath.section == 2) {
       cell = [tableView dequeueReusableCellWithIdentifier:@"rightDetailCellWithAccessory" forIndexPath:indexPath];
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"备注", @"");
            cell.detailTextLabel.text = self.order.remarks;
        } else {
            cell.textLabel.text = NSLocalizedString(@"发票信息", @"");
            if (!self.order.receipt) {
                cell.detailTextLabel.text = NSLocalizedString(@"不需要发票", @"");
            } else {
                cell.detailTextLabel.text = self.order.receipt.type;
            }
        }
        
    } else {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"rightDetailCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"显示参数", @"");
            
        } else {
            
            MLEBShoppingItemInfoCell *itemCell = [tableView dequeueReusableCellWithIdentifier:@"MLEBShoppingItemInfoCell" forIndexPath:indexPath];
            MLEBShoppingItem *shoppingItem = self.shoppingItems[indexPath.row - 1];
            [itemCell configureCell:shoppingItem];
            
            cell = itemCell;
        }
    }
    
    cell.textLabel.textColor = UIColorFromRGB(0x404040);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"MLEBAddressesViewControllerSegueIdentifier" sender:nil];
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"MLEBRemarksViewControllerSegueIdentifier" sender:nil];
        
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        [self performSegueWithIdentifier:@"MLEBInvoiceTypeViewControllerSegueIdentifier" sender:nil];
    
    } else if (indexPath.section == 3 && indexPath.row > 0) {
        self.selectedShoppingItem = self.shoppingItems[indexPath.row - 1];
        [self performSegueWithIdentifier:@"MLEBProductViewControllerSegueIdentifier" sender:nil];
    }
}

#pragma mark - MLEBAddressesViewController delegate
- (void)addingAddressViewControllerDidSelectAddress:(MLEBAddress *)address {
    if (address.managedObjectContext == self.order.managedObjectContext) {
        self.order.address = address;
    } else {
        MLEBAddress *addressInScratchContext = [MLEBAddress MR_createEntityInContext:kSharedWebService.scratchContext];
        addressInScratchContext.name = address.name;
        addressInScratchContext.street = address.street;
        addressInScratchContext.tel = address.tel;
        addressInScratchContext.mlObject = address.mlObject;
        self.order.address = addressInScratchContext;
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - MLEBRemarksViewController delegate
- (void)remarksViewController:(MLEBRemarksViewController *)vc didSetRemarks:(NSString *)remarksString {
    self.order.remarks = remarksString;
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark- Override Parent Method
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark- Private Method

#pragma mark- Getter Setter

#pragma mark- Helper Method
- (NSDecimalNumber *)totalPrice {
    __block NSUInteger totalPrice = 0;
    [self.shoppingItems enumerateObjectsUsingBlock:^(MLEBShoppingItem *  _Nonnull shoppingItem, NSUInteger idx, BOOL * _Nonnull stop) {
        totalPrice += (shoppingItem.quantity.integerValue * [shoppingItem.product.price integerValue]);
    }];
    NSDecimalNumber *totalPriceNumber = [[NSDecimalNumber alloc] initWithInt:(int)totalPrice];
    return totalPriceNumber;
}

- (MLEBOrder *)order {
    if (!_order) {
        _order = [MLEBOrder MR_createEntityInContext:kSharedWebService.scratchContext];
        [self.shoppingItems enumerateObjectsUsingBlock:^(MLEBShoppingItem *  _Nonnull shoppingItem, NSUInteger idx, BOOL * _Nonnull stop) {
            MLEBOrderItem *orderItem = [MLEBOrderItem MR_createEntityInContext:kSharedWebService.scratchContext];
            orderItem.price = shoppingItem.product.price;
            orderItem.quantity = shoppingItem.quantity;
            orderItem.order = _order;
            orderItem.product = shoppingItem.product;
            orderItem.custom_infos = shoppingItem.custom_infos;
            orderItem.selected_custom_info1 = shoppingItem.selected_custom_info1;
            orderItem.selected_custom_info2 = shoppingItem.selected_custom_info2;
            orderItem.selected_custom_info3 = shoppingItem.selected_custom_info3;
        }];
        
        _order.totalPrice = [self totalPrice];
        
        //default value
        _order.payMethod = NSLocalizedString(@"在线支付", @"");
        _order.deliveryMethod = NSLocalizedString(@"京东自营快递", @"");
    }
    
    return _order;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *vc = [segue destinationViewController];
    if ([vc isKindOfClass:[MLEBOrderDetailViewController class]]) {
        MLEBOrderDetailViewController *vcOrderDetail = (MLEBOrderDetailViewController *)vc;
        vcOrderDetail.order = self.order;
    
    } else if ([vc isKindOfClass:[MLEBAddressesViewController class]]) {
        MLEBAddressesViewController *vcAddresses = (MLEBAddressesViewController *)vc;
        vcAddresses.delegate = self;
        
    } else if ([vc isKindOfClass:[MLEBRemarksViewController class]]) {
        MLEBRemarksViewController *vcRemarks = (MLEBRemarksViewController *)vc;
        vcRemarks.delegate = self;
        
    } else if ([vc isKindOfClass:[MLEBProductViewController class]]) {
        MLEBProductViewController *vcProduct = (MLEBProductViewController *)vc;
        vcProduct.product = self.selectedShoppingItem.product;
        vcProduct.selectedCustomInfo1 = self.selectedShoppingItem.selected_custom_info1;
        vcProduct.selectedCustomInfo2 = self.selectedShoppingItem.selected_custom_info2;
        vcProduct.selectedCustomInfo3 = self.selectedShoppingItem.selected_custom_info3;
    }
}


@end
