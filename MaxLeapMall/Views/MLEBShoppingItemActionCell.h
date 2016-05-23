//
//  MLEBShoppingItemActionCell.h
//  MaxLeapMall
//
//  Created by julie on 15/11/19.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLEBShoppingItemActionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;

@property (nonatomic, copy) dispatch_block_t plusButtonHandler;
@property (nonatomic, copy) dispatch_block_t minusButtonHandler;

- (void)configureCell:(MLEBShoppingItem *)shoppingItem;

@end
