//
//  MLEBShoppingCartFooterCell.h
//  MaxLeapMall
//
//  Created by julie on 15/11/19.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLEBShoppingCartFooterCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (nonatomic, copy) dispatch_block_t submitButtonHandler;

- (void)setSubmitButtonEnabled:(BOOL)enabled;

@end
