//
//  MLEBWebService+UserInfo.m
//  MaxLeapMall
//
//  Created by julie on 15/11/17.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBWebService+UserInfo.h"

@implementation MLEBWebService (UserInfo)

NSString * const iconName = @"UserIcon";
NSString * const newIconName = @"NewUserIcon";

#pragma mark - login / user info
- (BOOL)isLoggedIn {
    MLUser *currentUser = [MLUser currentUser];
    BOOL loggedIn = currentUser!=nil && ! [MLAnonymousUtils isLinkedWithUser:currentUser];
    return loggedIn;
}

- (MLUser *)currentUser {
    if (self.isLoggedIn) {
        return [MLUser currentUser];
    }
    return nil;
}

- (void)loginWithMobilePhone:(NSString *)phoneNumber smsCode:(NSString *)smsCode completion:(void(^)(MLUser *user, BOOL succeeded, NSError *error))completion {
    [MLUser loginWithPhoneNumber:phoneNumber smsCode:smsCode block:^(MLUser * _Nullable user, NSError * _Nullable error) {
        if (user && !error) {
            if (user.isNew) {
                DDLogInfo(@"注册成功:phoneNumber = %@, smsCode = %@", phoneNumber, smsCode);
            } else {
                DDLogInfo(@"登录成功:phoneNumber = %@, smsCode = %@", phoneNumber, smsCode);
            }
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, user, YES, nil);
            
        } else {
            DDLogInfo(@"用手机验证码登录失败:phoneNumber = %@, smsCode = %@, error: %@", phoneNumber, smsCode, error);
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, NO, error);
        }
    }];
}

- (void)fetchUserBasicInfoWithCompletion:(void(^)(MLEBUser *user, NSError *error))completion {
    MLUser *mlUser = self.currentUser;
    if ([self isLoggedIn]) {
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            NSString *username = mlUser[@"username"];
            NSString *tel = username;
            MLEBUser *user = [MLEBUser MR_findFirstOrCreateByAttribute:@"tel" withValue:tel inContext:localContext];
            user.nickname = mlUser[@"nickname"];
            user.tel = tel;
             
        } completion:^(BOOL contextDidSave, NSError *error) {
            if (error) {
                DDLogError(@"magical record - save user info error:%@", error.localizedDescription);
            }
            
            MLEBUser *user = [MLEBUser MR_findFirst];
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, user, error);
        }];
        
    } else {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, nil);
    }
}

- (void)saveNewIcon:(UIImage *)image completion:(void(^)(BOOL succeeded))completion {
    NSData *imageData = UIImagePNGRepresentation(image);
    BOOL succeeded = [imageData writeToFile:kLocalUserIconFilePath atomically:YES];
    
    MLEBUser *user = [MLEBUser MR_findFirstInContext:self.defaultContext];
    user.iconImage = [UIImage imageWithData:imageData];
    [self.defaultContext MR_saveToPersistentStoreAndWait];
    
    BLOCK_SAFE_ASY_RUN_MainQueue(completion, succeeded);
}

- (void)syncUserIconWithMaxLeapWithCompletion:(void(^)(BOOL succeeded, NSError *error))completion {
    //local image exists: upload; otherwise, fetch
    UIImage *localIconImage = [UIImage imageWithContentsOfFile:kLocalUserIconFilePath];
    if (localIconImage) {
        [self uploadIconToMaxLeap:localIconImage completion:^(BOOL succeeded, NSError *error) {
            if (succeeded && !error) {
                BLOCK_SAFE_ASY_RUN_MainQueue(completion, YES, nil);
            } else {
                BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
            }
        }];
        
    } else {
        [self fetchUserIconWithCompletion:^(UIImage *image, NSError *error) {
            if (image && !error) {
                BLOCK_SAFE_ASY_RUN_MainQueue(completion, YES, nil);
            } else {
                BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
            }
        }];
    }
}


