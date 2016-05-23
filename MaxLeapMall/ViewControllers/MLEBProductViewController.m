//
//  MLEBProductViewController.m
//  MaxLeapMall
//
//  Created by Michael on 11/17/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import "MLEBProductViewController.h"
#import "MLEBUser.h"

@interface MLEBProductViewController () <
UITableViewDataSource,
UITableViewDelegate,
UIPickerViewDelegate,
UIPickerViewDataSource
>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *toolBarView;
@property (weak, nonatomic) IBOutlet UIImageView *likeImageView;
@property (weak, nonatomic) IBOutlet UILabel *likeTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *shoppingCartImageView;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *shoppingCartLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmOrderButton;
@property (weak, nonatomic) IBOutlet UIView *likedButtonBGView;
@property (weak, nonatomic) IBOutlet UIView *shoppingButtonBGView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickerViewBottomConstraints;
@property (weak, nonatomic) IBOutlet UIButton *finishPickerButton;
@property (weak, nonatomic) IBOutlet UIView *buttonPanel;

@property (nonatomic, strong) MLEBShoppingItem *shoppingItem;
@property (nonatomic, assign) NSUInteger editingCustomInfoIndex; // default -1
@end

@implementation MLEBProductViewController
#pragma mark - init Method

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"商品详情", nil);
    self.editingCustomInfoIndex = -1;
    
    self.shoppingItem = [self createShoppingItem];
    [self configureTableView];
    [self configureToolBar];
    [self configurePickerView];
    [self updateShoppingCartQuantityLabel];
    
    [MLAnalytics trackEvent:@"ViewProduct"
                 parameters:@{@"ProductId":SAFE_STRING(self.product.mlObjectId),
                              @"ProductName":SAFE_STRING(self.product.title),
                              @"Price":SAFE_STRING(self.product.price.stringValue),
                              @"UserName":SAFE_STRING(kSharedWebService.currentUser.username)
                              }];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.tabBarController.tabBar.hidden = YES;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateShoppingCartQuantityLabel];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([self isMovingFromParentViewController]) {
        [self.shoppingItem MR_deleteEntity];
    }
}

#pragma mark- Override Parent Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showCommentVCIdentifer"]) {
        MLEBCommentViewController *commentVC = segue.destinationViewController;
        commentVC.product = self.product;
    }
    if ([segue.identifier isEqualToString:@"showProductInfoViewControllerIdentifier"]) {
        MLEBProductInfoParameterViewController *productInfoVC = segue.destinationViewController;
        productInfoVC.product = self.product;
    }
    if ([segue.identifier isEqualToString:@"MLEBShoppingCartControllerSegueIdentifier"]) {
        MLEBShoppingCartController *shoppingCartVC = segue.destinationViewController;
        shoppingCartVC.shouldHideTabBar = YES;
    }
}

#pragma mark- SubViews Configuration
- (void)configureTableView {
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 20, 0)];
    self.tableView.backgroundColor = UIColorFromRGB(0xeeeeee);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.tableFooterView.backgroundColor = UIColorFromRGB(0xeeeeee);
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80.0;
}

- (void)configureToolBar {
    [self.toolBarView addTopBorderWithColor:UIColorFromRGB(0xE2E1E6) width:0.5];
    self.likeImageView.image = ImageNamed(@"btn_favorite_normal");
    self.shoppingCartImageView.image = ImageNamed(@"btn_shoppingcart_normal");
    self.likeTitleLabel.text = NSLocalizedString(@"喜欢", nil);
    self.shoppingCartLabel.text = NSLocalizedString(@"购物车", nil);
    self.confirmOrderButton.backgroundColor = UIColorFromRGB(0xFF7700);
    [self.confirmOrderButton setTitle:NSLocalizedString(@"加入购物车", nil) forState:UIControlStateNormal];
    
    [kSharedWebService checkLikeStatusForProduct:self.product completion:^(BOOL isLiked, NSError *error) {
        if (error) {
            return;
        }
        if (isLiked) {
            self.likeImageView.image = ImageNamed(@"btn_favorite_selected");
        }
    }];
}

