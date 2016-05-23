//
//  MLEBShoppingCartController.m
//  MaxLeapMall
//
//  Created by julie on 15/11/16.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBShoppingCartController.h"

@interface MLEBShoppingCartController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UILabel *emptyNotesLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewHomePageButton;

@property (nonatomic, strong) NSArray<MLEBShoppingItem*> *shoppingItemsInScratchCtx;
@property (nonatomic, strong) MLEBShoppingItem *selectedShoppingItem;

@end

@implementation MLEBShoppingCartController
#pragma mark - init Method

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"购物车", @"");
    self.parentController.title = NSLocalizedString(@"购物车", nil);
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self configureSubViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = self.shouldHideTabBar;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [self loadData];
    [self reloadViews];
    [self.tableView triggerPullToRefresh];
}

- (void)loadData {
    NSArray *shoppingItemsInDefaultCtx = [MLEBShoppingItem MR_findAllSortedBy:@"createdAt" ascending:NO];

    NSMutableArray *shoppingItemsInScratchCtx = [NSMutableArray array];
    [shoppingItemsInDefaultCtx enumerateObjectsUsingBlock:^(MLEBShoppingItem *  _Nonnull itemInDefaultCtx, NSUInteger idx, BOOL * _Nonnull stop) {
        MLEBShoppingItem *itemInScratchCtx = [MLEBShoppingItem cloneShoppingItem:itemInDefaultCtx toContext:kSharedWebService.scratchContext];
        [shoppingItemsInScratchCtx addObject:itemInScratchCtx];
    }];
    
    self.shoppingItemsInScratchCtx = [NSArray arrayWithArray:shoppingItemsInScratchCtx];
}

- (void)fetchDataAndUpdateViews {
    [kSharedWebService fetchShoppingItemsWithCompletion:^(NSArray *shoppingItemsFromScratchCtx, NSError *error) {
        execute_after_main_queue(0.2, ^{
            [self.tableView.pullToRefreshView stopAnimating];
        });
        
        if (!error) {
            self.shoppingItemsInScratchCtx = shoppingItemsFromScratchCtx;//提交订单至MaxLeap时需要将orderItem中的"product"赋为orderItem.product.mlObject —— 所以需要使用完成块中返回的数据（mlObject的数据依然保留）；来自defaultContext中的数据中, orderItem.product.mlObject为空
            [self reloadViews];
            
        } else {
            if (error.code == NSURLErrorTimedOut) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络连接超时", nil)];
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"出错了", nil)];
            }
        }
    }];
}

- (void)reloadViews {
    if (self.shoppingItemsInScratchCtx.count > 0) {
        [self.tableView reloadData];
        [self updateTotalPriceLabel];
        
        self.emptyView.hidden = YES;
        self.tableView.hidden = NO;
        
        [self rightBarButtonItem].title = self.tableView.isEditing ? @"完成" : @"编辑";
        
    } else {
        self.emptyView.hidden = NO;
        self.tableView.hidden = YES;
        
        [self rightBarButtonItem].title = nil;
    }
    
    if (self.shoppingItemsInScratchCtx.count > 0) {
        MLEBShoppingCartFooterCell *footerCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.shoppingItemsInScratchCtx.count inSection:0]];
        [footerCell setSubmitButtonEnabled:!self.tableView.isEditing];
    }
}

- (UIBarButtonItem *)rightBarButtonItem {
    if (self.parentController) {
        return self.parentController.navigationItem.rightBarButtonItem;
    } else {
        return self.navigationItem.rightBarButtonItem;
    }
}

#pragma mark- SubView Configuration
- (void)configureSubViews {
    [self configureNavigationBar];
    [self configureTableView];
    [self configureEmptyView];
}

- (void)configureNavigationBar {
    if (self.parentController) {
        self.parentController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"编辑", @"") style:UIBarButtonItemStyleDone target:self action:@selector(editButtonPressed:)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"编辑", @"") style:UIBarButtonItemStyleDone target:self action:@selector(editButtonPressed:)];
    }
}

- (void)configureTableView {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 106;
    self.tableView.sectionHeaderHeight = 10;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self updateTotalPriceLabel];
    
    __weak typeof(self) wSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [wSelf fetchDataAndUpdateViews];
    }];
}

- (void)configureEmptyView {
    self.emptyView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.emptyNotesLabel.textColor = UIColorFromRGB(0x808080);
    self.emptyNotesLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyNotesLabel.text = NSLocalizedString(@"您的购物车空空如也", @"");
    
    [self.viewHomePageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.viewHomePageButton setTitle:NSLocalizedString(@"去首页逛逛", @"") forState:UIControlStateNormal];
    self.viewHomePageButton.layer.cornerRadius = 2;
    self.viewHomePageButton.layer.masksToBounds = YES;
    self.viewHomePageButton.titleLabel.font = [UIFont systemFontOfSize:15];
    self.viewHomePageButton.backgroundColor = UIColorFromRGB(0xFF7700);
}

