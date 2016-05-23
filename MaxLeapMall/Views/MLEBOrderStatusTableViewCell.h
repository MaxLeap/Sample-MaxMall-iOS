//
//  MLEBOrderStatusTableViewCell.h
//  MaxLeapMall
//
//  Created by julie on 15/11/18.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLEBOrderStatusTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *orderIdLabel;
@property (weak, nonatomic) IBOutlet UIButton *orderStatusButton;

@property (nonatomic, copy) dispatch_block_t cancelOrderHandler;
@property (nonatomic, copy) dispatch_block_t payOrderHandler;

- (void)configureCell:(MLEBOrder *)order;

@end
