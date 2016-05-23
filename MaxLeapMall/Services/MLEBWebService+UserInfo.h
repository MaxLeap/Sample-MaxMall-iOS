//
//  MLEBWebService+UserInfo.h
//  MaxLeapMall
//
//  Created by julie on 15/11/17.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBWebService.h"

typedef NS_ENUM(NSUInteger, MLEBOrderStatus) {
    MLEBOrderStatusDefault = 0,//submitted -》 订单处理中（用户下单自动触发此状态）
    MLEBOrderStatusToBeDelivered = 1,
    MLEBOrderStatusInDelivery = 2,
    MLEBOrderStatusReceived = 3,
    MLEBOrderStatusCommented = 4,
    MLEBOrderStatusCancelledByUser = 10,
    MLEBOrderStatusCancelledByMerchant = 11 //商户取消
};

#define kLocalUserIconFilePath [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/UserIcon.jpg"]

@interface MLEBWebService (UserInfo)

/**************************** Login/User info ***************************/

/**
*  判断用户是否登录，匿名登录判断为未登录
*/
- (BOOL)isLoggedIn;

/**
 *  返回当前用户，未登录状态(使用 isLoggedIn 方法判断)返回 nil
 */
- (MLUser *)currentUser;

/**
 *  登录/注册
 */
- (void)loginWithMobilePhone:(NSString *)phoneNumber smsCode:(NSString *)smsCode completion:(void(^)(MLUser *user, BOOL succeeded, NSError *error))completion;

/**
 *  保存用户的基本信息：username, nickname, tel
 */
- (void)fetchUserBasicInfoWithCompletion:(void(^)(MLEBUser *user, NSError *error))completion;

/**
 *  获取并保存用户的头像
 */
- (void)fetchUserIconWithCompletion:(void(^)(UIImage *image, NSError *error))completion;

/**
 *  获取并保存地址信息
 */
- (void)fetchUserAddressesWithCompletion:(void(^)(NSOrderedSet *addresses, NSError *error))completion;

/**
 *  更新用户的昵称
 */
- (void)updateNickName:(NSString *)nickName completion:(void(^)(BOOL succeeded, NSError *error))completion;

/**
 *  同步用户的头像
 */
- (void)syncUserIconWithMaxLeapWithCompletion:(void(^)(BOOL succeeded, NSError *error))completion;
//本地保存头像
- (void)saveNewIcon:(UIImage *)image completion:(void(^)(BOOL succeeded))completion;

/**
 *  更新用户的地址列表
 */
- (void)syncAddressesToMaxLeapWithCompletion:(void(^)(BOOL succeeded, NSError *error))completion;

/**************************** Favorites ***************************/
/**
 *  获取用户收藏的商家信息
 */
- (void)fetchFavoritesWithCompletion:(void(^)(NSOrderedSet *favorites, NSError *error))completion;

/**
 *  查询是否已收藏某商家
 */
- (void)checkLikeStatusForProduct:(MLEBProduct *)merchant completion:(void(^)(BOOL isLiked, NSError *error))completion;

/**
 *  收藏喜欢的商家
 */
- (void)markFavoriteProduct:(MLEBProduct *)merchant completion:(void(^)(BOOL succeeded, NSError *error))completion;

/**
 *  取消收藏
 */
- (void)unmarkFavoriteProduct:(MLEBProduct *)merchant completion:(void(^)(BOOL succeeded, NSError *error))completion;


/**************************** Orders ***************************/
/**
 *  提交订单
 */
- (void)submitOrder:(MLEBOrder *)order completion:(void(^)(BOOL succeeded, NSError *error))completion;

/**
 *  获取用户的订单列表
 */
- (void)fetchOrdersFromPage:(NSUInteger)page completion:(void(^)(NSArray<MLEBOrder *> *orders, BOOL didReachEnd, NSError *error))completion;

/**
 *  确认收货
 */
- (void)confirmReceivalForOrder:(MLEBOrder *)order completion:(void(^)(BOOL succeeded, NSError *error))completion;

/**
 *  取消订单
 */
- (void)cancelOrder:(MLEBOrder *)order completion:(void(^)(BOOL succeeded, NSError *error))completion;

/**
 *  提交评论
 */
- (void)submitComments:(NSArray<MLEBComment *> *)comments forOrder:(MLEBOrder *)order completion:(void(^)(BOOL succeeded, NSError *error))completion;

/**************************** Helper Methods ***************************/
/**
 *  转换成对应NSManagedObjectContext中的NSManagedObject
 */
- (MLEBProduct *)productMOInTargetContext:(NSManagedObjectContext *)targetCtx fromProduct:(MLEBProduct *)merchant;

- (NSString *)detailedStatusStringForOrder:(MLEBOrder *)order;

@end
