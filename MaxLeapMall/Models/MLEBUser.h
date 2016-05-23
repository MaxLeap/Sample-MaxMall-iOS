//
//  MLEBUser.h
//  MaxLeapMall
//
//  Created by julie on 15/11/19.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kSharedUser [MLEBUser currentUser]
@class MLEBAddress, MLEBOrder, MLEBProduct, MLEBShoppingItem;

NS_ASSUME_NONNULL_BEGIN

@interface MLEBUser : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+ (MLEBUser *)currentUser;
@end

NS_ASSUME_NONNULL_END

#import "MLEBUser+CoreDataProperties.h"