- (void)configurePickerView {
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.pickerView.showsSelectionIndicator = NO;
    [self.buttonPanel addTopBorderWithColor:UIColorFromRGB(0xE2E1E6) width:0.5];
    [self.buttonPanel addBottomBorderWithColor:UIColorFromRGB(0xE2E1E6) width:0.5];
    
    self.pickerViewBottomConstraints.constant = -256;
    [self.view layoutIfNeeded];
    [self.finishPickerButton setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
    self.finishPickerButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.finishPickerButton setTitleColor:UIColorFromRGB(0xFF7700) forState:UIControlStateNormal];
    self.finishPickerButton.layer.borderColor = UIColorFromRGB(0xFF7700).CGColor;
    self.finishPickerButton.layer.borderWidth = 1.0f;
    self.finishPickerButton.layer.cornerRadius = 4;
    self.finishPickerButton.layer.masksToBounds = YES;
}

#pragma mark- Actions
- (IBAction)confirmButtonPressed:(id)sender {
    self.confirmOrderButton.backgroundColor = UIColorFromRGB(0xFF7700);
    if (!kSharedUser) {
        [self performSegueWithIdentifier:@"showLoginViewControllerIdentifier" sender:nil];
        return;
    }
    
    [self saveShoppingItem];
    [self updateShoppingCartQuantityLabel];
}

- (IBAction)confirmButtonTouchDown:(id)sender {
    self.confirmOrderButton.backgroundColor = UIColorFromRGB(0xD16304);
}

- (IBAction)comfirmButtonTouchUpOutside:(id)sender {
    self.confirmOrderButton.backgroundColor = UIColorFromRGB(0xFF7700);
}

- (IBAction)finishPickerView:(id)sender {
    [self hiddenPickerView];
    if ([self customInfoCount] > 0) {
        [self.tableView reloadData];
    }
}

- (IBAction)addShoppingCartButtonTouchDown:(id)sender {
    self.shoppingCartImageView.image = ImageNamed (@"btn_shoppingcart_selected");
    self.shoppingCartLabel.textColor = UIColorFromRGB(0xFF7700);
}

- (IBAction)addShoppingCartButtonPressed:(id)sender {
    self.shoppingCartImageView.image = ImageNamed(@"btn_shoppingcart_normal");
    self.shoppingCartLabel.textColor = UIColorFromRGB(0x000000);
    
    if (!kSharedUser) {
        [self performSegueWithIdentifier:@"showLoginViewControllerIdentifier" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"MLEBShoppingCartControllerSegueIdentifier" sender:nil];
    }
}

- (IBAction)likeButtonPressed:(id)sender {
    if (!kSharedUser) {
        [self performSegueWithIdentifier:@"showLoginViewControllerIdentifier" sender:nil];
        return;
    }
    
    NSPredicate *p = [NSPredicate predicateWithFormat:@"title = %@", self.product.title];
    NSOrderedSet *filtedResults = [kSharedUser.favorites filteredOrderedSetUsingPredicate:p];
    MLEBProduct *favoriteProduct = [filtedResults firstObject];
    if (favoriteProduct) {
        self.likeImageView.image = ImageNamed(@"btn_favorite_normal");
        [kSharedWebService unmarkFavoriteProduct:self.product completion:^(BOOL succeeded, NSError *error) {
            if (!error || !succeeded) {
                [SVProgressHUD showSuccessWithStatus:@"取消收藏成功"];
                self.likeImageView.image = ImageNamed(@"btn_favorite_selected");
            }
            
            self.likeImageView.image = ImageNamed(@"btn_favorite_normal");
            MLEBProduct *productInContext = [MLEBProduct cloneProductToDefaultContext:self.product];
            [kSharedUser removeFavoritesObject:productInContext];
        }];
    } else {
        self.likeImageView.image = ImageNamed(@"btn_favorite_selected");
        [kSharedWebService markFavoriteProduct:self.product completion:^(BOOL succeeded, NSError *error) {
            if (error || !succeeded) {
                [SVProgressHUD showSuccessWithStatus:@"收藏失败"];
                self.likeImageView.image = ImageNamed(@"btn_favorite_normal");
                return;
            }
            
            [SVProgressHUD showSuccessWithStatus:@"收藏成功"];
            self.likeImageView.image = ImageNamed(@"btn_favorite_selected");
            MLEBProduct *productInContext = [MLEBProduct cloneProductToDefaultContext:self.product];
            [kSharedUser addFavoritesObject:productInContext];
        }];
    }
}

