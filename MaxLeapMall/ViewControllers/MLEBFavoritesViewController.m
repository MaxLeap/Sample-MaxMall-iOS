//
//  MLEBFavoritesViewController.m
//  MaxLeapMall
//
//  Created by julie on 15/11/17.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBFavoritesViewController.h"

@interface MLEBFavoritesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *emptyNotesLabel;

@property (nonatomic, strong) NSMutableArray *favoritesInScratchCtx;
@property (nonatomic, strong) MLEBProduct *selectedProduct;

@end

@implementation MLEBFavoritesViewController
#pragma mark - init Method

#pragma mark- View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"我的收藏", @"");
    
    [self configureSubViews];
    
    [self loadData];
    [self reloadViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView triggerPullToRefresh];
}

- (void)fetchDataAndUpdateViews {
    [self loadData];
    [self reloadViews];
    
    [kSharedWebService fetchFavoritesWithCompletion:^(NSOrderedSet *favorites, NSError *error) {
        execute_after_main_queue(0.2, ^{
            [self.tableView.pullToRefreshView stopAnimating];
        });
        
        [self loadData];
        [self reloadViews];
    }];
}

- (void)loadData {
    [self.favoritesInScratchCtx removeAllObjects];
    
    MLEBUser *user = [MLEBUser MR_findFirstInContext:kSharedWebService.defaultContext];
    [user.favorites enumerateObjectsUsingBlock:^(MLEBProduct * _Nonnull merchantInDefaultCtx, NSUInteger idx, BOOL * _Nonnull stop) {
        MLEBProduct *productMOInScratchCtx = [kSharedWebService productMOInTargetContext:kSharedWebService.scratchContext fromProduct:merchantInDefaultCtx];
        [self.favoritesInScratchCtx addObject:productMOInScratchCtx];
    }];
}

- (void)reloadViews {
    [self.tableView reloadData];
    
    if (self.favoritesInScratchCtx.count > 0) {
        self.emptyNotesLabel.hidden = YES;
        
    } else {
        self.emptyNotesLabel.hidden = NO;
    }
}

#pragma mark- SubView Configuration
- (void)configureSubViews {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80.0;
    
    __weak typeof(self) wSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        wSelf.emptyNotesLabel.hidden = YES;
        [wSelf fetchDataAndUpdateViews];
    }];
    
    self.emptyNotesLabel.font = [UIFont systemFontOfSize:30];
    self.emptyNotesLabel.textColor = [UIColor lightGrayColor];
    self.emptyNotesLabel.text = NSLocalizedString(@"暂无收藏", nil);
    self.emptyNotesLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyNotesLabel.hidden = YES;
}

#pragma mark- Action

#pragma mark- Delegate，DataSource, Callback Method
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == self.favoritesInScratchCtx.count - 1) {
        return 10;
    }
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.favoritesInScratchCtx.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MLEBProductTableViewCell" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    MLEBProduct *oneProduct = self.favoritesInScratchCtx[indexPath.row];
    [(MLEBProductTableViewCell *)cell configureCell:oneProduct];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedProduct = self.favoritesInScratchCtx[indexPath.row];
    [self performSegueWithIdentifier:@"MLEBProductViewControllerSegueIdentifier" sender:nil];
}

#pragma mark- Override Parent Method

#pragma mark- Private Method

#pragma mark- Getter Setter
- (NSMutableArray *)favoritesInScratchCtx {
    if (!_favoritesInScratchCtx) {
        _favoritesInScratchCtx = [NSMutableArray array];
    }
    return _favoritesInScratchCtx;
}

#pragma mark- Helper Method

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MLEBProductViewController *merchantVC = [segue destinationViewController];
    merchantVC.product = self.selectedProduct;
}
@end
