//
//  MLEBShoppingItem+Helper.h
//  MaxLeapMall
//
//  Created by Michael on 11/23/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import "MLEBShoppingItem.h"

@interface MLEBShoppingItem (Helper)
+ (MLEBShoppingItem *)cloneShoppingItemToDefaultContext:(MLEBShoppingItem *)shoppingItem;

+ (MLEBShoppingItem *)cloneShoppingItem:(MLEBShoppingItem *)shoppingItem toContext:(NSManagedObjectContext *)context;
@end
