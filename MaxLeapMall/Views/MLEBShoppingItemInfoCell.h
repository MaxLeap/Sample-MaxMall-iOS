//
//  MLEBShoppingItemInfoCell.h
//  MaxLeapMall
//
//  Created by julie on 15/11/20.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLEBShoppingItemInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;

- (void)configureCell:(MLEBShoppingItem *)shoppingItem;

@end
