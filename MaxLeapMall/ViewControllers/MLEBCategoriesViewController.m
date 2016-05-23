//
//  MLEBCategoriesViewController.m
//  MaxLeapMall
//
//  Created by julie on 15/11/16.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBCategoriesViewController.h"

@interface MLEBCategoriesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *categories;
@end

@implementation MLEBCategoriesViewController

#pragma mark - init Method

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.parentController.title = NSLocalizedString(@"分类", nil);
    self.categories = [NSMutableArray new];
    [self configureTableView];
    [self.tableView triggerPullToRefresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark- Override Parent Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSDictionary *)sender {
    
    if ([segue.identifier isEqualToString:@"showProductListIdentifier"]) {
        if ([sender.allKeys containsObject:@"selectedCategory"]) {
            MLEBProductCategory *productCategory = sender[@"selectedCategory"];
            MLEBProductListViewController *productListVC = (MLEBProductListViewController *)segue.destinationViewController;
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

        
        [kSharedWebService fetchProductCategoryCompletion:^(NSArray *productCategories, NSError *error) {
            execute_after_main_queue(0.2, ^{
                [weakSelf.tableView.pullToRefreshView stopAnimating];
            });
            
            if (error) {
                if (error.code == NSURLErrorTimedOut) {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络连接超时", nil)];
                } else {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"出错了", nil)];
                }
            } else {
                weakSelf.categories = productCategories;
                [weakSelf.tableView reloadData];
            }
        }];
    }];
}

#pragma mark- Actions

#pragma mark- Public Methods

#pragma mark- Delegate，DataSource, Callback Method
#pragma mark -UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    MLEBProductCategory *oneCategory = self.categories[indexPath.row];
    cell.textLabel.text = oneCategory.title;
    [cell addBottomBorderWithColor:UIColorFromRGB(0xE2E1E6) width:0.5];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.categories.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MLEBProductCategory *oneCategory = self.categories[indexPath.row];
    [self performSegueWithIdentifier:@"showProductListIdentifier" sender:@{@"selectedCategory" : oneCategory}];
}

#pragma mark- Private Methods

#pragma mark- Getter Setter

#pragma mark- Helper Method

#pragma mark Temporary Area

@end
