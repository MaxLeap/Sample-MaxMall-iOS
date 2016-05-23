//
//  MLEBWebService+ShoppingCart.h
//  MaxLeapMall
//
//  Created by julie on 15/11/19.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBWebService.h"

@interface MLEBWebService (ShoppingCart)

/**
 *  获取用户的购物车信息
 */
- (void)fetchShoppingItemsWithCompletion:(void (^)(NSArray *, NSError *))completion;

/**
 *  添加至购物车,更新数量
 */
- (void)addOrUpdateShoppingItem:(MLEBShoppingItem *)shoppingItem completion:(void(^)(BOOL succeeded, NSError *error))completion;

/**
 *  从购物车中移除shoppingItem
 */
- (void)deleteShoppingItem:(MLEBShoppingItem *)shoppingItem completion:(void(^)(BOOL succeeded, NSError *error))completion;

- (void)syncShoppingItemsToMaxLeapWithCompletion:(void(^)(BOOL succeeded, NSError *error))completion;

@end
