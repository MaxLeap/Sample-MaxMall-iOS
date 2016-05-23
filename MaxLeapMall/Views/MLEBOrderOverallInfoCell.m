//
//  MLEBOrderOverallInfoCell.m
//  MaxLeapMall
//
//  Created by julie on 15/11/18.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBOrderOverallInfoCell.h"

@implementation MLEBOrderOverallInfoCell

- (void)awakeFromNib {
    self.totalPriceLabel.textColor = UIColorFromRGB(0x444444);
    self.orderTimeLabel.textColor = UIColorFromRGB(0x444444);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