#pragma mark- Public Methods

#pragma mark- Delegate，DataSource, Callback Method
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.editingCustomInfoIndex == -1) {
        return 0;
    }
    
    if (self.editingCustomInfoIndex == 0) {
        NSArray *items = [self.product customInfo1Items];
        return items.count;
    }
    
    if (self.editingCustomInfoIndex == 1) {
        NSArray *items = [self.product customInfo2Items];
        return items.count;
    }
    
    if (self.editingCustomInfoIndex == 2) {
        NSArray *items = [self.product customInfo3Items];
        return items.count;
    }
    
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (self.editingCustomInfoIndex == -1) {
        return @"";
    }
    
    if (self.editingCustomInfoIndex == 0) {
        NSArray *items = [self.product customInfo1Items];
        return items[row];
    }
    
    if (self.editingCustomInfoIndex == 1) {
        NSArray *items = [self.product customInfo2Items];
        return items[row];
    }
    
    if (self.editingCustomInfoIndex == 2) {
        NSArray *items = [self.product customInfo3Items];
        return items[row];
    }
    
    
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        if (self.editingCustomInfoIndex == 0) {
            NSArray *items = [self.product customInfo1Items];
            self.selectedCustomInfo1 = items[row];
        }
        
        if (self.editingCustomInfoIndex == 1) {
            NSArray *items = [self.product customInfo2Items];
            self.selectedCustomInfo2 = items[row];
        }
        
        if (self.editingCustomInfoIndex == 2) {
            NSArray *items = [self.product customInfo2Items];
            self.selectedCustomInfo3 = items[row];
        }
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        tView.font = [UIFont systemFontOfSize:18];
        tView.textColor = UIColorFromRGB(0x404040);
        tView.textAlignment = NSTextAlignmentCenter;
        tView.frame = CGRectMake(0, 0, ScreenRect.size.width, 22);
    }
    
    NSString *title = @"";
    
    if (self.editingCustomInfoIndex == 0) {
        NSArray *items = [self.product customInfo1Items];
        title = items[row];
    }
    
    if (self.editingCustomInfoIndex == 1) {
        NSArray *items = [self.product customInfo2Items];
        title = items[row];
    }
    
    if (self.editingCustomInfoIndex == 2) {
        NSArray *items = [self.product customInfo3Items];
        title = items[row];
    }
    
    tView.text = title;
    
    return tView;
}

