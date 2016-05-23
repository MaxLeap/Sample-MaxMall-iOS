//
//  MLEBWebService+ShoppingCart.m
//  MaxLeapMall
//
//  Created by julie on 15/11/19.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBWebService+ShoppingCart.h"

@implementation MLEBWebService (ShoppingCart)
- (void)fetchShoppingItemsWithCompletion:(void (^)(NSArray *, NSError *))completion {
    if ( ! [self isLoggedIn]) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, nil);
        return;
    }
    
    MLQuery *query = [MLQuery queryWithClassName:@"ShoppingItem"];
    [query whereKey:@"user" equalTo:self.currentUser];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"product"];
    if (!query) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, nil);
        return;
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *shoppingItemMLOs, NSError *error) {
        if (!error) {
            [MLEBShoppingItem MR_truncateAll];
            [MLEBProduct MR_truncateAll];
            [self.defaultContext MR_saveToPersistentStoreAndWait];
            
            [shoppingItemMLOs enumerateObjectsUsingBlock:^(MLObject *  _Nonnull shoppingItemMLO, NSUInteger idx, BOOL * _Nonnull stop) {
                MLEBShoppingItem *shoppingItemInDefaultCtx = [self shoppingItemMOInContext:self.defaultContext fromShoppingItemMLO:shoppingItemMLO];
                MLObject *shoppingProductMLO = shoppingItemMLO[@"product"];
                MLEBProduct *shoppingProductInDefaultCtx = [self productMOInContext:self.defaultContext fromProductMLO:shoppingProductMLO];
                shoppingItemInDefaultCtx.product = shoppingProductInDefaultCtx;
                [self.defaultContext MR_saveToPersistentStoreAndWait];
            }];
#if DEBUG
            NSArray *items = [MLEBShoppingItem MR_findAllInContext:self.defaultContext];
            DDLogInfo(@"shopping-items.count = %lu", items.count);
#endif
     
            NSMutableArray *shoppingItemsInScratchCtx = [NSMutableArray array];
            [shoppingItemMLOs enumerateObjectsUsingBlock:^(MLObject *  _Nonnull shoppingItemMLO, NSUInteger idx, BOOL * _Nonnull stop) {
                MLEBShoppingItem *shoppingItemInScratchCtx = [self shoppingItemMOInContext:self.scratchContext fromShoppingItemMLO:shoppingItemMLO];
                MLObject *shoppingProductMLO = shoppingItemMLO[@"product"];
                MLEBProduct *shoppingProductInScratchCtx = [self productMOInContext:self.scratchContext fromProductMLO:shoppingProductMLO];
                shoppingItemInScratchCtx.product = shoppingProductInScratchCtx;
                
                [shoppingItemsInScratchCtx addObject:shoppingItemInScratchCtx];
            }];

            BLOCK_SAFE_ASY_RUN_MainQueue(completion, [shoppingItemsInScratchCtx copy], error);
            
        } else {
            
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, error);
        }
    }];
}

- (void)addOrUpdateShoppingItem:(MLEBShoppingItem *)shoppingItem completion:(void(^)(BOOL succeeded, NSError *error))completion {
    if ( ! [self isLoggedIn]) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, nil);
        return;
    }

    MLQuery *query = [MLQuery queryWithClassName:@"ShoppingItem"];
    [query whereKey:@"user" equalTo:self.currentUser];
    [query includeKey:@"product"];
    if (shoppingItem.mlObjectId) {
        [query getObjectInBackgroundWithId:shoppingItem.mlObjectId block:^(MLObject *shoppingItemMLO, NSError *error) {
            if (shoppingItemMLO && !error) {
                shoppingItemMLO[@"quantity"] = shoppingItem.quantity;
                [shoppingItemMLO saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    DDLogInfo(@"saved-- shoppingItemMLO.objectId = %@", shoppingItemMLO.objectId);

                    BLOCK_SAFE_ASY_RUN_MainQueue(completion, succeeded, error);
                }];
            } else {
                BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
            }
        }];
        
    } else {
        MLQuery *productQuery = [MLQuery queryWithClassName:@"Product"];
        DDLogInfo(@"item.product.id = %@", shoppingItem.product.mlObjectId);
        [productQuery getObjectInBackgroundWithId:shoppingItem.product.mlObjectId block:^(MLObject *productMLO, NSError *error) {
            if (productMLO && !error) {
                MLObject *shoppingItemMLO = [self shoppingItemMLOFromShoppingItemMO:shoppingItem];

                shoppingItemMLO[@"product"] = productMLO;
                [shoppingItemMLO saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    DDLogInfo(@"saved-- shoppingItemMLO.objectId = %@", shoppingItemMLO.objectId);
                    shoppingItem.mlObjectId = shoppingItemMLO.objectId;
                    [self.defaultContext MR_saveToPersistentStoreAndWait];
                    
                    BLOCK_SAFE_ASY_RUN_MainQueue(completion, succeeded, error);
                }];
                
            } else {
                BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
            }
        }];
    }
}

