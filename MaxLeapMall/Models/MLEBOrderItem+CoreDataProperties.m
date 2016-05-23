//
//  MLEBOrderItem+CoreDataProperties.m
//  MaxLeapMall
//
//  Created by Michael on 11/18/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MLEBOrderItem+CoreDataProperties.h"

@implementation MLEBOrderItem (CoreDataProperties)

@dynamic orderItemId;
@dynamic price;
@dynamic quantity;

@dynamic custom_infos;
@dynamic selected_custom_info1;
@dynamic selected_custom_info2;
@dynamic selected_custom_info3;

@dynamic product;
@dynamic order;

@end
