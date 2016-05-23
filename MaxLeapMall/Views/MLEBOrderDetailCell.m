//
//  MLEBOrderDetailCell.m
//  MaxLeapMall
//
//  Created by julie on 15/11/20.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBOrderDetailCell.h"

@interface MLEBOrderDetailCell ()
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet UIView *separatorLine1;

@property (weak, nonatomic) IBOutlet UILabel *orderTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryMethodLabel;

@property (weak, nonatomic) IBOutlet UIView *separatorLine2;

@property (weak, nonatomic) IBOutlet UILabel *receiptHeadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *receiptTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *receiptContentLabel;
@end

@implementation MLEBOrderDetailCell

- (void)awakeFromNib {
    self.separatorLine1.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.separatorLine2.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)configureCell:(MLEBOrder *)order {
    self.totalPriceLabel.text = [NSString stringWithFormat:@"总额: ￥%.2f", order.totalPrice.integerValue/100.0];
    
    self.contactNameLabel.text = [NSString stringWithFormat:@"收货人: %@", [order.address.name ? : @""
                                                                         stringByAppendingFormat:@"  %@", order.address.tel ? : @""]];
    self.addressLabel.text = [NSString stringWithFormat:@"收货地址: %@", order.address.street ? : @""];
    
    self.orderTimeLabel.text = [NSString stringWithFormat:@"下单时间: %@", [order.createdAt detailedHumanDateString] ? : @""];
    self.deliveryMethodLabel.text = [NSString stringWithFormat:@"配送方式: %@", order.deliveryMethod ? : @"无"];
    
    self.receiptHeadingLabel.text = [NSString stringWithFormat:@"发票抬头: %@", order.receipt.heading ? : @"无"];
    self.receiptTypeLabel.text = [NSString stringWithFormat:@"发票信息: %@", order.receipt.type ? : @"无"];
    self.receiptContentLabel.text = [NSString stringWithFormat:@"发票内容: %@", order.receipt.content ? : @"无"];
}

@end
