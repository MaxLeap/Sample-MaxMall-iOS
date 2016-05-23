//
//  MLEBOrderItem+CoreDataProperties.h
//  MaxLeapMall
//
//  Created by Michael on 11/18/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MLEBOrderItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLEBOrderItem (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *orderItemId;
@property (nullable, nonatomic, retain) NSDecimalNumber *price;
@property (nullable, nonatomic, retain) NSNumber *quantity;

@property (nullable, nonatomic, retain) NSString *custom_infos;
@property (nullable, nonatomic, retain) NSString *selected_custom_info1;
@property (nullable, nonatomic, retain) NSString *selected_custom_info2;
@property (nullable, nonatomic, retain) NSString *selected_custom_info3;

@property (nullable, nonatomic, retain) MLEBProduct *product;
@property (nullable, nonatomic, retain) MLEBOrder *order;

@end

NS_ASSUME_NONNULL_END