#pragma mark -UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kProductPreviewCell = @"MLEBProductImagePreviewTableViewCell";
    static NSString *kProductdIntrolductionCell = @"MLEBProductDetailTableViewCell";
    static NSString *kProductQuantityCell = @"MLEBProductQuantityTableViewCell";
    static NSString *kProductInfoCell = @"MLEBProductInfoTableViewCell";
    
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:kProductPreviewCell];
        [(MLEBProductImagePreviewTableViewCell *)cell configureCell:self.product];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:kProductdIntrolductionCell];
        [(MLEBProductDetailTableViewCell *)cell configureCell:self.product];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:kProductInfoCell];
            cell.textLabel.text = NSLocalizedString(@"商品评价", nil);
            [cell addBottomBorderWithColor:UIColorFromRGB(0xE2E1E6) width:0.5];
        }
        
        if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:kProductInfoCell];
            cell.textLabel.text = NSLocalizedString(@"规格参数", nil);
            cell.detailTextLabel.text = @" ";
            [cell addBottomBorderWithColor:UIColorFromRGB(0xE2E1E6) width:0.5];
        }
        
        if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:kProductQuantityCell];
            [(MLEBProductQuantityTableViewCell *)cell configureCell:self.shoppingItem];
            [(MLEBProductQuantityTableViewCell *)cell setPlusProductOrderHandler:^(MLEBProductQuantityTableViewCell *cell) {
                NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }];
            
            [(MLEBProductQuantityTableViewCell *)cell setMinusProductOrderHandler:^(MLEBProductQuantityTableViewCell *cell) {
                NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }];
        }
    }
    
    if (indexPath.section == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:kProductInfoCell];
        
        if (indexPath.row == 0) {
            NSString *key = [self.product customInfo1Name];
            cell.textLabel.text = key;
            cell.detailTextLabel.text = self.selectedCustomInfo1;
            if (indexPath.row < [self customInfoCount] - 1) {
                [cell addBottomBorderWithColor:UIColorFromRGB(0xE2E1E6) width:0.5];
            }
        }
        
        if (indexPath.row == 1) {
            NSString *key = [self.product customInfo2Name];
            cell.textLabel.text = key;
            cell.detailTextLabel.text = self.selectedCustomInfo2;
            if (indexPath.row < [self customInfoCount] - 1) {
                [cell addBottomBorderWithColor:UIColorFromRGB(0xE2E1E6) width:0.5];
            }
        }
        
        if (indexPath.row == 2) {
            NSString *key = [self.product customInfo3Name];
            cell.textLabel.text = key;
            cell.detailTextLabel.text = self.selectedCustomInfo3;
            if (indexPath.row < [self customInfoCount] - 1) {
                [cell addBottomBorderWithColor:UIColorFromRGB(0xE2E1E6) width:0.5];
            }
        }
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        return 1;
    }
    
    if (section == 2) {
        return 3;
    }
    
    if (section == 3) {
        return [self customInfoCount];
    }
    
    return 0;
}

- (NSUInteger)customInfoCount {
    int count = 0;
    BOOL isInfo1Exist = self.product.custom_info1.length > 0;
    BOOL isInfo2Exist = self.product.custom_info2.length > 0;
    BOOL isInfo3Exist = self.product.custom_info3.length > 0;
    if (isInfo1Exist) {
        count++;
    }
    
    if (isInfo2Exist) {
        count++;
    }
    
    if (isInfo3Exist) {
        count++;
    }
    
    return count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"showCommentVCIdentifer" sender:nil];
        }
        
        if (indexPath.row == 1) {
            [self performSegueWithIdentifier:@"showProductInfoViewControllerIdentifier" sender:nil];
        }
    }
    
    if (indexPath.section == 3) {
        self.editingCustomInfoIndex = indexPath.row;
        [self showPickerView];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0 || section == 3) {
        return 0.1;
    }
    
    return 10;
}

#pragma mark- Private Methods
- (MLEBShoppingItem *)createShoppingItem {
    NSArray *info1s =[self.product customInfo1Items];
    NSArray *info2s = [self.product customInfo2Items];
    NSArray *info3s = [self.product customInfo3Items];
    
    if ([info1s count] > 0 && self.selectedCustomInfo1.length == 0) {
        self.selectedCustomInfo1 = [info1s firstObject];
    }
    
    if ([info2s count] > 0 && self.selectedCustomInfo2.length == 0) {
        self.selectedCustomInfo2 = [info2s firstObject];
    }
    
    if ([info3s count] > 0 && self.selectedCustomInfo3.length == 0) {
        self.selectedCustomInfo3 = [info3s firstObject];
    }
    
    MLEBShoppingItem *shoppingItem = [MLEBShoppingItem MR_createEntityInContext:kSharedWebService.scratchContext];
    shoppingItem.createdAt = [NSDate date];
    shoppingItem.product = self.product;
    shoppingItem.selected_custom_info1 = self.selectedCustomInfo1;
    shoppingItem.selected_custom_info2 = self.selectedCustomInfo2;
    shoppingItem.selected_custom_info3 = self.selectedCustomInfo3;
    shoppingItem.quantity = @(1);
    
    return shoppingItem;
}

