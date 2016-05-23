//
//  MLEBShoppingCartFooterCell.m
//  MaxLeapMall
//
//  Created by julie on 15/11/19.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBShoppingCartFooterCell.h"

@interface MLEBShoppingCartFooterCell ()
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UILabel *priceTextLabel;
@end

@implementation MLEBShoppingCartFooterCell

- (void)awakeFromNib {
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.priceTextLabel.text = NSLocalizedString(@"总价(不计运费)", @"");
    self.priceTextLabel.textColor = kTextLightGrayColor;
    
    self.totalPriceLabel.textColor = UIColorFromRGB(0xFF7700);
    
    [self.submitButton setTitle:NSLocalizedString(@"去结算", @"") forState:UIControlStateNormal];
    [self.submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.submitButton.layer.cornerRadius = 2;
    self.submitButton.layer.masksToBounds = YES;
    self.submitButton.backgroundColor = UIColorFromRGB(0xFF7700);
}

- (IBAction)submitButtonPressed:(id)sender {
    BLOCK_SAFE_RUN(self.submitButtonHandler);
}

- (void)setSubmitButtonEnabled:(BOOL)enabled {
    self.submitButton.alpha = enabled ? 1 : 0.5;
    self.submitButton.enabled = enabled;
}

@end
