//
//  MLEBProductListViewController.m
//  MaxLeapMall
//
//  Created by Michael on 11/17/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import "MLEBProductListViewController.h"

@interface MLEBProductListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *products;
@property (weak, nonatomic) IBOutlet UILabel *emptySetTipsLabel;
@end

@implementation MLEBProductListViewController

#pragma mark - init Method

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.serachProductCategory) {
        self.title = self.serachProductCategory.title;
    }
    
    self.emptySetTipsLabel.text = NSLocalizedString(@"没有匹配结果", nil);
    self.emptySetTipsLabel.hidden = YES;
    [self configureTableView];
    [self.tableView triggerPullToRefresh];
}

#pragma mark- Override Parent Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showProductViewControllerIdentifier"]) {
        MLEBProductViewController *productVC = (MLEBProductViewController *)segue.destinationViewController;
        MLEBProduct *product = sender[@"selectedProduct"];
        productVC.product = product;
        productVC.hidesBottomBarWhenPushed = YES;
    }
}

#pragma mark- SubViews Configuration
- (void)configureTableView {
    self.view.backgroundColor = UIColorFromRGB(0xeeeeee);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80.0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.products = [NSMutableArray new];
    
    __weak typeof(self) weakSelf = self;
    __block int page = 0;
    [weakSelf.tableView addPullToRefreshWithActionHandler:^{
        self.emptySetTipsLabel.hidden = YES;
        self.tableView.showsInfiniteScrolling = NO;
        page = 0;
        if (self.serachProductCategory) {
            [kSharedWebService fetchProductWithProductCategory:self.serachProductCategory fromPage:page completion:^(NSArray *merchaints, BOOL isReachEnd, NSError *error) {
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
                    [weakSelf.products addObjectsFromArray:merchaints];
                    [weakSelf.tableView reloadData];
                }
            }];
        }
    }];
    
    [weakSelf.tableView addInfiniteScrollingWithActionHandler:^{
        if (self.serachProductCategory) {
            [kSharedWebService fetchProductWithProductCategory:self.serachProductCategory fromPage:page + 1 completion:^(NSArray *products, BOOL isReachEnd, NSError *error) {
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
        }
    }];
}

#pragma mark- Actions

#pragma mark- Public Methods

#pragma mark- Delegate，DataSource, Callback Method
#pragma mark -UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MLEBProductTableViewCell";
    MLEBProductTableViewCell *cell = (MLEBProductTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell configureCell:self.products[indexPath.row]];
    [cell.contentView addBottomBorderWithColor:UIColorFromRGB(0xDCDCDC) width:0.5];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.products.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MLEBProduct *product = self.products[indexPath.row];
    [self performSegueWithIdentifier:@"showProductViewControllerIdentifier" sender:@{@"selectedProduct" : product}];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

#pragma mark- Private Methods

#pragma mark- Getter Setter

#pragma mark- Helper Method

#pragma mark Temporary Area


@end
