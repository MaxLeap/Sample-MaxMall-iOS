//
//  MLEBUser+CoreDataProperties.h
//  MaxLeapMall
//
//  Created by julie on 15/11/19.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MLEBUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLEBUser (CoreDataProperties)

@property (nullable, nonatomic, retain) id iconImage;
@property (nullable, nonatomic, retain) NSString *nickname;
@property (nullable, nonatomic, retain) NSString *tel;
@property (nullable, nonatomic, retain) NSOrderedSet<MLEBAddress *> *addresses;
@property (nullable, nonatomic, retain) NSOrderedSet<MLEBProduct *> *favorites;
@property (nullable, nonatomic, retain) NSOrderedSet<MLEBOrder *> *orders;
@property (nullable, nonatomic, retain) NSOrderedSet<MLEBShoppingItem *> *shoppingItems;

@end

@interface MLEBUser (CoreDataGeneratedAccessors)

- (void)insertObject:(MLEBAddress *)value inAddressesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAddressesAtIndex:(NSUInteger)idx;
- (void)insertAddresses:(NSArray<MLEBAddress *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAddressesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAddressesAtIndex:(NSUInteger)idx withObject:(MLEBAddress *)value;
- (void)replaceAddressesAtIndexes:(NSIndexSet *)indexes withAddresses:(NSArray<MLEBAddress *> *)values;
- (void)addAddressesObject:(MLEBAddress *)value;
- (void)removeAddressesObject:(MLEBAddress *)value;
- (void)addAddresses:(NSOrderedSet<MLEBAddress *> *)values;
- (void)removeAddresses:(NSOrderedSet<MLEBAddress *> *)values;

- (void)insertObject:(MLEBProduct *)value inFavoritesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFavoritesAtIndex:(NSUInteger)idx;
- (void)insertFavorites:(NSArray<MLEBProduct *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFavoritesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFavoritesAtIndex:(NSUInteger)idx withObject:(MLEBProduct *)value;
- (void)replaceFavoritesAtIndexes:(NSIndexSet *)indexes withFavorites:(NSArray<MLEBProduct *> *)values;
- (void)addFavoritesObject:(MLEBProduct *)value;
- (void)removeFavoritesObject:(MLEBProduct *)value;
- (void)addFavorites:(NSOrderedSet<MLEBProduct *> *)values;
- (void)removeFavorites:(NSOrderedSet<MLEBProduct *> *)values;

- (void)insertObject:(MLEBOrder *)value inOrdersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromOrdersAtIndex:(NSUInteger)idx;
- (void)insertOrders:(NSArray<MLEBOrder *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeOrdersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInOrdersAtIndex:(NSUInteger)idx withObject:(MLEBOrder *)value;
- (void)replaceOrdersAtIndexes:(NSIndexSet *)indexes withOrders:(NSArray<MLEBOrder *> *)values;
- (void)addOrdersObject:(MLEBOrder *)value;
- (void)removeOrdersObject:(MLEBOrder *)value;
- (void)addOrders:(NSOrderedSet<MLEBOrder *> *)values;
- (void)removeOrders:(NSOrderedSet<MLEBOrder *> *)values;

- (void)insertObject:(MLEBShoppingItem *)value inShoppingItemsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromShoppingItemsAtIndex:(NSUInteger)idx;
- (void)insertShoppingItems:(NSArray<MLEBShoppingItem *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeShoppingItemsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInShoppingItemsAtIndex:(NSUInteger)idx withObject:(MLEBShoppingItem *)value;
- (void)replaceShoppingItemsAtIndexes:(NSIndexSet *)indexes withShoppingItems:(NSArray<MLEBShoppingItem *> *)values;
- (void)addShoppingItemsObject:(MLEBShoppingItem *)value;
- (void)removeShoppingItemsObject:(MLEBShoppingItem *)value;
- (void)addShoppingItems:(NSOrderedSet<MLEBShoppingItem *> *)values;
- (void)removeShoppingItems:(NSOrderedSet<MLEBShoppingItem *> *)values;

@end

NS_ASSUME_NONNULL_END
