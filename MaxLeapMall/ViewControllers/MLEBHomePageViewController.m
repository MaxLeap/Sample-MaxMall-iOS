//
//  MLEBHomePageViewController.m
//  MaxLeapMall
//
//  Created by julie on 15/11/16.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBHomePageViewController.h"

@interface MLEBHomePageViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *searchTitleView;
@property (nonatomic, strong) IBOutlet UIImageView *serachIconImageView;
@property (nonatomic, strong) IBOutlet UILabel *searchPromptLabel;
@property (weak, nonatomic) IBOutlet UIView *searchBarContainerView;
@property (nonatomic, strong) NSArray *banners;
@property (nonatomic, strong) NSArray *shortCategory;
@property (nonatomic, strong) NSMutableArray *products;
@end

@implementation MLEBHomePageViewController

#pragma mark - init Method

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.parentController.title = NSLocalizedString(@"主页", nil);
    [self configureTitleView];
    [self configureTableView];
    
    [self.tableView triggerPullToRefresh];
}


- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.tabBarController.tabBar.hidden = NO;
    [super viewWillAppear:animated];
}

#pragma mark- Override Parent Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSDictionary *)sender {
    if ([segue.identifier isEqualToString:@"showProductViewControllerIdentifier"]) {
        MLEBProductViewController *productVC = (MLEBProductViewController *)segue.destinationViewController;
        if ([sender.allKeys containsObject:@"bannerIndex"]) {
            NSUInteger index = [sender[@"bannerIndex"] integerValue];
            MLEBBanner *oneBanner = self.banners[index];
            productVC.product = oneBanner.product;
        }
        
        if ([sender.allKeys containsObject:@"selectedProduct"]) {
            MLEBProduct *product = sender[@"selectedProduct"];
            productVC.product = product;
        }
    }
    
    if ([segue.identifier isEqualToString:@"showProductListViewControllerIdentifier"]) {
        MLEBProductListViewController *productListVC = (MLEBProductListViewController *)segue.destinationViewController;
        if ([sender.allKeys containsObject:@"productCategory"]) {
            MLEBProductCategory *productCategory = sender[@"productCategory"];
            productListVC.serachProductCategory = productCategory;
        }
    }
}

#pragma mark- SubViews Configuration
- (void)configureTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80.0;
    
    __weak typeof(self) weakSelf = self;
    __block int page = 0;
    [weakSelf.tableView addPullToRefreshWithActionHandler:^{
        weakSelf.tableView.showsInfiniteScrolling = NO;
        page = 0;
        [kSharedWebService fetchProductsFromPage:page completion:^(NSArray *products, BOOL isReachEnd, NSError *error) {
            execute_after_main_queue(0.2, ^{
                [weakSelf.tableView.pullToRefreshView stopAnimating];
            });
            weakSelf.tableView.showsInfiniteScrolling = !isReachEnd;
            
            if (error) {
                if (error.code == 100) {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络连接超时", nil)];
                } else {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"出错了", nil)];
                }
            } else {
                [weakSelf.products removeAllObjects];
                [weakSelf.products addObjectsFromArray:products];
                [weakSelf.tableView reloadData];
            }
        }];
        
        [kSharedWebService fetchProductCategoryCompletion:^(NSArray *merchaintKinds, NSError *error) {
            if (error) {
                if (error.code == 100) {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络连接超时", nil)];
                } else {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"出错了", nil)];
                }
            } else {
                weakSelf.shortCategory = merchaintKinds;
                [weakSelf.tableView reloadData];
            }
        }];
        
        [kSharedWebService fetchBannersCompletion:^(NSArray *banners, NSError *error) {
            if (error) {
                if (error.code == 100) {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络连接超时", nil)];
                } else {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"出错了", nil)];
                }
            } else {
                weakSelf.banners = banners;
                [weakSelf.tableView reloadData];
            }
        }];
    }];
    
    [weakSelf.tableView addInfiniteScrollingWithActionHandler:^{
        [kSharedWebService fetchProductsFromPage:page + 1
                                      completion:^(NSArray *products, BOOL isReachEnd, NSError *error) {
                                          [weakSelf.tableView.infiniteScrollingView stopAnimating];
                                          weakSelf.tableView.showsInfiniteScrolling = !isReachEnd;
                                          if (!error) {
                                              page++;
                                              [weakSelf.products addObjectsFromArray:products];
                                              [weakSelf.tableView reloadData];
                                          } else {
                                              [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Error", nil)];
                                          }
                                      }];
    }];
}

#pragma mark- Actions
- (IBAction)searchButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"presetnSearchViewIdentifier" sender:nil];
}

#pragma mark- Public Methods

#pragma mark- Delegate，DataSource, Callback Method
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kBannerCellIdentifier = @"MLEBBannerTableViewCell";
    static NSString *kMerchantKindCellIdentifier = @"MLEBProductCategoryTableViewCell";
    static NSString *kMerchantCellIdentifier = @"MLEBProductTableViewCell";
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:kBannerCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [(MLEBBannerTableViewCell*)cell setBannerTapHandler:^(MLEBBannerTableViewCell *cell, NSUInteger index) {
            [self performSegueWithIdentifier:@"showProductViewControllerIdentifier" sender:@{@"bannerIndex" : @(index)}];
        }];
        [(MLEBBannerTableViewCell*)cell configureCell:self.banners];
    }
    
    if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:kMerchantKindCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [(MLEBProductCategoryTableViewCell *)cell configureCell:self.shortCategory];
        [(MLEBProductCategoryTableViewCell *)cell setProductTypeTapHandler:^(MLEBProductCategoryTableViewCell *cell, MLEBProductCategory *productCategory) {
            [self performSegueWithIdentifier:@"showProductListViewControllerIdentifier" sender:@{@"productCategory" : productCategory}];
        }];
    }
    
    if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:kMerchantCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        MLEBProduct *oneProduct = self.products[indexPath.row];
        [(MLEBProductTableViewCell *)cell configureCell:oneProduct];
        [cell.contentView addBottomBorderWithColor:UIColorFromRGB(0xDCDCDC) width:0.5];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        return 1;
    }
    
    return [self.products count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        return 10;
    }
    
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2) {
        MLEBProduct *product = self.products[indexPath.row];
        [self performSegueWithIdentifier:@"showProductViewControllerIdentifier" sender:@{@"selectedProduct" : product}];
    }
}

#pragma mark- Private Methods
- (void)configureTitleView {
    self.serachIconImageView.image = ImageNamed(@"Search");
    self.searchPromptLabel.text = NSLocalizedString(@"搜索商品名称", nil);
    self.searchBarContainerView.layer.cornerRadius = 5;
    self.searchBarContainerView.layer.masksToBounds = YES;
    self.searchTitleView.frame = CGRectMake(0, 0, ScreenRect.size.width, 44);
    self.parentController.navigationItem.titleView = self.searchTitleView;
}

#pragma mark- Getter Setter
- (NSMutableArray *)products {
    if (!_products) {
        _products = [NSMutableArray new];
    }
    return _products;
}


#pragma mark- Helper Method

#pragma mark Temporary Area
@end
