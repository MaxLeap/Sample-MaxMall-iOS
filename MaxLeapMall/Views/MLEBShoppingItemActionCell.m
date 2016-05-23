//
//  MLEBShoppingItemActionCell.m
//  MaxLeapMall
//
//  Created by julie on 15/11/19.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBShoppingItemActionCell.h"

@interface MLEBShoppingItemActionCell ()
@property (weak, nonatomic) IBOutlet UIButton *minusButton;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;

@end

@implementation MLEBShoppingItemActionCell

- (void)awakeFromNib {
    self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.introLabel.numberOfLines = 2;
    
    [self.minusButton setImage:ImageNamed(@"btn_minus_one_normal") forState:UIControlStateNormal];
    [self.minusButton setImage:ImageNamed(@"btn_minus_one_selected") forState:UIControlStateHighlighted];
    
    [self.plusButton setImage:ImageNamed(@"btn_add_one_normal") forState:UIControlStateNormal];
    [self.plusButton setImage:ImageNamed(@"btn_add_one_selected") forState:UIControlStateHighlighted];
}

- (IBAction)plusButtonPressed:(id)sender {
    BLOCK_SAFE_ASY_RUN_MainQueue(self.plusButtonHandler);
}

- (IBAction)minusButtonPressed:(id)sender {
    BLOCK_SAFE_ASY_RUN_MainQueue(self.minusButtonHandler);
}

- (void)configureCell:(MLEBShoppingItem *)shoppingItem {
    NSString *urlString = [shoppingItem.product.icons firstObject];
    [self.thumbnailImageView sd_setImageWithURL:urlString.toURL placeholderImage:[UIImage imageWithColor:UIColorFromRGB(0xE7EBEE)] options:SDWebImageRetryFailed];
    NSDecimalNumber *price = [shoppingItem.product.price decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:100]];
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@", price ?: @"0"];
   
    self.introLabel.attributedText = [self attributedTitleForShoppingItem:shoppingItem];
    self.quantityLabel.text = [NSString stringWithFormat:@"%@", shoppingItem.quantity ? : @"1"];
}

- (NSAttributedString *)attributedTitleForShoppingItem:(MLEBShoppingItem *)shoppingItem {
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:shoppingItem.product.title ?: @"" attributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"   %@", shoppingItem.custom_infos ?: @""] attributes:@{NSForegroundColorAttributeName : kTextLightGrayColor}]];
    return [string copy];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
