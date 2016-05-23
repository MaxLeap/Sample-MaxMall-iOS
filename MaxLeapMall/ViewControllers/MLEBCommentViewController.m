//
//  MLEBCommentViewController.m
//  MaxLeapMall
//
//  Created by Michael on 11/19/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import "MLEBCommentViewController.h"

@interface MLEBCommentViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *praises;
@property (nonatomic, strong) NSMutableArray *assessments;
@property (nonatomic, strong) NSMutableArray *badReviews;

@property (weak, nonatomic) IBOutlet UIButton *praisesButton;
@property (weak, nonatomic) IBOutlet UIButton *assessmentsButton;
@property (weak, nonatomic) IBOutlet UIButton *badReviewsButton;
@property (weak, nonatomic) IBOutlet UIView *scrollIndicatorView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) NSMutableArray *currentComments;
@property (nonatomic, weak) UIButton *currentButton;
@property (nonatomic, assign) MLEBCommentType currentCommentType;
@property (weak, nonatomic) IBOutlet UILabel *emptySetTipsLabel;
@property (nonatomic, assign) BOOL isLoadParaise;
@property (nonatomic, assign) BOOL isLoadAssesment;
@property (nonatomic, assign) BOOL isLoadBadReviews;
@end

@implementation MLEBCommentViewController
#pragma mark - init Method

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"商品评论", nil);
    self.view.backgroundColor = UIColorFromRGB(0xeeeeee);

    self.emptySetTipsLabel.text = NSLocalizedString(@"暂无评论", nil);
    self.emptySetTipsLabel.hidden = YES;
    
    [self configureTableView];
    [self configureCategoryView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView triggerPullToRefresh];
}

#pragma mark- Override Parent Methods

#pragma mark- SubViews Configuration
- (void)configureTableView {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80.0;
    
    __weak typeof(self) weakSelf = self;
    __block int page = 0;
    [weakSelf.tableView addPullToRefreshWithActionHandler:^{
        self.tableView.showsInfiniteScrolling = NO;
        page = 0;
        [kSharedWebService fetchProductCommentWithType:self.currentCommentType product:self.product fromPage:page completion:^(NSArray *comments, BOOL isReachEnd, NSError *error) {
            execute_after_main_queue(0.2, ^{
                [weakSelf.tableView.pullToRefreshView stopAnimating];
                self.emptySetTipsLabel.hidden = (comments.count != 0);
            });
            weakSelf.tableView.showsInfiniteScrolling = !isReachEnd;
            
            if (error) {
                if (error.code == 100) {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络连接超时", nil)];
                } else {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"出错了", nil)];
                }
            } else {
                [weakSelf.currentComments removeAllObjects];
                [weakSelf.currentComments addObjectsFromArray:comments];
                [weakSelf.tableView reloadData];
            }
        }];
    }];
    
    [weakSelf.tableView addInfiniteScrollingWithActionHandler:^{
        [kSharedWebService fetchProductCommentWithType:self.currentCommentType product:self.product fromPage:page + 1 completion:^(NSArray *comments, BOOL isReachEnd, NSError *error) {
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
            weakSelf.tableView.showsInfiniteScrolling = !isReachEnd;
            if (!error) {
                page++;
                [weakSelf.currentComments addObjectsFromArray:comments];
                [weakSelf.tableView reloadData];
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"出错了", nil)];
            }
        }];
    }];
}

- (void)configureCategoryView {
    [self.praisesButton setTitle:NSLocalizedString(@"满意", nil) forState:UIControlStateNormal];
    [self.assessmentsButton setTitle:NSLocalizedString(@"一般", nil) forState:UIControlStateNormal];
    [self.badReviewsButton setTitle:NSLocalizedString(@"不满意", nil) forState:UIControlStateNormal];
    self.currentButton = self.praisesButton;
    self.scrollIndicatorView.backgroundColor = UIColorFromRGB(0xFF7700);
}

#pragma mark- Actions

- (IBAction)praisesButtonPressed:(UIButton *)sender {
    self.emptySetTipsLabel.hidden = YES;
    
    self.isLoadParaise = YES;
    self.currentCommentType = MLEBCommentTypePraises;
    self.currentButton = sender;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.scrollViewLeadingConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
    
    [self.tableView triggerPullToRefresh];
}

- (IBAction)assessmentsButtonPressed:(UIButton *)sender {
    self.emptySetTipsLabel.hidden = YES;
    
    self.isLoadAssesment = YES;
    self.currentCommentType = MLEBCommentTypeAssessments;
    self.currentButton = sender;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.scrollViewLeadingConstraint.constant = ScreenRect.size.width * 1 / 3;
        [self.view layoutIfNeeded];
    }];
    
    [self.tableView triggerPullToRefresh];
}

- (IBAction)badReviewsButton:(UIButton *)sender {
    self.emptySetTipsLabel.hidden = YES;
    
    self.isLoadBadReviews = YES;
    self.currentCommentType = MLEBCommentTypeBadReviews;
    self.currentButton = sender;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.scrollViewLeadingConstraint.constant = ScreenRect.size.width * 2 / 3;;
        [self.view layoutIfNeeded];
    }];
    
    [self.tableView triggerPullToRefresh];
}

#pragma mark- Public Methods

#pragma mark- Delegate，DataSource, Callback Method
#pragma mark -UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MLEBCommentTableViewCell";
    MLEBCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell configureCell:self.currentComments[indexPath.row]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentComments.count;
}

#pragma mark- Private Methods

#pragma mark- Getter Setter
- (NSMutableArray *)praises {
    if (!_praises) {
        _praises = [NSMutableArray new];
    }
    
    return _praises;
}

- (NSMutableArray *)assessments {
    if (!_assessments) {
        _assessments = [NSMutableArray new];
    }
    
    return _assessments;
}

- (NSMutableArray *)badReviews {
    if (!_badReviews) {
        _badReviews = [NSMutableArray new];
    }
    
    return _badReviews;
}

- (NSMutableArray *)currentComments {
    if (self.currentCommentType == MLEBCommentTypePraises) {
        return self.praises;
    }
    
    if (self.currentCommentType == MLEBCommentTypeAssessments) {
        return self.assessments;
    }
    
    if (self.currentCommentType == MLEBCommentTypeBadReviews) {
        return self.badReviews;
    }
    
    
    return self.praises;
}

#pragma mark- Helper Method

#pragma mark Temporary Area

@end
