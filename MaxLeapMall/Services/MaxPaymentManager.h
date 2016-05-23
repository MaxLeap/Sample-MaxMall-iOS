//
//  MaxPaymentManager.h
//  MaxLeapMall
//
//  Created by 周和生 on 16/5/18.
//  Copyright © 2016年 MaxLeapMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MaxPaymentManager : NSObject

+ (MaxPaymentManager *)sharedManager;
- (void)payWithChannel:(MLPayChannel)channel subject:(NSString *)subject billNo:(NSString *)billNo totalFen:(CGFloat)totalFen scheme:(NSString *)scheme returnUrl:(NSString *)returnUrl extraAttrs:(NSDictionary *)extraAttrs completion:(void(^)(BOOL succeeded,  MLPayResult * result))completion;

@end
