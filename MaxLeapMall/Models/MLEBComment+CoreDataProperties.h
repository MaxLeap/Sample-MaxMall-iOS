//
//  MLEBComment+CoreDataProperties.h
//  MaxLeapMall
//
//  Created by Michael on 11/17/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MLEBComment.h"
#import "MLEBUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLEBComment (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *content;
@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSNumber *score;
@property (nullable, nonatomic, retain) MLEBProduct *product;
@property (nullable, nonatomic, retain) MLEBUser *user;

@end

NS_ASSUME_NONNULL_END