- (void)saveShoppingItem {
    dispatch_block_t trackAddShoppingCartEvent = ^{
        [MLAnalytics trackEvent:@"AddShoppingCart"
                     parameters:@{@"ProductId":SAFE_STRING(self.product.mlObjectId),
                                  @"ProductName":SAFE_STRING(self.product.title),
                                  @"Price":SAFE_STRING(self.product.price.stringValue),
                                  @"BuyCount":SAFE_STRING(self.shoppingItem.quantity.stringValue),
                                  @"UserName":SAFE_STRING(kSharedWebService.currentUser.username)
                                  }];
    };
    
    if (self.shoppingItem.quantity.integerValue > 0) {
        [self saveSelectedCustomInfo];
  
        NSPredicate *p = [NSPredicate predicateWithBlock:^BOOL(MLEBShoppingItem *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            DDLogInfo(@"evaluatedObj.product.title = %@, self.product.title = %@", evaluatedObject.product.title, self.product.title);
            BOOL isTitleEqual = [evaluatedObject.product.title isEqualToString:self.product.title];
            BOOL isSelectedCustomInfo1Equal = self.selectedCustomInfo1 == nil || [evaluatedObject.selected_custom_info1 isEqualToString:self.selectedCustomInfo1];
            BOOL isSelectedCustomInfo1Equa2 = self.selectedCustomInfo2 == nil || [evaluatedObject.selected_custom_info2 isEqualToString:self.selectedCustomInfo2];
            BOOL isSelectedCustomInfo1Equa3 = self.selectedCustomInfo3 == nil || [evaluatedObject.selected_custom_info3 isEqualToString:self.selectedCustomInfo3];
            return isTitleEqual && isSelectedCustomInfo1Equal && isSelectedCustomInfo1Equa2 && isSelectedCustomInfo1Equa3;
        }];
        

        NSFetchRequest *fetchRequest = [MLEBShoppingItem MR_requestAll];
//        fetchRequest.returnsObjectsAsFaults = NO;
        NSArray *allShoppingItems = [MLEBShoppingItem MR_executeFetchRequest:fetchRequest];
        
        NSArray *matchedResults = [allShoppingItems filteredArrayUsingPredicate:p];
        MLEBShoppingItem *existedShoppingItemInDefaultContext = [matchedResults firstObject];
        
        if (existedShoppingItemInDefaultContext) {
            existedShoppingItemInDefaultContext.quantity = @(existedShoppingItemInDefaultContext.quantity.integerValue + self.shoppingItem.quantity.integerValue);
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
           
//            self.confirmOrderButton.enabled = NO;
//            self.confirmOrderButton.alpha = 0.5;
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
            [kSharedWebService addOrUpdateShoppingItem:existedShoppingItemInDefaultContext completion:^(BOOL succeeded, NSError *error) {
                [SVProgressHUD dismiss];
//                self.confirmOrderButton.enabled = YES;
//                self.confirmOrderButton.alpha = 1;

                if (!succeeded || error) {
                    if (error.code == NSURLErrorTimedOut) {
                        [SVProgressHUD showErrorWithStatus:@"添加至购物车失败，请求超时"];
                    } else {
                        [SVProgressHUD showErrorWithStatus:@"添加至购物车失败"];
                    }
                } else {
                    [SVProgressHUD showSuccessWithStatus:@"添加至购物车成功"];
                    trackAddShoppingCartEvent();
                }
            }];
        } else {
            MLEBShoppingItem *shoppingItemInDefaultContext = [MLEBShoppingItem cloneShoppingItemToDefaultContext:self.shoppingItem];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            
//            self.confirmOrderButton.enabled = NO;
//            self.confirmOrderButton.alpha = 0.5;
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
            [kSharedWebService addOrUpdateShoppingItem:shoppingItemInDefaultContext completion:^(BOOL succeeded, NSError *error) {
                [SVProgressHUD dismiss];
//                self.confirmOrderButton.enabled = YES;
//                self.confirmOrderButton.alpha = 1;
                
                if (!succeeded || error) {
                    if (error.code == NSURLErrorTimedOut) {
                        [SVProgressHUD showErrorWithStatus:@"添加至购物车失败，请求超时"];
                    } else {
                        [SVProgressHUD showErrorWithStatus:@"添加至购物车失败"];
                    }
                } else {
                    [SVProgressHUD showSuccessWithStatus:@"添加至购物车成功"];
                    trackAddShoppingCartEvent();
                }
            }];
        }
    }
}