- (void)deleteShoppingItem:(MLEBShoppingItem *)shoppingItem completion:(void(^)(BOOL succeeded, NSError *error))completion {
    if (! [self isLoggedIn]) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, nil);
        return;
    }
    
    MLQuery *query = [MLQuery queryWithClassName:@"ShoppingItem"];
    [query whereKey:@"user" equalTo:self.currentUser];
    if (shoppingItem.mlObjectId) {
        [query getObjectInBackgroundWithId:shoppingItem.mlObjectId block:^(MLObject *shoppingItemMLO, NSError *error) {
            if (shoppingItemMLO && !error) {
                [shoppingItemMLO deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    BLOCK_SAFE_ASY_RUN_MainQueue(completion, succeeded, error);
                }];
                
            } else {
                BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
            }
        }];
        
    } else {
        
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, nil);
    }
}

- (void)syncShoppingItemsToMaxLeapWithCompletion:(void(^)(BOOL succeeded, NSError *error))completion {
    if (! [self isLoggedIn]) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, nil);
        return;
    }
    
    MLQuery *query = [MLQuery queryWithClassName:@"ShoppingItem"];
    [query whereKey:@"user" equalTo:self.currentUser];
    [query includeKey:@"product"];
    if (!query) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, nil);
        return;
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *shoppingItemMLOs, NSError *error) {
        if (error) {
            BLOCK_SAFE_ASY_RUN_MainQueue(completion, NO, error);
            
        } else {
            
            NSArray *shoppingItemsToAddToML = [self shoppingItemMLOsToAddToMaxLeapBasedOnCurrentMLOs:shoppingItemMLOs];
            NSArray *shoppingItemsToDeleteFromML = [self shoppingItemMLOsToDeleteFromMaxLeapBasedOnCurrentMLOs:shoppingItemMLOs];
            
            [MLObject saveAllInBackground:shoppingItemsToAddToML block:^(BOOL succeeded, NSError *error) {
                if (succeeded && !error) {
                    [MLObject deleteAllInBackground:shoppingItemsToDeleteFromML block:^(BOOL succeeded, NSError *error) {
                        BLOCK_SAFE_ASY_RUN_MainQueue(completion, succeeded, error);
                    }];
                } else {
                    BLOCK_SAFE_ASY_RUN_MainQueue(completion, succeeded, error);
                }
            }];
        }
    }];
}

#pragma mark - Private Methods
- (NSArray *)shoppingItemMLOsToAddToMaxLeapBasedOnCurrentMLOs:(NSArray *)shoppingItemMLOs {
    NSMutableArray *shoppingItemsToAddToML = [NSMutableArray array];
    NSArray *shoppingItemMOs = [MLEBShoppingItem MR_findAllInContext:self.defaultContext];
    [shoppingItemMOs enumerateObjectsUsingBlock:^(MLEBShoppingItem *  _Nonnull shoppingItemMO, NSUInteger idx, BOOL * _Nonnull stop) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(MLObject *evaluatedObject, NSDictionary<NSString *,id> * bindings) {
            MLObject *productMLO = evaluatedObject[@"product"];
            BOOL isProductMatched = [productMLO[@"title"] isEqualToString:shoppingItemMO.product.title] && [productMLO[@"intro"] isEqualToString:shoppingItemMO.product.intro];
            
            return isProductMatched && ([evaluatedObject[@"quantity"] integerValue] == shoppingItemMO.quantity.integerValue);
        }];
        
        NSArray *filteredArray = [shoppingItemMLOs filteredArrayUsingPredicate:predicate];
        if (filteredArray.count == 0) {
            MLObject *shoppingItemMLO = [self shoppingItemMLOFromShoppingItemMO:shoppingItemMO];
            [shoppingItemsToAddToML addObject:shoppingItemMLO];
        }
    }];
    return shoppingItemsToAddToML;
}