- (void)fetchUserAddressesWithCompletion:(void(^)(NSOrderedSet *addresses, NSError *error))completion {
    MLUser *mlUser = [kSharedWebService currentUser];
    if (mlUser) {
        MLQuery *query = [MLQuery queryWithClassName:@"Address"];
        [query whereKey:@"user" equalTo:mlUser];
        [query findObjectsInBackgroundWithBlock:^(NSArray *mlAddresses, NSError *error) {
            if (error) {
                BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, error);
                return;
            }
            
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                MLEBUser *user = [MLEBUser MR_findFirstInContext:localContext];
                
                // 远程有，本地没有，添加到本地
                [mlAddresses enumerateObjectsUsingBlock:^(MLObject *  _Nonnull addressObj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"street = %@ AND name = %@ AND tel = %@", addressObj[@"street"], addressObj[@"name"], addressObj[@"tel"]];
                    MLEBAddress *address = [MLEBAddress MR_findFirstWithPredicate:predicate inContext:localContext];
                    if (!address) {
                        address = [MLEBAddress MR_createEntityInContext:localContext];
                    }
                    address.name = addressObj[@"name"];
                    address.tel = addressObj[@"tel"];
                    address.street = addressObj[@"street"];
                    address.user = user;
                    address.mlObject = addressObj;
                }];
                
                // 本地有，服务器没有， 从本地删除，因为这里是初始同步，不存在用户刚加了一个新的地址
                NSArray *localAddressMOs = [MLEBAddress MR_findAll];
                [localAddressMOs enumerateObjectsUsingBlock:^(MLEBAddress *addressMO, NSUInteger idx, BOOL * stop) {
                    __block BOOL isNeedDelete = YES;
                    [mlAddresses enumerateObjectsUsingBlock:^(MLObject *addressObj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSString *name = addressObj[@"name"];
                        NSString *tel = addressObj[@"tel"];
                        NSString *street = addressObj[@"street"];
                        if ([name isEqualToString:addressMO.name] && [tel isEqualToString:addressMO.tel] && [street isEqualToString:addressMO.street]) {
                            isNeedDelete = NO;
                            *stop = YES;
                        }
                    }];
                    
                    if (isNeedDelete) {
                        [addressMO MR_deleteEntityInContext:localContext];
                    }
                }];
            } completion:^(BOOL contextDidSave, NSError *error) {
                if (error) {
                    DDLogError(@"magical record - save addresses error:%@", error.localizedDescription);
                }
                
                MLEBUser *user = [MLEBUser MR_findFirst];
                BLOCK_SAFE_ASY_RUN_MainQueue(completion, [user.addresses copy], error);
            }];
        }];
        
    } else {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, nil);
    }
}


- (void)updateNickName:(NSString *)nickName completion:(void(^)(BOOL succeeded, NSError *error))completion {
    MLUser *mlUser = self.currentUser;
    mlUser[@"nickname"] = nickName;
    [mlUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded && !error) {
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                MLEBUser *user = [MLEBUser MR_findFirstInContext:localContext];
                user.nickname = nickName;
            } completion:^(BOOL contextDidSave, NSError *error) {
                BLOCK_SAFE_ASY_RUN_MainQueue(completion, YES, error);
            }];
            
        } else {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
        }
    }];
}


- (void)syncAddressesToMaxLeapWithCompletion:(void(^)(BOOL succeeded, NSError *error))completion {
    MLUser *user = [kSharedWebService currentUser];
    MLQuery *query = [MLQuery queryWithClassName:@"Address"];
    [query whereKey:@"user" equalTo:user];
    [query findObjectsInBackgroundWithBlock:^(NSArray *addressMLOs, NSError *error) {
        if (error) {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
            return;
        }
        
        NSArray *addressesToAddToML = [self addressMLOsToAddToMaxLeapBasedOnCurrentMLOs:addressMLOs];
        NSArray *addressesToDeleteFromML = [self addressMLOsToDeleteFromMaxLeapBasedOnCurrentMLOs:addressMLOs];
        
        __weak typeof(self) wSelf = self;
        [self addAddressesToMaxLeap:addressesToAddToML completion:^(BOOL succeeded, NSError *error) {
            if (succeeded && !error) {
                [addressesToAddToML enumerateObjectsUsingBlock:^(MLObject *insertedMLO, NSUInteger idx, BOOL * _Nonnull stop) {
                    // 将插入的mlobject赋值给本地的对象
                    NSPredicate *p = [NSPredicate predicateWithFormat:@"street = %@ AND name = %@ AND tel = %@", insertedMLO[@"street"], insertedMLO[@"name"], insertedMLO[@"tel"]];
                    MLEBAddress *addressMO = [MLEBAddress MR_findFirstWithPredicate:p inContext:[NSManagedObjectContext MR_defaultContext]];
                    addressMO.mlObject = insertedMLO;
                }];
                
                [wSelf deleteAddressesFromMaxLeap:addressesToDeleteFromML completion:^(BOOL succeeded, NSError *error) {
                    BLOCK_SAFE_ASY_RUN_MainQueue(completion, succeeded, error);
                }];
            } else {
                BLOCK_SAFE_ASY_RUN_MainQueue(completion, succeeded, error);
            }
        }];
    }];
}


