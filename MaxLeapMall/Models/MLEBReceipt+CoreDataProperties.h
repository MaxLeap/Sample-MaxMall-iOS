//
//  MLEBReceipt+CoreDataProperties.h
//  MaxLeapMall
//
//  Created by Michael on 11/17/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MLEBReceipt.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLEBReceipt (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSString *heading;
@property (nullable, nonatomic, retain) NSString *content;

@end

NS_ASSUME_NONNULL_END
