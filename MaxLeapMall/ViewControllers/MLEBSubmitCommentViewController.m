//
//  MLEBSubmitCommentViewController.m
//  MaxLeapMall
//
//  Created by julie on 15/11/24.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBSubmitCommentViewController.h"

@interface MLEBSubmitCommentViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *submitCommentButton;

@property (nonatomic, strong) NSMutableArray<MLEBComment *> *comments;
@property (nonatomic, strong) MLEBOrderItem *selectedOrderItem;

@end

@implementation MLEBSubmitCommentViewController

#pragma mark - init Method

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.title = NSLocalizedString(@"评价", @"");
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    
    [self.submitCommentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.submitCommentButton.backgroundColor = UIColorFromRGB(0xFF7700);
    self.submitCommentButton.layer.cornerRadius = 2;
    [self.submitCommentButton setTitle:NSLocalizedString(@"提交评价", @"") forState:UIControlStateNormal];
}

#pragma mark- SubView Configuration

#pragma mark- Action
- (IBAction)submitCommentsButtonPressed:(id)sender {
    if (![self hasCommmentedAllProducts]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"请评价所有商品", @"")];
        return;
    }
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"正在提交...", @"")];
    [kSharedWebService submitComments:self.comments forOrder:self.order completion:^(BOOL succeeded, NSError *error) {
        if (succeeded && !error) {
            self.order.orderStatus = @(MLEBOrderStatusCommented);
            
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"评论成功!", @"")];
            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
            if (error.code == NSURLErrorTimedOut) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络连接超时", nil)];
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"出错了", nil)];
            }
        }
    }];
}

#pragma mark- Delegate，DataSource, Callback Method
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.order.orderItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    MLEBOrderItem *orderItem = self.order.orderItems[indexPath.section];
    if (indexPath.row == 0) {
        MLEBOrderItemBriefInfoCell *orderItemCell = [tableView dequeueReusableCellWithIdentifier:@"MLEBOrderItemBriefInfoCell" forIndexPath:indexPath];
        [orderItemCell configureCell:orderItem];
        cell = orderItemCell;
        
    } else {
        MLEBCommentInputCell *commentInputCell = [tableView dequeueReusableCellWithIdentifier:@"MLEBCommentInputCell" forIndexPath:indexPath];
        MLEBComment *comment = self.comments[indexPath.section];
        commentInputCell.starRatingHandler = ^(float score){
            comment.score = @(score);
        };
        commentInputCell.commentHandler = ^(NSString *content){
            comment.content = content;
        };
        
        cell = commentInputCell;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
    if (indexPath.row == 0) {
        self.selectedOrderItem = self.order.orderItems[indexPath.section];
        [self performSegueWithIdentifier:@"MLEBProductViewControllerSegueIdentifier" sender:nil];
    }
}

#pragma mark- Override Parent Method

#pragma mark- Private Method

#pragma mark- Getter Setter
- (NSMutableArray *)comments {
    if (!_comments) {
        _comments = [NSMutableArray array];
        [self.order.orderItems enumerateObjectsUsingBlock:^(MLEBOrderItem * _Nonnull orderItem, NSUInteger idx, BOOL * _Nonnull stop) {
            MLEBComment *comment = [MLEBComment MR_createEntityInContext:kSharedWebService.scratchContext];
            comment.product = orderItem.product;
            [_comments addObject:comment];
        }];
    }
    return _comments;
}

#pragma mark- Helper Method

- (BOOL)hasCommmentedAllProducts {
    __block BOOL hasScoredAll = YES;
    [self.comments enumerateObjectsUsingBlock:^(MLEBComment * _Nonnull comment, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!comment.score) {
            hasScoredAll = NO;
            *stop = YES;
        }
    }];
    
    if (hasScoredAll) {
        [self.comments enumerateObjectsUsingBlock:^(MLEBComment * _Nonnull comment, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!comment.content.length) {
                //auto generate comment content
                comment.content = [self defaultContentStringBasedOnScoredComment:comment];
            }
        }];
    }
    
    return hasScoredAll;
}

- (NSString *)defaultContentStringBasedOnScoredComment:(MLEBComment *)comment {
    if (comment.score.floatValue >= 4.0) {
        return NSLocalizedString(@"非常不错!", @"");//满意
    } else if (comment.score.floatValue >= 3.0) {
        return NSLocalizedString(@"比较一般，还可以。", @""); //一般
    } else {
        return NSLocalizedString(@"不太满意，有待改进。", @""); //不满意
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MLEBProductViewController *vcProduct = [segue destinationViewController];
    vcProduct.product = self.selectedOrderItem.product;
    vcProduct.selectedCustomInfo1 = self.selectedOrderItem.selected_custom_info1;
    vcProduct.selectedCustomInfo2 = self.selectedOrderItem.selected_custom_info2;
    vcProduct.selectedCustomInfo3 = self.selectedOrderItem.selected_custom_info3;
}


@end
