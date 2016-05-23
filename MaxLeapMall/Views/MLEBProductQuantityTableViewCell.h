//
//  MLEBProductQuantityTableViewCell.h
//  MaxLeapMall
//
//  Created by Michael on 11/18/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLEBProductQuantityTableViewCell : UITableViewCell
@property (nonatomic, copy) void(^plusProductOrderHandler)(MLEBProductQuantityTableViewCell *cell);
@property (nonatomic, copy) void(^minusProductOrderHandler)(MLEBProductQuantityTableViewCell *cell);
- (void)configureCell:(MLEBShoppingItem *)shoppingItem;
@end