- (void)saveSelectedCustomInfo {
    self.shoppingItem.selected_custom_info1 = self.selectedCustomInfo1;
    self.shoppingItem.selected_custom_info2 = self.selectedCustomInfo2;
    self.shoppingItem.selected_custom_info3 = self.selectedCustomInfo3;
    
    self.shoppingItem.custom_infos = [NSString stringWithFormat:@"%@ %@ %@", self.selectedCustomInfo1 ?: @"", self.selectedCustomInfo2 ?: @"", self.selectedCustomInfo3 ?: @""];
}

- (void)updateShoppingCartQuantityLabel {
    NSPredicate *p = [NSPredicate predicateWithFormat:@"quantity > 0"];
    NSArray *shoppintItems = [MLEBShoppingItem MR_findAllWithPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
    NSNumber *sumOfProduct = [shoppintItems valueForKeyPath:@"@sum.quantity"];
    [self.toolBarView addSubview:self.shoppingButtonBGView];
    if (sumOfProduct.integerValue > 0) {
        self.quantityLabel.hidden = NO;
        if (sumOfProduct.integerValue > 10) {
            self.quantityLabel.text = @"10+";
        } else {
            self.quantityLabel.text = [sumOfProduct stringValue];
        }
        
        self.quantityLabel.layer.cornerRadius = 23 / 2.0;
        self.quantityLabel.layer.masksToBounds = YES;
        self.quantityLabel.backgroundColor = [UIColor redColor];
    } else {
        self.quantityLabel.hidden = YES;
    }
}

- (void)showPickerView {
    [self.pickerView reloadAllComponents];
    if (self.editingCustomInfoIndex == 0) {
        NSArray *customInfo1Items = [self.product customInfo1Items];
        NSUInteger index = [customInfo1Items indexOfObject:self.selectedCustomInfo1];
        [self.pickerView selectRow:index inComponent:0 animated:YES];
    }
    
    if (self.editingCustomInfoIndex == 1) {
        NSArray *customInfo2Items = [self.product customInfo2Items];
        NSUInteger index = [customInfo2Items indexOfObject:self.selectedCustomInfo2];
        [self.pickerView selectRow:index inComponent:0 animated:YES];
    }
    
    if (self.editingCustomInfoIndex == 2) {
        NSArray *customInfo3Items = [self.product customInfo3Items];
        NSUInteger index = [customInfo3Items indexOfObject:self.selectedCustomInfo3];
        [self.pickerView selectRow:index inComponent:0 animated:YES];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.pickerViewBottomConstraints.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

- (void)hiddenPickerView {
    [UIView animateWithDuration:0.25 animations:^{
        self.pickerViewBottomConstraints.constant = -256;
        self.editingCustomInfoIndex = -1;
        [self.view layoutIfNeeded];
    }];
    
    [self.tableView reloadData];
}

#pragma mark- Getter Setter

#pragma mark- Helper Method

#pragma mark Temporary Area


@end