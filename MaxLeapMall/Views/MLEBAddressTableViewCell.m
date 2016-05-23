//
//  MLEBAddressTableViewCell.m
//  MaxLeapMall
//
//  Created by julie on 15/11/18.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBAddressTableViewCell.h"

@interface MLEBAddressTableViewCell ()
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@end

@implementation MLEBAddressTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.editButton setImage:ImageNamed(@"ic_edit") forState:UIControlStateNormal];
    
    self.addressLabel.textColor = kTextLightGrayColor;
}

- (IBAction)editButtonPressed:(id)sender {
    BLOCK_SAFE_RUN(self.editAddressHandler);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
