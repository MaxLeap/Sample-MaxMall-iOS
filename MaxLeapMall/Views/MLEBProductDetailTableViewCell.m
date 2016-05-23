//
//  MLEBProductDetailTableViewCell.m
//  MaxLeapMall
//
//  Created by Michael on 11/18/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import "MLEBProductDetailTableViewCell.h"

@interface MLEBProductDetailTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *originPriceLabel;
@property (nonatomic, strong) MLEBProduct *product;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@end

@implementation MLEBProductDetailTableViewCell

#pragma mark - init Method


#pragma mark- Override Parent Methods

#pragma mark- SubViews Configuration

#pragma mark- Actions

#pragma mark- Public Methods
- (void)configureCell:(MLEBProduct *)product {
    self.product = product;
    self.nameLabel.text = product.title;
    self.detailLabel.text = product.intro;
    NSDecimalNumber *price = [product.price decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:100]];
    NSDecimalNumber *originalPrice = [product.originalPrice decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:100]];
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@", price];
    NSString *originPrice = [NSString stringWithFormat:@"原价￥%@", originalPrice];
    NSAttributedString *theAttributedString;
    theAttributedString = [[NSAttributedString alloc] initWithString:originPrice attributes:@{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]}];
    self.originPriceLabel.attributedText =  theAttributedString;
    
    if ([product.services count] > 0) {
        for (int i = 0; i < [product.services count]; i++) {
            UILabel *servieLabel = [self.contentView viewWithTag:i + 100];
            if (!servieLabel) {
                servieLabel = [UILabel autoLayoutView];
                [self.contentView addSubview:servieLabel];
                
                servieLabel.textColor = UIColorFromRGB(0x444444);
                servieLabel.font = [UIFont systemFontOfSize:15];
                if (i == 0) {
                    [servieLabel pinAttribute:NSLayoutAttributeLeading toAttribute:NSLayoutAttributeLeading ofItem:self.originPriceLabel];
                } else {
                    [servieLabel pinAttribute:NSLayoutAttributeLeading toAttribute:NSLayoutAttributeLeading ofItem:self.originPriceLabel withConstant:43];
                }
                
                [servieLabel pinAttribute:NSLayoutAttributeTop toAttribute:NSLayoutAttributeBottom ofItem:self.originPriceLabel withConstant:10 + 28 * i];
            }
            
            if (i == 0) {
                servieLabel.text = [NSString stringWithFormat:@"服务: %@", product.services[i]];
            } else {
                servieLabel.text = product.services[i];
            }
        }
    }
    
    if ([product.services count] > 0) {
        self.bottomConstraint.constant = MAX(13, 13 + 28 * [product.services count]);
    }
    [self updateConstraints];
}

#pragma mark- Delegate，DataSource, Callback Method

#pragma mark- Private Methods

#pragma mark- Getter Setter

#pragma mark- Helper Method

#pragma mark Temporary Area

@end
