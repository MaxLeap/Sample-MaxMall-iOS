//
//  MaxPaymentManager.m
//  MaxLeapMall
//
//  Created by 周和生 on 16/5/18.
//  Copyright © 2016年 MaxLeapMobile. All rights reserved.
//

@import MaxLeapPay;
#import "MaxPaymentManager.h"

@implementation MaxPaymentManager

+ (MaxPaymentManager *)sharedManager {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [MaxPaymentManager new];
    });
}


- (void)payWithChannel:(MLPayChannel)channel subject:(NSString *)subject billNo:(NSString *)billNo totalFen:(CGFloat)totalFen scheme:(NSString *)scheme returnUrl:(NSString *)returnUrl extraAttrs:(NSDictionary *)extraAttrs completion:(void(^)(BOOL succeeded,  MLPayResult * result))completion {
    
    // 1. 生成订单
    MLPayment *payment = [[MLPayment alloc] init];
    
    // 设置使用 AliApp 渠道支付，该渠道会打开支付宝应用进行支付，如果没有安装支付宝应用，支付宝 SDK 会打开一个网页进行支付
    // 设置通过”微信移动支付“渠道支付，该支付方式目前要求必须安装有微信应用，否则无法使用
    payment.channel = channel;
    
    // 交易号要保证在商户系统中唯一
    payment.billNo = billNo;
    
    // 订单简要说明
    payment.subject = subject;
    
    // 总金额，单位：分
    payment.totalFee = totalFen;
    
    // 支付宝支付完成后通知支付结果时需要用到，没有固定格式，可以是 info.plist -> URL Types 中的任意一个 scheme
    // 微信注意：这个值不需要设置，但是需要在 info.plist -> URL Types 中配置微信专用 URL Scheme, scheme 值为微信应用的 appId
    payment.scheme = scheme;
    
    // 银联需要配置 returnUrl
    payment.returnUrl = returnUrl;
    
    // 配置自定义字段
    if (extraAttrs.count) {
        [payment.extraAttrs addEntriesFromDictionary:extraAttrs];
    }
    
    
    // 2. 开始支付流程
    [MaxLeapPay startPayment:payment
                  completion:^(MLPayResult * _Nonnull result) {
                      if (result.code == MLPaySuccess) {
                          NSLog(@"支付成功");
                          if (completion) {
                              completion(YES, nil);
                          }
                      } else {
                          NSLog(@"支付失败");
                          if (completion) {
                              completion(NO, result);
                          }
                      }
                  }];
    
}


@end
