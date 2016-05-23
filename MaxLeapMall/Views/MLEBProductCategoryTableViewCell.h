//
//  MerchantKindTableViewCell.h
//  MaxLeapFood
//
//  Created by Michael on 11/3/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLEBProductCategoryTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *categoryImages;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *categoryLabels;
@property (nonatomic, copy) void(^productTypeTapHandler)(MLEBProductCategoryTableViewCell *cell, MLEBProductCategory *productCategory);
- (void)configureCell:(NSArray *)productCategorys;
@end