#pragma mark - Favorites
- (void)fetchFavoritesWithCompletion:(void (^)(NSOrderedSet *, NSError *))completion {
    MLUser *user = self.currentUser;
    if (! [self isLoggedIn]) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, nil);
        return;
    }
    
    MLRelation *relation = [user relationForKey:@"favorites"];
    MLQuery *query = [relation query];
    if (!query) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, nil);
        return;
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *favoriteProducts, NSError *error) {
        if (favoriteProducts.count > 0 && !error) {
            
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                
                MLEBUser *user = [MLEBUser MR_findFirstInContext:localContext];
                [favoriteProducts enumerateObjectsUsingBlock:^(MLObject *  _Nonnull oneProductMLO, NSUInteger idx, BOOL * _Nonnull stop) {
                    MLEBProduct *productInScratchCtx = [self productMOFromProductMLO:oneProductMLO];
                    MLEBProduct *productMO = [MLEBProduct cloneProduct:productInScratchCtx toContext:localContext];

                    [user addFavoritesObject:productMO];
                }];
                
            } completion:^(BOOL contextDidSave, NSError *error) {
                
                MLEBUser *user = [MLEBUser MR_findFirstInContext:self.defaultContext];
                [user.favorites enumerateObjectsUsingBlock:^(MLEBProduct * _Nonnull productMO, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(MLObject * _Nonnull evaluatedMerchantMLO, NSDictionary<NSString *,id> * _Nullable bindings) {
                        return [productMO.title isEqualToString:evaluatedMerchantMLO[@"title"]];
                    }];
                    
                    NSArray *filteredArray = [favoriteProducts filteredArrayUsingPredicate:predicate];
                    if (filteredArray.count > 0) {
                        productMO.mlObject  = [filteredArray firstObject];
                    }
                }];
                
                BLOCK_SAFE_ASY_RUN_MainQueue(completion, user.favorites, error);
            }];
            
        } else {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, error);
        }
    }];
}

- (void)checkLikeStatusForProduct:(MLEBProduct *)product completion:(void(^)(BOOL isLiked, NSError *error))completion {
    MLUser *user = self.currentUser;
    MLRelation *relation = [user relationForKey:@"favorites"];
    MLQuery *query = [relation query];
    if (!query) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, nil);
        return;
    }
    
    [query whereKey:@"title" equalTo:product.title];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count > 0) {
                [self saveFavoriteProduct:product completion:^{
                    BLOCK_SAFE_ASY_RUN_MainQueue(completion, YES, nil);
                }];
                
            } else {
                [self deleteFavoriteProduct:product completion:^{
                    BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, nil);
                }];
            }
            
        } else {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
        }
    }];
}
//[{"__type":"Pointer","className":"OrderProduct","objectId":"5657f4b7cb0ecb000122dc11"}]
- (void)markFavoriteProduct:(MLEBProduct *)product completion:(void(^)(BOOL succeeded, NSError *error))completion {
    MLUser *user = self.currentUser;
    
    [MLAnalytics trackEvent:@"FavoriteProduct"
                 parameters:@{@"ProductId":SAFE_STRING(product.mlObjectId),
                              @"ProductName":SAFE_STRING(product.title),
                              @"Price":SAFE_STRING(product.price.stringValue),
                              @"UserName":SAFE_STRING(user.username)
                              }];
    
    if (! [self isLoggedIn]) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, nil);
        return;
    }
    
    MLRelation *relation = [user relationForKey:@"favorites"];
    [relation addObject:product.mlObject];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded && !error) {
            [self saveFavoriteProduct:product completion:^{
                BLOCK_SAFE_ASY_RUN_MainQueue(completion, YES, error);
            }];
            
        } else {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
        }
    }];
}

