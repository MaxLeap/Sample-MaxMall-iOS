//
//  MLEBShoppingItem+Helper.m
//  MaxLeapMall
//
//  Created by Michael on 11/23/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import "MLEBShoppingItem+Helper.h"

@implementation MLEBShoppingItem (Helper)

+ (MLEBShoppingItem *)cloneShoppingItemToDefaultContext:(MLEBShoppingItem *)shoppingItem {
    MLEBShoppingItem *shoppingitemInDefaultContext = [MLEBShoppingItem MR_createEntity];
    shoppingitemInDefaultContext.mlObjectId = shoppingItem.mlObjectId;
    shoppingitemInDefaultContext.quantity = [shoppingItem.quantity copy];
    shoppingitemInDefaultContext.selected_custom_info1 = shoppingItem.selected_custom_info1;
    shoppingitemInDefaultContext.selected_custom_info2 = shoppingItem.selected_custom_info2;
    shoppingitemInDefaultContext.selected_custom_info3 = shoppingItem.selected_custom_info3;
    shoppingitemInDefaultContext.custom_infos = shoppingItem.custom_infos;
    
    NSLog(@"%@", shoppingItem.product);
    shoppingitemInDefaultContext.product = [MLEBProduct cloneProductToDefaultContext:shoppingItem.product];
    
    return shoppingitemInDefaultContext;
}

+ (MLEBShoppingItem *)cloneShoppingItem:(MLEBShoppingItem *)shoppingItem toContext:(NSManagedObjectContext *)context {
    MLEBShoppingItem *shoppingitemInNewContext = [MLEBShoppingItem MR_createEntityInContext:context];
    shoppingitemInNewContext.mlObjectId = shoppingItem.mlObjectId;
    shoppingitemInNewContext.quantity = [shoppingItem.quantity copy];
    shoppingitemInNewContext.selected_custom_info1 = shoppingItem.selected_custom_info1;
    shoppingitemInNewContext.selected_custom_info2 = shoppingItem.selected_custom_info2;
    shoppingitemInNewContext.selected_custom_info3 = shoppingItem.selected_custom_info3;
    shoppingitemInNewContext.custom_infos = shoppingItem.custom_infos;
    shoppingitemInNewContext.product = [MLEBProduct cloneProduct:shoppingItem.product toContext:context];
    
    return shoppingitemInNewContext;
}

@end
