//
//  MerchantKindTableViewCell.m
//  MaxLeapFood
//
//  Created by Michael on 11/3/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import "MLEBProductCategoryTableViewCell.h"

@interface MLEBProductCategoryTableViewCell ()
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, strong) NSArray *productCategorys;
@end

@implementation MLEBProductCategoryTableViewCell
- (void)awakeFromNib {
    self.currentIndex = NSNotFound;
    NSArray *presetTitle = @[@"男装", @"女装", @"鞋靴", @"箱包", @"婴童", @"美妆", @"食品", @"珠宝"];
    [presetTitle enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < self.categoryImages.count) {
            UIImageView *oneCategoryImage = self.categoryImages[idx];
            UIImage *placeImage = [UIImage imageWithColor:UIColorFromRGB(0xE7EBEE) withRadius:45 / 2];
            oneCategoryImage.image = placeImage;
        }
        
        if (idx < self.categoryLabels.count) {
            UILabel *oneCategoryLabel = self.categoryLabels[idx];
            oneCategoryLabel.textColor = UIColorFromRGB(0x404040);
            oneCategoryLabel.text = presetTitle[idx];
        }
    }];
}

- (void)configureCell:(NSArray *)productCategorys {
    self.productCategorys = productCategorys;
    [productCategorys enumerateObjectsUsingBlock:^(MLEBProductCategory *oneProductCategory, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < self.categoryImages.count) {
            UIImageView *oneCategoryImage = self.categoryImages[idx];
            UIImage *placeImage = [UIImage imageWithColor:UIColorFromRGB(0xE7EBEE) withRadius:45 / 2];
            [oneCategoryImage sd_setImageWithURL:oneProductCategory.iconUrlString.toURL placeholderImage:placeImage options:SDWebImageRetryFailed];
        }
        
        if (idx < self.categoryLabels.count) {
            UILabel *oneCategoryLabel = self.categoryLabels[idx];
            oneCategoryLabel.textColor = UIColorFromRGB(0x404040);
            oneCategoryLabel.text = oneProductCategory.title;
        }
    }];
    
    [self updateConstraints];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    [self.categoryImages enumerateObjectsUsingBlock:^(UIImageView *oneImageView, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(oneImageView.frame, location) && idx < self.productCategorys.count) {
            self.currentIndex = idx;
            *stop = YES;
        }
    }];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    __block NSUInteger selectedIndexAtEnd = 0;
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    [self.categoryImages enumerateObjectsUsingBlock:^(UIImageView *oneImageView, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(oneImageView.frame, location) && idx < self.productCategorys.count) {
            selectedIndexAtEnd = idx;
            *stop = YES;
        }
    }];
    
    if (self.currentIndex == selectedIndexAtEnd) {
        BLOCK_SAFE_ASY_RUN_MainQueue(self.productTypeTapHandler, self, self.productCategorys[selectedIndexAtEnd]);
    }
    
    self.currentIndex = NSNotFound;
}

@end
