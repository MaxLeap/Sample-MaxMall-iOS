//
//  MLEBOrderActionButtonCell.m
//  MaxLeapMall
//
//  Created by julie on 15/11/18.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBOrderActionButtonCell.h"

@interface MLEBOrderActionButtonCell ()

@end

@implementation MLEBOrderActionButtonCell

- (void)awakeFromNib {
   
    [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.actionButton.backgroundColor = UIColorFromRGB(0xFF7700);
    self.actionButton.layer.cornerRadius = 2;
}


- (IBAction)actionButtonPressed:(id)sender {
    BLOCK_SAFE_ASY_RUN_MainQueue(self.actionHandler);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
