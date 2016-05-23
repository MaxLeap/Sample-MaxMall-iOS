//
//  MLEBWebService+HomePage.h
//  MaxLeapMall
//
//  Created by Michael on 11/26/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import "MLEBWebService.h"

@interface MLEBWebService (HomePage)
/**
 * 获取首页的banner列表
 */
- (void)fetchBannersCompletion:(void(^)(NSArray *banners, NSError *error))completion;

/**
 * 获取首页的快捷分类
 */
- (void)fetchProductCategoryCompletion:(void(^)(NSArray *productCategorys, NSError *error))completion;

/**
 * 获取商品列表
 */
- (void)fetchProductsFromPage:(NSUInteger)page completion:(void(^)(NSArray *merchaints, BOOL isReachEnd, NSError *error))completion;

/**
 * 根据产品分类获取产品
 */
- (void)fetchProductWithProductCategory:(MLEBProductCategory *)productCategory
                               fromPage:(NSUInteger)page
                             completion:(void(^)(NSArray *products, BOOL isReacheEnd, NSError *error))completion ;

/**
 * 根据商品名字获取商品列表
 */
- (void)fetchProductWithProductName:(NSString *)productName
                           fromPage:(NSUInteger)page
                         primaryKey:(NSString *)primaryKey
                    primaryKeyOrder:(NSComparisonResult)primaryKeyOrder
                       secondaryKey:(NSString *)secondaryKey
                  secondaryKeyOrder:(NSComparisonResult)secondaryKeyOrder
                         completion:(void(^)(NSArray *products, BOOL isReacheEnd, NSError *error))completion ;

/**
 * 获取评论
 */
- (void)fetchProductCommentWithType:(MLEBCommentType)commentType
                            product:(MLEBProduct *)product
                           fromPage:(NSUInteger)page
                         completion:(void(^)(NSArray *comments, BOOL isReachEnd, NSError *error))completion;

/**
 * 获取指定产品的评论数目
 */
- (void)fetchCommentForProduct:(MLEBProduct *)product completion:(void(^)(NSUInteger commentCount, MLEBProduct *product, NSError *error))completion;

@end
