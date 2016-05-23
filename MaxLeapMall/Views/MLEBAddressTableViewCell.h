//
//  MLEBAddressTableViewCell.h
//  MaxLeapMall
//
//  Created by julie on 15/11/18.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLEBAddressTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *telLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (nonatomic, copy) dispatch_block_t editAddressHandler;

@end
