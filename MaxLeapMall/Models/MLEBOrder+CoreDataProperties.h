//
//  MLEBOrder+CoreDataProperties.h
//  MaxLeapMall
//
//  Created by Michael on 11/18/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MLEBOrder.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLEBOrder (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSString *deliveryMethod;
@property (nullable, nonatomic, retain) NSString *orderId;
@property (nullable, nonatomic, retain) NSNumber *orderStatus;
@property (nullable, nonatomic, retain) NSString *payMethod;
@property (nullable, nonatomic, retain) NSString *remarks;
@property (nullable, nonatomic, retain) NSDecimalNumber *totalPrice;
@property (nullable, nonatomic, retain) NSDate *updatedAt;
@property (nullable, nonatomic, retain) MLEBAddress *address;
@property (nullable, nonatomic, retain) NSOrderedSet<MLEBOrderItem *> *orderItems;
@property (nullable, nonatomic, retain) MLEBReceipt *receipt;
@property (nullable, nonatomic, retain) MLEBUser *user;

@end

@interface MLEBOrder (CoreDataGeneratedAccessors)

- (void)insertObject:(MLEBOrderItem *)value inOrderItemsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromOrderItemsAtIndex:(NSUInteger)idx;
- (void)insertOrderItems:(NSArray<MLEBOrderItem *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeOrderItemsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInOrderItemsAtIndex:(NSUInteger)idx withObject:(MLEBOrderItem *)value;
- (void)replaceOrderItemsAtIndexes:(NSIndexSet *)indexes withOrderItems:(NSArray<MLEBOrderItem *> *)values;
- (void)addOrderItemsObject:(MLEBOrderItem *)value;
- (void)removeOrderItemsObject:(MLEBOrderItem *)value;
- (void)addOrderItems:(NSOrderedSet<MLEBOrderItem *> *)values;
- (void)removeOrderItems:(NSOrderedSet<MLEBOrderItem *> *)values;

@end

NS_ASSUME_NONNULL_END
