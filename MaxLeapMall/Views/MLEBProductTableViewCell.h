//
//  MLEBProductTableViewCell.h
//  MaxLeapMall
//
//  Created by Michael on 11/17/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLEBProductTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;

- (void)configureCell:(MLEBProduct *)product;
@end