- (void)unmarkFavoriteProduct:(MLEBProduct *)merchant completion:(void(^)(BOOL succeeded, NSError *error))completion {
    MLUser *user = self.currentUser;
    if (! [self isLoggedIn]) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, nil);
        return;
    }
    
    MLRelation *relation = [user relationForKey:@"favorites"];
    [relation removeObject:merchant.mlObject];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded && !error) {
            [self deleteFavoriteProduct:merchant completion:^{
                BLOCK_SAFE_ASY_RUN_MainQueue(completion, YES, error);
            }];
            
        } else {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
        }
    }];
}

#pragma mark - Orders
- (void)submitOrder:(MLEBOrder *)order completion:(void(^)(BOOL succeeded, NSError *error))completion {
    if (! self.isLoggedIn) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, nil);
        return;
    }
    
    NSMutableArray *orderItemMLOs = [NSMutableArray array];
    [order.orderItems enumerateObjectsUsingBlock:^(MLEBOrderItem * _Nonnull orderItem, NSUInteger idx, BOOL * _Nonnull stop) {
        if (orderItem.product.mlObject) {
            MLObject *orderItemMLO = [self orderItemMLOFromMLEBOrderItem:orderItem];
            [orderItemMLOs addObject:orderItemMLO];
        }
    }];
    
    if (orderItemMLOs.count == 0) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, nil);
        return;
    }
    
    [MLObject saveAllInBackground:orderItemMLOs block:^(BOOL succeeded, NSError *error) {

        order.mlObject = [self orderMLOFromMLEBOrder:order];
        order.mlObject[@"order_status"] = @(MLEBOrderStatusDefault);
        order.mlObject[@"order_products"] = orderItemMLOs;
        [order.mlObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded && !error) {
                order.orderId = order.mlObject.objectId;
                order.createdAt = order.mlObject.createdAt;
            }
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, succeeded, error);
            
            [self updateProductSalesCountForOrderItems:order.orderItems];
        }];
    }];
}