- (void)updateTotalPriceLabel {
    MLEBShoppingCartFooterCell *footerCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.shoppingItemsInScratchCtx.count inSection:0]];
    NSDecimalNumber *totalPriceNumber = [[self totalPrice] decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:100]];
    footerCell.totalPriceLabel.text = [NSString stringWithFormat:@"￥%@", totalPriceNumber];
}

- (NSDecimalNumber *)totalPrice {
    __block NSUInteger totalPrice = 0;
    [self.shoppingItemsInScratchCtx enumerateObjectsUsingBlock:^(MLEBShoppingItem *  _Nonnull shoppingItem, NSUInteger idx, BOOL * _Nonnull stop) {
        totalPrice += (shoppingItem.quantity.integerValue * [shoppingItem.product.price integerValue]);
    }];
    NSDecimalNumber *totalPriceNumber = [[NSDecimalNumber alloc] initWithInt:(int)totalPrice];
    return totalPriceNumber;
}

#pragma mark- Action

- (IBAction)viewHomePageButtonPressed:(id)sender {
    [self.tabBarController setSelectedIndex:0];
}

- (void)editButtonPressed:(id)sender {
    if (!self.tableView.isEditing) {
        [self.tableView setEditing:YES animated:YES];
        [self.parentController.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"完成", @"")];
        
    } else {
        [self.tableView setEditing:NO animated:YES];
        [self.parentController.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"编辑", @"")];
    }
    
    [self reloadViews];
}

#pragma mark- Delegate，DataSource, Callback Method
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.shoppingItemsInScratchCtx.count > 0) {
        return self.shoppingItemsInScratchCtx.count + 1;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.row < self.shoppingItemsInScratchCtx.count) {
        
        MLEBShoppingItemActionCell *shoppingItemCell = [tableView dequeueReusableCellWithIdentifier:@"MLEBShoppingItemActionCell" forIndexPath:indexPath];
        MLEBShoppingItem *shoppingItem = self.shoppingItemsInScratchCtx[indexPath.row];
        [shoppingItemCell configureCell:shoppingItem];
        
        __weak MLEBShoppingItemActionCell *wCell = shoppingItemCell;
        __weak typeof(self) wSelf = self;
        shoppingItemCell.plusButtonHandler = ^{
            
            NSUInteger count = shoppingItem.quantity.integerValue;
            shoppingItem.quantity = @(++count);
            wCell.quantityLabel.text = [NSString stringWithFormat:@"%@", shoppingItem.quantity];
            
            [wSelf updateTotalPriceLabel];
            
            //save data
            MLEBShoppingItem *shoppingItemInDefaultCtx = [MLEBShoppingItem MR_findFirstByAttribute:@"mlObjectId" withValue:shoppingItem.mlObjectId inContext:kSharedWebService.defaultContext];
            shoppingItemInDefaultCtx.quantity = shoppingItem.quantity;
            [kSharedWebService.defaultContext MR_saveToPersistentStoreAndWait];
            
            [kSharedWebService addOrUpdateShoppingItem:shoppingItem completion:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    
                } else {
                    if (error.code == NSURLErrorTimedOut) {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络连接超时", nil)];
                    } else {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"出错了", nil)];
                    }
                }
            }];
        };
        shoppingItemCell.minusButtonHandler = ^{
            if (shoppingItem.quantity.integerValue > 1) {
                NSUInteger count = shoppingItem.quantity.integerValue;
                shoppingItem.quantity = @(--count);
                wCell.quantityLabel.text = [NSString stringWithFormat:@"%@", shoppingItem.quantity];
                
                [wSelf updateTotalPriceLabel];
                
                //save data
                MLEBShoppingItem *shoppingItemInDefaultCtx = [MLEBShoppingItem MR_findFirstByAttribute:@"mlObjectId" withValue:shoppingItem.mlObjectId inContext:kSharedWebService.defaultContext];
                shoppingItemInDefaultCtx.quantity = shoppingItem.quantity;
                [kSharedWebService.defaultContext MR_saveToPersistentStoreAndWait];
                
                [kSharedWebService addOrUpdateShoppingItem:shoppingItem completion:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        
                    } else {
                        if (error.code == NSURLErrorTimedOut) {
                            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络连接超时", nil)];
                        } else {
                            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"出错了", nil)];
                        }
                    }
                }];
            }
        };
        if (self.shoppingItemsInScratchCtx.count > 1 && indexPath.row < self.shoppingItemsInScratchCtx.count - 1) {
            [shoppingItemCell addBottomBorderWithColor:UIColorFromRGB(0xDCDCDC) width:0.5];
        }
        
        cell = shoppingItemCell;
        
    } else {
        MLEBShoppingCartFooterCell *submitButtonCell = [tableView dequeueReusableCellWithIdentifier:@"MLEBShoppingCartFooterCell" forIndexPath:indexPath];
        submitButtonCell.submitButtonHandler = ^{
            [self performSegueWithIdentifier:@"MLEBSubmitOrderViewControllerSegueIdentifier" sender:nil];
        };
        
        NSDecimalNumber *totalPriceNumber = [[self totalPrice] decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:100]];
        submitButtonCell.totalPriceLabel.text = [NSString stringWithFormat:@"￥%@", totalPriceNumber];
        
        submitButtonCell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell = submitButtonCell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < self.shoppingItemsInScratchCtx.count) {
        self.selectedShoppingItem = self.shoppingItemsInScratchCtx[indexPath.row];
        [self performSegueWithIdentifier:@"MLEBProductViewControllerSegueIdentifier" sender:nil];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.tableView.isEditing && indexPath.row < self.shoppingItemsInScratchCtx.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if  (editingStyle == UITableViewCellEditingStyleDelete) {
        MLEBShoppingItem *shoppingItem = self.shoppingItemsInScratchCtx[indexPath.row];
        
        MLEBShoppingItem *shoppingItemInDefaultCtx = [MLEBShoppingItem MR_findFirstByAttribute:@"mlObjectId" withValue:shoppingItem.mlObjectId inContext:kSharedWebService.defaultContext];
        [shoppingItemInDefaultCtx MR_deleteEntityInContext:kSharedWebService.defaultContext];
        [kSharedWebService.defaultContext MR_saveToPersistentStoreAndWait];
        
        MLEBShoppingItem *shoppingItemInScratchCtx = [MLEBShoppingItem MR_findFirstByAttribute:@"mlObjectId" withValue:shoppingItem.mlObjectId inContext:kSharedWebService.scratchContext];
        [shoppingItemInScratchCtx MR_deleteEntityInContext:kSharedWebService.scratchContext];
        
        [self loadData];
        [self reloadViews];
        
        [kSharedWebService deleteShoppingItem:shoppingItem completion:^(BOOL succeeded, NSError *error) {
            
        }];
    }
}

