//
//  MLFFSerchView.m
//  MaxLeapFood
//
//  Created by Michael on 11/11/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import "MLEBSearchViewController.h"
@interface MLEBSearchViewController () <
UITextFieldDelegate,
UITableViewDataSource,
UITableViewDelegate
>
@property (weak, nonatomic) IBOutlet UIView *searchContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *searchIconImageView;
@property (weak, nonatomic) IBOutlet UIView *searchBarContainerView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *searchHistory;

@property (weak, nonatomic) IBOutlet UIView *controlPanel1;
@property (weak, nonatomic) IBOutlet UIButton *orderByPriceButton;
@property (weak, nonatomic) IBOutlet UIButton *orderBySaleButton;

@property (weak, nonatomic) IBOutlet UIView *controlPanel2;
@property (weak, nonatomic) IBOutlet UILabel *searchTipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *clearAllHistoryButton;
@property (nonatomic, assign) BOOL isShowResultPhase;
@property (nonatomic, strong) NSMutableArray *productSearchResult;
@property (weak, nonatomic) IBOutlet UILabel *emptySetTipsLabel;
@property (nonatomic, copy) NSString *keyword;

@property (nonatomic, copy) NSString *primaryKey;
@property (nonatomic, copy) NSString *seconaryKey;
@property (nonatomic, assign) NSComparisonResult primaryKeyOrder;
@property (nonatomic, assign) NSComparisonResult seconaryKeyOrder;
@property (nonatomic, assign) NSComparisonResult priceOrder;
@property (nonatomic, assign) NSComparisonResult saleOrder;
@end

@implementation MLEBSearchViewController

#pragma mark - init Method
- (void)viewDidLoad {
    [super viewDidLoad];
    self.productSearchResult = [NSMutableArray new];
    self.controlPanel1.hidden = NO;
    self.controlPanel2.hidden = NO;
    [self configureSubViews];
    [self configureTableView];
    [self configureControlPanel1];
    [self configureControlPanel2];
    
    self.emptySetTipsLabel.text = NSLocalizedString(@"没有匹配结果", nil);
    self.emptySetTipsLabel.hidden = YES;
    
    self.primaryKey = @"price";
    self.seconaryKey = @"quantity";
    self.primaryKeyOrder = NSOrderedAscending;
    self.seconaryKeyOrder = NSOrderedAscending;
    
    [self.searchTextField becomeFirstResponder];
    NSFetchRequest *fetchRequest = [MLEBSearchHistory MR_requestAllSortedBy:@"searchTime" ascending:NO];
    fetchRequest.fetchLimit = 10;
    self.searchHistory = [MLEBSearchHistory MR_executeFetchRequest:fetchRequest];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.tabBarController.tabBar.hidden = YES;
    [super viewWillAppear:animated];
}

#pragma mark- Override Parent Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSDictionary *)sender {
    if ([segue.identifier isEqualToString:@"showProductViewControllerIdentifier"]) {
        if ([sender.allKeys containsObject:@"selectedProduct"]) {
            MLEBProduct *product = sender[@"selectedProduct"];
            MLEBProductViewController *productVC = (MLEBProductViewController *)segue.destinationViewController;
            productVC.product = product;
        }
    }
}
#pragma mark- SubViews Configuration
- (void)configureTableView {
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 106.0;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [UIView new];
    
    __weak typeof(self) weakSelf = self;
    __block int page = 0;
    [weakSelf.tableView addPullToRefreshWithActionHandler:^{
        if (!self.isShowResultPhase) {
            execute_after_main_queue(0.2, ^{
                [self.tableView.pullToRefreshView stopAnimating];
            });
            return;
        }
        
        self.tableView.showsInfiniteScrolling = NO;
        page = 0;
        if (self.keyword.length) {
            [kSharedWebService fetchProductWithProductName:self.keyword
                                                  fromPage:page
                                                primaryKey:self.primaryKey
                                           primaryKeyOrder:self.primaryKeyOrder
                                              secondaryKey:self.seconaryKey
                                         secondaryKeyOrder:self.seconaryKeyOrder
                                                completion:^(NSArray *products, BOOL isReacheEnd, NSError *error) {
                                                    execute_after_main_queue(0.2, ^{
                                                        [weakSelf.tableView.pullToRefreshView stopAnimating];
                                                        self.emptySetTipsLabel.hidden = (products.count != 0);
                                                    });
                                                    
                                                    weakSelf.tableView.showsInfiniteScrolling = !isReacheEnd;
                                                    
                                                    if (error) {
                                                        if (error.code == 100) {
                                                            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络连接超时", nil)];
                                                        } else {
                                                            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"出错了", nil)];
                                                        }
                                                    } else {
                                                        [weakSelf.productSearchResult removeAllObjects];
                                                        [weakSelf.productSearchResult addObjectsFromArray:products];
                                                        [weakSelf.tableView reloadData];
                                                    }
                                                }];
        }
    }];
    
    [weakSelf.tableView addInfiniteScrollingWithActionHandler:^{
        [self.tableView.infiniteScrollingView stopAnimating];
        if (!self.isShowResultPhase) {
            return;
        }
        
        if (self.keyword.length) {
            [kSharedWebService fetchProductWithProductName:self.keyword
                                                  fromPage:page + 1
                                                primaryKey:self.primaryKey
                                           primaryKeyOrder:self.primaryKeyOrder
                                              secondaryKey:self.seconaryKey
                                         secondaryKeyOrder:self.seconaryKeyOrder
                                                completion:^(NSArray *products, BOOL isReacheEnd, NSError *error) {
                                                    [weakSelf.tableView.infiniteScrollingView stopAnimating];
                                                    weakSelf.tableView.showsInfiniteScrolling = !isReacheEnd;
                                                    if (!error) {
                                                        page++;
                                                        [weakSelf.productSearchResult addObjectsFromArray:products];
                                                        [weakSelf.tableView reloadData];
                                                    } else {
                                                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"出错了", nil)];
                                                    }
                                                }];
        }
    }];
}