- (void)fetchOrdersFromPage:(NSUInteger)page completion:(void(^)(NSArray<MLEBOrder *> *orders, BOOL didReachEnd, NSError *error))completion {
    if (! self.isLoggedIn) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, YES, nil);
        return;
    }
    
    MLQuery *query = [MLQuery queryWithClassName:@"Order"];
    [query whereKey:@"user" equalTo:self.currentUser];
    [query includeKey:@"address"];
    [query includeKey:@"order_products.product"];
    [query orderByDescending:@"createdAt"];
    query.skip = page * kPerPage;
    query.limit = kPerPage;
    [query findObjectsInBackgroundWithBlock:^(NSArray *orderMLOs, NSError *error) {
        DDLogInfo(@"orders.count = %lu", (unsigned long)orderMLOs.count);
        
        if (orderMLOs.count == 0 || error) {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, YES, error);
        } else {
            
            NSMutableArray *orderMOs = [NSMutableArray array];
            [orderMLOs enumerateObjectsUsingBlock:^(MLObject * _Nonnull orderMLO, NSUInteger idx, BOOL * _Nonnull stop) {
                
                MLEBOrder *orderMO = [MLEBOrder MR_findFirstOrCreateByAttribute:@"orderId" withValue:orderMLO.objectId inContext:self.scratchContext];
                orderMO.mlObject = orderMLO;

                orderMO.orderStatus = orderMLO[@"order_status"];
                orderMO.orderId = orderMLO.objectId;
                orderMO.updatedAt = orderMLO.updatedAt;
                orderMO.createdAt = orderMLO.createdAt;
                orderMO.totalPrice = orderMLO[@"total"];
                orderMO.payMethod = orderMLO[@"pay_method"];
                orderMO.deliveryMethod = orderMLO[@"delivery"];
                
                NSString *receiptHeading = orderMLO[@"receipt_heading"];
                NSString *receiptType = orderMLO[@"receipt_type"];
                NSString *receiptContent = orderMLO[@"receipt_content"];
                NSPredicate *receiptPredicate = [NSPredicate predicateWithFormat:@"heading = %@ AND type = %@ AND content = %@", receiptHeading, receiptType, receiptContent];
                MLEBReceipt *receipt = [MLEBReceipt MR_findFirstWithPredicate:receiptPredicate inContext:self.scratchContext];
                if (!receipt) {
                    receipt = [MLEBReceipt MR_createEntityInContext:self.scratchContext];
                    receipt.heading = receiptHeading;
                    receipt.type = receiptType;
                    receipt.content = receiptContent;
                }
                orderMO.receipt = receipt;
                
                MLObject *addressObj = orderMLO[@"address"]; //get associated data with Pointer
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"street = %@ AND name = %@ AND tel = %@", addressObj[@"street"], addressObj[@"name"], addressObj[@"tel"]];
                MLEBAddress *addressMO = [MLEBAddress MR_findFirstWithPredicate:predicate inContext:self.scratchContext];
                if (!addressMO) {
                    addressMO = [MLEBAddress MR_createEntityInContext:self.scratchContext];
                }
                addressMO.street = addressObj[@"street"];
                addressMO.name = addressObj[@"name"];
                addressMO.tel = addressObj[@"tel"];
                
                orderMO.address = addressMO;
               
                NSMutableOrderedSet *orderItemsSet = [NSMutableOrderedSet new];
                NSArray *orderItemMLOs = orderMLO[@"order_products"];
                [orderItemMLOs enumerateObjectsUsingBlock:^(MLObject * _Nonnull orderItemMLO, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *orderItemId = orderItemMLO.objectId;
                    NSNumber *orderItemPrice = orderItemMLO[@"price"];
                    NSNumber *orderItemQuantity = orderItemMLO[@"quantity"];
                    MLObject *orderItemProductMLO = orderItemMLO[@"product"];
                    MLEBProduct *product = [self productMOFromProductMLO:orderItemProductMLO];
                    
                    MLEBOrderItem *orderItemMO = nil;
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"orderItemId = %@", orderItemId];
                    NSOrderedSet *filteredSet = [orderMO.orderItems filteredOrderedSetUsingPredicate:predicate];
                    if (filteredSet.count > 0) {
                        orderItemMO = [filteredSet firstObject];
                    } else {
                        orderItemMO = [MLEBOrderItem MR_createEntityInContext:self.scratchContext];
                    }
                    orderItemMO.orderItemId = orderItemId;
                    orderItemMO.price = [NSDecimalNumber decimalNumberWithDecimal:[orderItemPrice decimalValue]];
                    orderItemMO.quantity = orderItemQuantity;
                    orderItemMO.custom_infos = orderItemMLO[@"custom_infos"];
                    orderItemMO.product = product;
                    
                    [orderItemsSet addObject:orderItemMO];
                }];
                orderMO.orderItems = orderItemsSet;
                
                [orderMOs addObject:orderMO];
            }];
            
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, orderMOs, orderMOs.count < kPerPage, error);
        }
    }];
}

- (void)confirmReceivalForOrder:(MLEBOrder *)order completion:(void(^)(BOOL succeeded, NSError *error))completion {
    [self updateOrderStatus:MLEBOrderStatusReceived forOrder:order completion:^(BOOL succeeded, NSError *error) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, succeeded, error);
    }];
}

- (void)cancelOrder:(MLEBOrder *)order completion:(void(^)(BOOL succeeded, NSError *error))completion {
    [self updateOrderStatus:MLEBOrderStatusCancelledByUser forOrder:order completion:^(BOOL succeeded, NSError *error) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, succeeded, error);
    }];
}

