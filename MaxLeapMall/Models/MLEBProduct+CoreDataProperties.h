//
//  MLEBProduct+CoreDataProperties.h
//  MaxLeapMall
//
//  Created by Michael on 11/17/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MLEBProduct.h"
#import "MLEBProductCategory.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLEBProduct (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *mlObjectId;
@property (nullable, nonatomic, retain) NSString *custom_info1;
@property (nullable, nonatomic, retain) NSString *custom_info2;
@property (nullable, nonatomic, retain) NSString *custom_info3;
@property (nullable, nonatomic, retain) NSString *detail;
@property (nullable, nonatomic, retain) NSArray *icons;
@property (nullable, nonatomic, retain) NSString *info;
@property (nullable, nonatomic, retain) NSString *intro;
@property (nullable, nonatomic, retain) NSDecimalNumber *originalPrice;
@property (nullable, nonatomic, retain) NSDecimalNumber *price;
@property (nullable, nonatomic, retain) NSArray *services;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) MLEBProductCategory *category; // NOT cloneable
@property (nullable, nonatomic, retain) NSOrderedSet<NSManagedObject *> *comments; // NOT cloneable
@property (nullable, nonatomic, retain) NSNumber *commentCount;

@end

@interface MLEBProduct (CoreDataGeneratedAccessors)

- (void)insertObject:(NSManagedObject *)value inCommentsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCommentsAtIndex:(NSUInteger)idx;
- (void)insertComments:(NSArray<NSManagedObject *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCommentsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCommentsAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceCommentsAtIndexes:(NSIndexSet *)indexes withComments:(NSArray<NSManagedObject *> *)values;
- (void)addCommentsObject:(NSManagedObject *)value;
- (void)removeCommentsObject:(NSManagedObject *)value;
- (void)addComments:(NSOrderedSet<NSManagedObject *> *)values;
- (void)removeComments:(NSOrderedSet<NSManagedObject *> *)values;

@end

NS_ASSUME_NONNULL_END