#pragma mark- Override Parent Method

#pragma mark- Private Method

#pragma mark- Getter Setter

#pragma mark- Helper Method

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *vc = [segue destinationViewController];
    if ([vc isKindOfClass:[MLEBSubmitOrderViewController class]]) {
        MLEBSubmitOrderViewController *vcSubmitOrder = (MLEBSubmitOrderViewController *)vc;
        vcSubmitOrder.shoppingItems = self.shoppingItemsInScratchCtx;
        
        [self trackBalanceEvent];
        
    } else if ([vc isKindOfClass:[MLEBProductViewController class]]) {
        MLEBProductViewController *vcProduct = (MLEBProductViewController *)vc;
        vcProduct.product = self.selectedShoppingItem.product;
        vcProduct.selectedCustomInfo1 = self.selectedShoppingItem.selected_custom_info1;
        vcProduct.selectedCustomInfo2 = self.selectedShoppingItem.selected_custom_info2;
        vcProduct.selectedCustomInfo3 = self.selectedShoppingItem.selected_custom_info3;
    }
}

- (void)trackBalanceEvent {
    __block NSString *productIds = @"", *productNames = @"";
    __block int totalCount = 0;
    __block NSDecimalNumber *price = [NSDecimalNumber decimalNumberWithString:@"0"];
    [self.shoppingItemsInScratchCtx enumerateObjectsUsingBlock:^(MLEBShoppingItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        productIds = [productIds stringByAppendingString:obj.product.mlObjectId];
        productNames = [productNames stringByAppendingString:obj.product.title];
        totalCount += obj.quantity.intValue;
        price = [price decimalNumberByAdding:obj.product.price];
    }];
    [MLAnalytics trackEvent:@"Balance"
                 parameters:@{@"ProductIds": SAFE_STRING(productIds),
                              @"ProductNames": SAFE_STRING(productNames),
                              @"TotalBuyCount": [@(totalCount) stringValue],
                              @"Price":price.stringValue,
                              @"UserName":SAFE_STRING(kSharedWebService.currentUser.username)
                              }];
}

@end