#pragma mark - Comment
- (void)submitComments:(NSArray<MLEBComment *> *)comments forOrder:(MLEBOrder *)order completion:(void(^)(BOOL succeeded, NSError *error))completion {
    NSMutableArray *commentMLOs = [NSMutableArray array];
    [comments enumerateObjectsUsingBlock:^(MLEBComment * _Nonnull comment, NSUInteger idx, BOOL * _Nonnull stop) {
        MLObject *commentMLO = [MLObject objectWithClassName:@"Comment"];
        commentMLO[@"score"] = comment.score;
        commentMLO[@"content"] = comment.content;
        commentMLO[@"product"] = comment.product.mlObject;
        commentMLO[@"user"] = self.currentUser;
        [commentMLOs addObject:commentMLO];
    }];
    
    [MLObject saveAllInBackground:commentMLOs block:^(BOOL succeeded, NSError *error) {
        if (succeeded && !error) {
            //提交评论以后更新订单的状态为”已评论“
            [self updateOrderStatus:MLEBOrderStatusCommented forOrder:order completion:^(BOOL succeeded, NSError *error) {
                BLOCK_SAFE_ASY_RUN_MainQueue(completion, succeeded, error);
            }];
        } else {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
        }
        
    }];
}

#pragma mark - Helper Methods
- (MLEBProduct *)productMOInTargetContext:(NSManagedObjectContext *)targetCtx fromProduct:(MLEBProduct *)product {
    MLEBProduct *productMO = nil;
    if (targetCtx == product.managedObjectContext) {
        productMO = product;
        
    } else {
        productMO = [MLEBProduct MR_findFirstOrCreateByAttribute:@"title" withValue:product.title inContext:targetCtx];
        productMO.title = product.title;
        productMO.info = product.info;
        productMO.icons = product.icons;
        productMO.price = product.price;
        
        productMO.mlObject = product.mlObject;
    }
    
    return productMO;
}

- (NSString *)detailedStatusStringForOrder:(MLEBOrder *)order {
    NSString *string = nil;
    switch (order.orderStatus.integerValue) {
        case MLEBOrderStatusToBeDelivered: string = @"商品待发货"; break;
        case MLEBOrderStatusInDelivery: string = @"商品已发货"; break;
        case MLEBOrderStatusReceived: string = @"交易已完成"; break;
        case MLEBOrderStatusCommented: string = @"交易已完成"; break;
        case MLEBOrderStatusCancelledByUser: string = @"订单已取消"; break;
        case MLEBOrderStatusCancelledByMerchant: string = @"订单已取消"; break;
        default: string = @"订单处理中"; break;
    }
    return string;
}

#pragma mark - Private Methods
- (void)fetchUserIconWithCompletion:(void(^)(UIImage *image, NSError *error))completion {
    MLUser *mlUser = self.currentUser;
    MLFile *userIconFile = mlUser[@"iconFile"];
    DDLogInfo(@"before fetch - iconFile.url = %@", userIconFile.url);
    
    [userIconFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:imageData];
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                MLEBUser *user = [MLEBUser MR_findFirstInContext:localContext];
                user.iconImage = image;
                
                MLFile *file = mlUser[@"iconFile"];
                DDLogInfo(@"fetchUserIcon - imageData.length = %lu, iconFile.url = %@", (unsigned long)imageData.length, file.url);
                
            } completion:^(BOOL contextDidSave, NSError *error) {
                BLOCK_SAFE_ASY_RUN_MainQueue(completion, image, error);
            }];
            
        } else {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, error);
        }
    }];
}

- (void)uploadIconToMaxLeap:(UIImage *)image completion:(void(^)(BOOL succeeded, NSError *error))completion {
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    if (imageData.length > 1000) {
        imageData = UIImageJPEGRepresentation(image, 10.0/imageData.length);
    }
    MLFile *imageFile = [MLFile fileWithName:@"image.png" data:imageData];
    
    MLUser *mlUser = self.currentUser;
    mlUser[@"iconFile"] = imageFile;
    [mlUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        DDLogInfo(@"save file to MaxLeap - succeeded = %d, error = %@", succeeded, error);
        
        if (succeeded && !error) {
            MLEBUser *user = [MLEBUser MR_findFirstInContext:self.defaultContext];
            user.iconImage = image;
            
            [self.defaultContext MR_saveToPersistentStoreAndWait];
            
            [[NSFileManager defaultManager] removeItemAtPath:kLocalUserIconFilePath error:nil];
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, YES, nil);
            
        } else {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
        }
    }];
}

