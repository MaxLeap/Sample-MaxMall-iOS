//
//  MLEBOrderStatusTableViewCell.m
//  MaxLeapMall
//
//  Created by julie on 15/11/18.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//
@import MaxLeapPay;
#import "MLEBOrderStatusTableViewCell.h"

@interface MLEBOrderStatusTableViewCell ()
@property (nonatomic, strong) MLEBOrder *order;
@end

@implementation MLEBOrderStatusTableViewCell

- (void)awakeFromNib {
    self.orderIdLabel.textColor = kTextLightGrayColor;
    self.orderStatusButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
}

- (void)configureCell:(MLEBOrder *)order {
    self.order = order;
    
    self.orderIdLabel.text = [NSString stringWithFormat:@"%@: ***%@", @"订单号", [self.order.orderId substringFromIndex:16]];
    [self.orderStatusButton setTitle:NSLocalizedString(@"", @"") forState:UIControlStateNormal];
    self.orderStatusButton.enabled = NO;
    
    NSString *currentOrderId = order.orderId;
    [MaxLeapPay queryOrderWithBillNo:currentOrderId
                               block:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                                   if ([currentOrderId isEqualToString:self.order.orderId]) {
                                       BOOL success = NO;
                                       for (MLOrder *billInfo in objects) {
                                           if ([billInfo.billNo isEqualToString:currentOrderId] && [billInfo.status isEqualToString:@"success"]) {
                                               success = YES;
                                           }
                                       }
                                       if (success) {
                                           NSLog(@"bill %@ payed", currentOrderId);
                                       } else {
                                           NSLog(@"bill %@ not payed", currentOrderId);
                                       }
                                       if (self.order.orderStatus.integerValue == MLEBOrderStatusDefault && !success) {
                                           self.orderStatusButton.enabled = YES;
                                           [self.orderStatusButton setTitleColor:UIColorFromRGB(0xFF4400) forState:UIControlStateNormal];
                                           [self.orderStatusButton setTitle:NSLocalizedString(@"立即支付", @"") forState:UIControlStateNormal];
                                       } else {
                                           self.orderStatusButton.enabled = NO;
                                           [self.orderStatusButton setTitleColor:UIColorFromRGB(0x404040) forState:UIControlStateNormal];
                                           [self.orderStatusButton setTitle:[kSharedWebService detailedStatusStringForOrder:self.order] forState:UIControlStateNormal];
                                       }
                                   }
                                   
                               }];
    
    
}



- (IBAction)orderStatusButtonPressed:(id)sender {
    BLOCK_SAFE_ASY_RUN_MainQueue(self.payOrderHandler);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
