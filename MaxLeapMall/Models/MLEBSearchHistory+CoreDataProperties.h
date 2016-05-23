//
//  MLEBSearchHistory+CoreDataProperties.h
//  MaxLeapMall
//
//  Created by Michael on 11/17/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MLEBSearchHistory.h"

NS_ASSUME_NONNULL_BEGIN

@interface MLEBSearchHistory (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *keyword;
@property (nullable, nonatomic, retain) NSDate *searchTime;

@end

NS_ASSUME_NONNULL_END