- (void)saveFavoriteProduct:(MLEBProduct *)productInScratchCtx completion:(void(^)(void))completion {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        MLEBProduct *productInDefaultCtx = [MLEBProduct MR_findFirstByAttribute:@"title" withValue:productInScratchCtx.title inContext:localContext];
        if (!productInDefaultCtx) {
            MLEBUser *userMO = [MLEBUser MR_findFirstInContext:localContext];
            productInDefaultCtx = [MLEBProduct MR_createEntityInContext:localContext];
            productInDefaultCtx.mlObject = productInScratchCtx.mlObject;
            
            productInDefaultCtx.title = productInScratchCtx.title;
            productInDefaultCtx.icons = productInScratchCtx.icons;
            productInDefaultCtx.intro = productInScratchCtx.intro;
            productInDefaultCtx.price = productInScratchCtx.price;
            
            [userMO addFavoritesObject:productInDefaultCtx];
        }
    } completion:^(BOOL contextDidSave, NSError *error) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion);
    }];
}

- (void)deleteFavoriteProduct:(MLEBProduct *)product completion:(void(^)(void))completion {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        MLEBProduct *productMO = [MLEBProduct MR_findFirstByAttribute:@"title" withValue:product.title inContext:localContext];
        if (productMO) {
            MLEBUser *userMO = [MLEBUser MR_findFirstInContext:localContext];
            
            [userMO removeFavoritesObject:productMO];
            [productMO MR_deleteEntityInContext:localContext];
        }
    } completion:^(BOOL contextDidSave, NSError *error) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion);
    }];
}

- (void)updateOrderStatus:(MLEBOrderStatus)status forOrder:(MLEBOrder *)order completion:(void(^)(BOOL succeeded, NSError *error))completion {
    order.mlObject[@"order_status"] = @(status);
    [order.mlObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            order.orderStatus = @(status);
        }
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, succeeded, error);
    }];
}

- (void)updateProductSalesCountForOrderItems:(NSOrderedSet *)orderItems {
    [orderItems enumerateObjectsUsingBlock:^(MLEBOrderItem * _Nonnull orderItem, NSUInteger idx, BOOL * _Nonnull stop) {
        MLEBProduct *product = orderItem.product;
        MLQuery *query = [MLQuery queryWithClassName:@"Product"];
        [query getObjectInBackgroundWithId:product.mlObjectId block:^(MLObject *productMLO, NSError *error) {
            NSUInteger salesCount = [productMLO[@"quantity"] integerValue];
            productMLO[@"quantity"] = @(salesCount + orderItem.quantity.integerValue);
            
            [productMLO saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                DDLogInfo(@"update product salesCount succeeded = %d, error = %@", succeeded, error);
            }];
        }];
    }];
}

- (void)addAddressesToMaxLeap:(NSArray *)addressesToAddToML completion:(void(^)(BOOL succeeded, NSError *error))completion {
    [MLObject saveAllInBackground:addressesToAddToML block:^(BOOL succeeded, NSError *error) {
        if (succeeded && !error) {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, YES, nil);

        } else {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
        }
    }];
}

- (void)deleteAddressesFromMaxLeap:(NSArray *)addressesToDeleteFromML completion:(void(^)(BOOL succeeded, NSError *error))completion {
    [MLObject deleteAllInBackground:addressesToDeleteFromML block:^(BOOL succeeded, NSError *error) {
        if (succeeded && !error) {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, YES, nil);
            
        } else {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
        }
    }];
}

