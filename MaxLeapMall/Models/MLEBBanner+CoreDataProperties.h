//
//  MLEBBanner+CoreDataProperties.h
//  MaxLeapMall
//
//  Created by Michael on 11/17/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MLEBBanner.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLEBBanner (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *priority;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSString *urlString;
@property (nullable, nonatomic, retain) MLEBProduct *product;

@end

NS_ASSUME_NONNULL_END
