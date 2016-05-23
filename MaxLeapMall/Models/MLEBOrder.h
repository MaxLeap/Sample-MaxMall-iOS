//
//  MLEBOrder.h
//  MaxLeapMall
//
//  Created by Michael on 11/18/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MLEBAddress, MLEBOrderItem, MLEBReceipt, MLEBUser;

NS_ASSUME_NONNULL_BEGIN

@interface MLEBOrder : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "MLEBOrder+CoreDataProperties.h"