- (NSArray *)addressMLOsToAddToMaxLeapBasedOnCurrentMLOs:(NSArray *)addressMLOs {
    NSMutableArray *addressesToAddToML = [NSMutableArray array];
    NSArray *localAddressMOs = [MLEBAddress MR_findAll];
    [localAddressMOs enumerateObjectsUsingBlock:^(MLEBAddress *  _Nonnull addressMO, NSUInteger idx, BOOL * _Nonnull stop) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(MLObject *evaluatedObject, NSDictionary<NSString *,id> * bindings) {
            return [evaluatedObject[@"street"] isEqualToString:addressMO.street] && [evaluatedObject[@"name"] isEqualToString:addressMO.name] && [evaluatedObject[@"tel"] isEqualToString:addressMO.tel];
        }];
        
        NSArray *filteredArray = [addressMLOs filteredArrayUsingPredicate:predicate];
        if (filteredArray.count == 0) {
            MLObject *addressMLO = [self addressMLOFromMLEBAddress:addressMO];
            [addressesToAddToML addObject:addressMLO];
        }
    }];
    return addressesToAddToML;
}

- (NSArray *)addressMLOsToDeleteFromMaxLeapBasedOnCurrentMLOs:(NSArray *)addressMLOs {
    NSMutableArray *addressesToDeleteFromML = [NSMutableArray array];
    NSArray *localAddressMOs = [MLEBAddress MR_findAll];
    [addressMLOs enumerateObjectsUsingBlock:^(MLObject *addressMLO, NSUInteger idx, BOOL * stop) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"street = %@ AND name = %@ AND tel = %@", addressMLO[@"street"], addressMLO[@"name"], addressMLO[@"tel"]];
        NSArray *filteredArray = [localAddressMOs filteredArrayUsingPredicate:predicate];
        if (filteredArray.count == 0) {
            [addressesToDeleteFromML addObject:addressMLO];
        }
    }];
    return addressesToDeleteFromML;
}

- (MLObject *)orderMLOFromMLEBOrder:(MLEBOrder *)order {
    MLObject *orderMLO = [MLObject objectWithClassName:@"Order"];
    orderMLO[@"total"] = order.totalPrice;
    
    orderMLO[@"receipt_heading"] = order.receipt.heading;
    orderMLO[@"receipt_content"] = order.receipt.content;
    orderMLO[@"receipt_type"] = order.receipt.type;
    
    orderMLO[@"remarks"] = order.remarks;
    orderMLO[@"pay_method"] = order.payMethod;
    orderMLO[@"delivery"] = order.deliveryMethod;
    orderMLO[@"order_status"] = order.orderStatus;
    
    orderMLO[@"address"] = order.address.mlObject;
    orderMLO[@"user"] = [kSharedWebService currentUser];
    
    return orderMLO;
}

- (MLObject *)orderItemMLOFromMLEBOrderItem:(MLEBOrderItem *)orderItem {
    MLObject *orderItemMLO = [MLObject objectWithClassName:@"OrderProduct"];
    orderItemMLO[@"price"] = orderItem.price;
    orderItemMLO[@"quantity"] = orderItem.quantity;
    orderItemMLO[@"selected_custom_info1"] = orderItem.selected_custom_info1;
    orderItemMLO[@"selected_custom_info2"] = orderItem.selected_custom_info2;
    orderItemMLO[@"selected_custom_info3"] = orderItem.selected_custom_info3;
    orderItemMLO[@"custom_infos"] = orderItem.custom_infos;
    
    orderItemMLO[@"product"] = orderItem.product.mlObject;
    return orderItemMLO;
}

- (MLObject *)addressMLOFromMLEBAddress:(MLEBAddress *)address {
    MLObject *addressMLO = [MLObject objectWithClassName:@"Address"];
    addressMLO[@"street"] = address.street;
    addressMLO[@"name"] = address.name;
    addressMLO[@"tel"] = address.tel;
    addressMLO[@"user"] = self.currentUser;
    return addressMLO;
}

- (NSString *)fullPathForImageWithName:(NSString *)imageName {
    NSString *path = [NSString stringWithFormat:@"Documents/%@.jpg", imageName];
    NSString *fullPath = [NSHomeDirectory() stringByAppendingPathComponent:path];
    return fullPath;
}

@end
