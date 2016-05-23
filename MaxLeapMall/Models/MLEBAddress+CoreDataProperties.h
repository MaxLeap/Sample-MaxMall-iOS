//
//  MLEBAddress+CoreDataProperties.h
//  MaxLeapMall
//
//  Created by Michael on 11/17/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MLEBAddress.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLEBAddress (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *street;
@property (nullable, nonatomic, retain) NSString *tel;
@property (nullable, nonatomic, retain) NSManagedObject *user;

@end

NS_ASSUME_NONNULL_END
