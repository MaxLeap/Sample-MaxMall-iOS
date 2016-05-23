//
//  MLEBShoppingItem+CoreDataProperties.h
//  MaxLeapMall
//
//  Created by Michael on 11/20/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MLEBShoppingItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLEBShoppingItem (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSString *mlObjectId;
@property (nullable, nonatomic, retain) NSNumber *quantity;
@property (nullable, nonatomic, retain) NSString *selected_custom_info2;
@property (nullable, nonatomic, retain) NSString *selected_custom_info1;
@property (nullable, nonatomic, retain) NSString *selected_custom_info3;
@property (nullable, nonatomic, retain) NSString *custom_infos;

@property (nullable, nonatomic, retain) MLEBProduct *product;

@end

NS_ASSUME_NONNULL_END
