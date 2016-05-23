//
//  MLEBProductBriefInfoCell.m
//  MaxLeapMall
//
//  Created by julie on 15/11/18.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBOrderItemBriefInfoCell.h"

@interface MLEBOrderItemBriefInfoCell ()
@property (weak, nonatomic) IBOutlet UIImageView *itemIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *itemIntroLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemQuantityLabel;

@end

@implementation MLEBOrderItemBriefInfoCell

- (void)awakeFromNib {
    // Initialization code
    
    self.itemQuantityLabel.textColor = kTextLightGrayColor;
    self.itemIntroLabel.numberOfLines = 2;
    self.itemIntroLabel.textColor = UIColorFromRGB(0x444444);
}

- (void)configureCell:(MLEBOrderItem *)orderItem {
    NSString *iconUrl = [orderItem.product.icons firstObject];
    [self.itemIconImageView sd_setImageWithURL:iconUrl.toURL placeholderImage:ImageNamed(@"default_item") options:SDWebImageRetryFailed];
    
    self.itemIntroLabel.attributedText = [self attributedTitleForOrderItem:orderItem];
    self.itemQuantityLabel.text = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"共", @""), orderItem.quantity, NSLocalizedString(@"件", @"")];
}

- (NSAttributedString *)attributedTitleForOrderItem:(MLEBOrderItem *)orderItem {
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:orderItem.product.title ?: @"" attributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"   %@", orderItem.custom_infos ?: @""] attributes:@{NSForegroundColorAttributeName : kTextLightGrayColor}]];
    return [string copy];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
