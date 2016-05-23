//
//  MLEBOrderActionButtonCell.h
//  MaxLeapMall
//
//  Created by julie on 15/11/18.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLEBOrderActionButtonCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@property (nonatomic, copy) dispatch_block_t actionHandler;
@end
