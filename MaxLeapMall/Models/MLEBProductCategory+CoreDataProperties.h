//
//  MLEBProductCategory+CoreDataProperties.h
//  MaxLeapMall
//
//  Created by Michael on 11/18/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MLEBProductCategory.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLEBProductCategory (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *iconUrlString;
@property (nullable, nonatomic, retain) NSNumber *isOnSales;
@property (nullable, nonatomic, retain) NSNumber *recommend;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSOrderedSet<MLEBProduct *> *products;

@end

@interface MLEBProductCategory (CoreDataGeneratedAccessors)

- (void)insertObject:(MLEBProduct *)value inProductsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromProductsAtIndex:(NSUInteger)idx;
- (void)insertProducts:(NSArray<MLEBProduct *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeProductsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInProductsAtIndex:(NSUInteger)idx withObject:(MLEBProduct *)value;
- (void)replaceProductsAtIndexes:(NSIndexSet *)indexes withProducts:(NSArray<MLEBProduct *> *)values;
- (void)addProductsObject:(MLEBProduct *)value;
- (void)removeProductsObject:(MLEBProduct *)value;
- (void)addProducts:(NSOrderedSet<MLEBProduct *> *)values;
- (void)removeProducts:(NSOrderedSet<MLEBProduct *> *)values;

@end

NS_ASSUME_NONNULL_END
