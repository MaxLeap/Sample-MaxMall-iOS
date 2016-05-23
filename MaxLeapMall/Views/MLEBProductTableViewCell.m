//
//  MLEBProductTableViewCell.m
//  MaxLeapMall
//
//  Created by Michael on 11/17/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import "MLEBProductTableViewCell.h"

@interface MLEBProductTableViewCell ()
@property (nonatomic, strong) MLEBProduct *product;
@end

@implementation MLEBProductTableViewCell

#pragma mark - init Method


#pragma mark- Override Parent Methods

#pragma mark- SubViews Configuration

#pragma mark- Actions
- (void)prepareForReuse {
    self.commentCountLabel.text = @"";
}

#pragma mark- Public Methods
- (void)configureCell:(MLEBProduct *)product {
    self.product = product;
    
    NSString *thumbileURLString = [product.icons firstObject];
    UIImage *placeImage = [UIImage imageWithColor:UIColorFromRGB(0xE7EBEE)];
    [self.thumbileImageView sd_setImageWithURL:thumbileURLString.toURL placeholderImage:placeImage options:SDWebImageRetryFailed];
    self.nameLabel.text = product.intro;
    NSDecimalNumber *price = [product.price decimalNumberByDividingBy:[[NSDecimalNumber alloc] initWithInt:100]];
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@元", price];

    if (self.product.commentCount) {
        self.commentCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@人评论", nil), self.product.commentCount];
    }
   
    [kSharedWebService fetchCommentForProduct:product completion:^(NSUInteger commentCount, MLEBProduct *product, NSError *error) {
        if (product == self.product) {
            self.product.commentCount = @(commentCount);
            self.commentCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@人评论", nil), self.product.commentCount];
        }
    }];
}

#pragma mark- Delegate，DataSource, Callback Method

#pragma mark- Private Methods

#pragma mark- Getter Setter

#pragma mark- Helper Method

#pragma mark Temporary Area

@end