- (void)configureControlPanel1 {
    [self.orderByPriceButton setTitle:NSLocalizedString(@"价格", nil) forState:UIControlStateNormal];
    [self.orderByPriceButton setImage:ImageNamed(@"btn_high_to_low_normal") forState:UIControlStateNormal];
    [self.orderByPriceButton setImage:ImageNamed(@"btn_high_to_low_selected") forState:UIControlStateHighlighted];
    self.orderByPriceButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, 0, self.orderByPriceButton.width / 2 - 180);
    
    [self.orderBySaleButton setTitle:NSLocalizedString(@"销量", nil) forState:UIControlStateNormal];
    [self.orderBySaleButton setImage:ImageNamed(@"btn_high_to_low_normal") forState:UIControlStateNormal];
    [self.orderBySaleButton setImage:ImageNamed(@"btn_high_to_low_normal") forState:UIControlStateHighlighted];
    self.orderBySaleButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, 0, self.orderBySaleButton.width / 2 - 180);
    
    [self.orderByPriceButton setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
    [self.orderBySaleButton setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
    
    [self.orderByPriceButton setTitleColor:UIColorFromRGB(0xFF7700) forState:UIControlStateHighlighted];
    [self.orderBySaleButton setTitleColor:UIColorFromRGB(0xFF7700) forState:UIControlStateHighlighted];
    
    [self.orderByPriceButton addBottomBorderWithColor:UIColorFromRGB(0xE2E1E6) width:0.5];
    [self.orderByPriceButton addRightBorderWithColor:UIColorFromRGB(0xE2E1E6) width:0.5];
    [self.orderBySaleButton addBottomBorderWithColor:UIColorFromRGB(0xE2E1E6) width:0.5];
}

- (void)configureControlPanel2 {
    self.searchTipsLabel.text = NSLocalizedString(@"历史搜索词", nil);
    [self.controlPanel2 addBottomBorderWithColor:UIColorFromRGB(0xDCDCDC) width:0.5];
    [self.clearAllHistoryButton setTitle:NSLocalizedString(@"清除", nil) forState:UIControlStateNormal];
    [self.clearAllHistoryButton setTitleColor:UIColorFromRGB(0xFF4400) forState:UIControlStateNormal];
}

- (IBAction)priceOrderPressed:(id)sender {
    self.primaryKey = @"price";
    self.seconaryKey = @"quantity";
    self.seconaryKeyOrder = self.saleOrder;
    
    if (self.priceOrder == NSOrderedDescending) {
        self.priceOrder = NSOrderedAscending;;
        self.primaryKeyOrder = NSOrderedAscending;
        [self.orderByPriceButton setImage:ImageNamed(@"btn_low_to_high_normal") forState:UIControlStateNormal];
        [self.orderByPriceButton setImage:ImageNamed(@"btn_low_to_high_selected") forState:UIControlStateHighlighted];
    } else {
        self.priceOrder = NSOrderedDescending;;
        self.primaryKeyOrder = NSOrderedDescending;
        [self.orderByPriceButton setImage:ImageNamed(@"btn_high_to_low_normal") forState:UIControlStateNormal];
        [self.orderByPriceButton setImage:ImageNamed(@"btn_high_to_low_selected") forState:UIControlStateHighlighted];
    }
    [self.tableView triggerPullToRefresh];
}

- (IBAction)saleOrderPressed:(id)sender {
    self.primaryKey = @"quantity";
    self.seconaryKey = @"price";
    self.seconaryKeyOrder = self.priceOrder;
    
    if (self.saleOrder == NSOrderedDescending) {
        self.saleOrder = NSOrderedAscending;
        self.primaryKeyOrder = NSOrderedAscending;
        [self.orderBySaleButton setImage:ImageNamed(@"btn_low_to_high_normal") forState:UIControlStateNormal];
        [self.orderBySaleButton setImage:ImageNamed(@"btn_low_to_high_selected") forState:UIControlStateHighlighted];
    } else {
        self.saleOrder = NSOrderedDescending;
        self.primaryKeyOrder = NSOrderedDescending;
        [self.orderBySaleButton setImage:ImageNamed(@"btn_high_to_low_normal") forState:UIControlStateNormal];
        [self.orderBySaleButton setImage:ImageNamed(@"btn_high_to_low_selected") forState:UIControlStateHighlighted];
    }
    [self.tableView triggerPullToRefresh];
}

#pragma mark- Actions
- (void)reloadData {
    [self.tableView reloadData];
}

- (IBAction)clearButtonPressed:(id)sender {
    [MLEBSearchHistory MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    self.searchHistory = nil;
    [self.tableView reloadData];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark- Public Methods
- (void)configureSubViews {
    self.searchContainerView.backgroundColor = UIColorFromRGB(0xFF4400);
    self.searchBarContainerView.layer.cornerRadius = 5;
    self.searchBarContainerView.layer.masksToBounds = YES;
    self.searchTextField.placeholder = NSLocalizedString(@"搜索商品名称", nil);
    self.searchTextField.keyboardType = UIKeyboardTypeWebSearch;
    self.searchIconImageView.image = ImageNamed(@"Search");
    [self.cancelButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    self.searchTextField.delegate = self;
}

#pragma mark- Delegate，DataSource, Callback Method

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length) {
        [self startSearchWithKeyboard:textField.text];
        return YES;
    } else {
        return NO;
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
    self.emptySetTipsLabel.hidden = YES;
    [self.tableView.pullToRefreshView stopAnimating];
    
    [self.productSearchResult removeAllObjects];
    [self.tableView reloadData];
    self.controlPanel1.hidden = YES;
    self.controlPanel2.hidden = NO;
    
    self.isShowResultPhase = NO;
    NSFetchRequest *fetchRequest = [MLEBSearchHistory MR_requestAllSortedBy:@"searchTime" ascending:NO];
    fetchRequest.fetchLimit = 10;
    self.searchHistory = [MLEBSearchHistory MR_executeFetchRequest:fetchRequest];
    [self.tableView reloadData];
    
    return YES;
}

#pragma mark -UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kSearchTableViewCell = @"kSearchTableViewCell";
    static NSString *kProductTableViewCell = @"kProductTableViewCell";
    
    UITableViewCell *cell;
    if (self.isShowResultPhase) {
        cell = [tableView dequeueReusableCellWithIdentifier:kProductTableViewCell];
        MLEBProduct *product = [self.productSearchResult objectAtIndex:indexPath.row];
        [(MLEBProductTableViewCell *)cell configureCell:product];
        [cell addBottomBorderWithColor:UIColorFromRGB(0xE2E1E6) width:0.5];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kSearchTableViewCell];
        MLEBSearchHistory *oneSearchHistory = self.searchHistory[indexPath.row];
        cell.textLabel.text = oneSearchHistory.keyword;
        cell.textLabel.textColor = UIColorFromRGB(0x333333);
        [cell addBottomBorderWithColor:UIColorFromRGB(0xd3d5dc) width:0.5];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isShowResultPhase) {
        return self.productSearchResult.count;
    } else {
        return self.searchHistory.count;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.isShowResultPhase) {
        MLEBProduct *product = self.productSearchResult[indexPath.row];
        [self performSegueWithIdentifier:@"showProductViewControllerIdentifier" sender:@{@"selectedProduct" : product}];
    } else {
        [self.searchTextField resignFirstResponder];
        MLEBSearchHistory *oneSearchHistory = self.searchHistory[indexPath.row];
        oneSearchHistory.searchTime = [NSDate date];
        self.searchHistory = nil;
        [self.tableView reloadData];
        self.isShowResultPhase = YES;
        self.controlPanel1.hidden = NO;
        self.controlPanel2.hidden = YES;
        self.keyword = oneSearchHistory.keyword;
        self.searchTextField.text = self.keyword;
        [self.tableView triggerPullToRefresh];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchTextField resignFirstResponder];
}

#pragma mark- Private Methods
- (void)startSearchWithKeyboard:(NSString *)keyword {
    [self.searchTextField resignFirstResponder];
    
    MLEBSearchHistory *searchHistory = [MLEBSearchHistory MR_findFirstOrCreateByAttribute:@"keyword" withValue:keyword];
    searchHistory.searchTime = [NSDate date];
    searchHistory.keyword = keyword;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    self.searchHistory = nil;
    [self.tableView reloadData];
    self.isShowResultPhase = YES;
    self.controlPanel1.hidden = NO;
    self.controlPanel2.hidden = YES;
    self.keyword = self.searchTextField.text;
    
    [self.tableView triggerPullToRefresh];
}

#pragma mark- Getter Setter

#pragma mark- Helper Method

#pragma mark Temporary Area

@end