- (NSArray *)shoppingItemMLOsToDeleteFromMaxLeapBasedOnCurrentMLOs:(NSArray *)shopingItemMLOs {
    NSMutableArray *shopingItemsToDeleteFromMaxLeap = [NSMutableArray array];
    NSArray *localShoppingItemMOs = [MLEBShoppingItem MR_findAll];
    [shopingItemMLOs enumerateObjectsUsingBlock:^(MLObject *shoppingItemMLO, NSUInteger idx, BOOL * stop) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(MLEBShoppingItem *evaluatedObject, NSDictionary<NSString *,id> * bindings) {
            MLObject *productMLO = shoppingItemMLO[@"product"];
            BOOL isProductMatched = [productMLO[@"title"] isEqualToString:evaluatedObject.product.title] && [productMLO[@"intro"] isEqualToString:evaluatedObject.product.intro];
            return isProductMatched && ([shoppingItemMLO[@"quantity"] integerValue] == evaluatedObject.quantity.integerValue);
        }];
        NSArray *filteredArray = [localShoppingItemMOs filteredArrayUsingPredicate:predicate];
        if (filteredArray.count == 0) {
            [shopingItemsToDeleteFromMaxLeap addObject:shoppingItemMLO];
        }
    }];
    return shopingItemsToDeleteFromMaxLeap;
}

#pragma mark - Helper Methods
- (MLEBProduct*)productMOInContext:(NSManagedObjectContext *)context fromProductMLO:(MLObject *)productMLO {
    NSString *title = productMLO[@"title"];
    MLEBProduct *productMO = [MLEBProduct MR_findFirstOrCreateByAttribute:@"title" withValue:title inContext:context];
    productMO.mlObjectId = productMLO.objectId;
    productMO.title = title;
    productMO.price = [NSDecimalNumber decimalNumberWithDecimal:[productMLO[@"price"] decimalValue]];
    productMO.originalPrice = [NSDecimalNumber decimalNumberWithDecimal:[productMLO[@"original_price"] decimalValue]];
    productMO.intro = productMLO[@"intro"];
    
    NSArray *icons = productMLO[@"icons"];
    productMO.icons = icons;
    productMO.services = productMLO[@"services"];
    productMO.info = productMLO[@"info"];
    productMO.custom_info1 = productMLO[@"custom_info1"];
    productMO.custom_info2 = productMLO[@"custom_info2"];
    productMO.custom_info3 = productMLO[@"custom_info3"];
    
    productMO.mlObject = productMLO;
    
    return productMO;
}

- (MLEBShoppingItem *)shoppingItemMOInContext:(NSManagedObjectContext *)context fromShoppingItemMLO:(MLObject *)shoppingItemMLO {
    MLEBShoppingItem *shoppingItem = nil;
    NSArray *shoppintItems = [MLEBShoppingItem MR_findAllInContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mlObjectId = %@", shoppingItemMLO.objectId];
    NSArray *filtedShoppingItems = [shoppintItems filteredArrayUsingPredicate:predicate];
    if ([filtedShoppingItems count] > 0) {
        shoppingItem = [filtedShoppingItems firstObject];
    } else {
        shoppingItem = [MLEBShoppingItem MR_createEntityInContext:context];
    }
    shoppingItem.quantity = shoppingItemMLO[@"quantity"];
    shoppingItem.selected_custom_info1 = shoppingItemMLO[@"selected_custom_info1"];
    shoppingItem.selected_custom_info2 = shoppingItemMLO[@"selected_custom_info2"];
    shoppingItem.selected_custom_info3 = shoppingItemMLO[@"selected_custom_info3"];
    shoppingItem.custom_infos = shoppingItemMLO[@"custom_infos"];
    shoppingItem.mlObjectId = shoppingItemMLO.objectId;
    
    shoppingItem.mlObject = shoppingItemMLO;
    
    return shoppingItem;
}

- (MLObject *)shoppingItemMLOFromShoppingItemMO:(MLEBShoppingItem *)shoppingItem {
    MLObject *shoppingItemMLO = [MLObject objectWithClassName:@"ShoppingItem"];
    shoppingItemMLO[@"user"] = self.currentUser;
    shoppingItemMLO[@"quantity"] = shoppingItem.quantity;
    shoppingItemMLO[@"product"] = shoppingItem.product.mlObject;
    shoppingItemMLO[@"selected_custom_info1"] = shoppingItem.selected_custom_info1;
    shoppingItemMLO[@"selected_custom_info2"] = shoppingItem.selected_custom_info2;
    shoppingItemMLO[@"selected_custom_info3"] = shoppingItem.selected_custom_info3;
    shoppingItemMLO[@"custom_infos"] = shoppingItem.custom_infos;
    return shoppingItemMLO;
}

@end
