//
//  MLEBShoppingItemInfoCell.m
//  MaxLeapMall
//
//  Created by julie on 15/11/20.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBShoppingItemInfoCell.h"

@implementation MLEBShoppingItemInfoCell

- (void)awakeFromNib {
    self.introLabel.textColor = UIColorFromRGB(0x444444);
    self.quantityLabel.textColor = UIColorFromRGB(0x8F8F8F);
    self.priceLabel.textColor = UIColorFromRGB(0x444444);
}

- (void)configureCell:(MLEBShoppingItem *)shoppingItem {
    NSString *urlString = [shoppingItem.product.icons firstObject];
    [self.thumbnailImageView sd_setImageWithURL:urlString.toURL placeholderImage:[UIImage imageWithColor:UIColorFromRGB(0xE7EBEE)] options:SDWebImageRetryFailed];
   
    self.introLabel.attributedText = [self attributedTitleForShoppingItem:shoppingItem];
    self.quantityLabel.text = [NSString stringWithFormat:@"共%@件", shoppingItem.quantity];
    NSDecimalNumber *price = [shoppingItem.product.price decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:100]];
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@", price];
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
