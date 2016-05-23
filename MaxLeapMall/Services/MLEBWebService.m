//
//  MLFDWebService.m
//  MaxLeapFood
//
//  Created by Michael on 11/2/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import "MLEBWebService.h"

@implementation MLEBWebService
+ (MLEBWebService *)sharedInstance {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [MLEBWebService new];
    });
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _defaultContext = [NSManagedObjectContext MR_defaultContext];
    _scratchContext = [NSManagedObjectContext MR_newMainQueueContext];
    [_scratchContext setPersistentStoreCoordinator:[NSPersistentStoreCoordinator MR_defaultStoreCoordinator]];

    return self;
}

#pragma mark - Helper Method
- (MLEBProduct*)productMOFromProductMLO:(MLObject *)productMLO {
    NSString *title = productMLO[@"title"];
    MLEBProduct *productMO = [MLEBProduct MR_findFirstOrCreateByAttribute:@"title" withValue:title inContext:self.scratchContext];
    productMO.mlObjectId = productMLO.objectId;
    productMO.title = title;
    productMO.mlObject = productMLO;
    productMO.price = [NSDecimalNumber decimalNumberWithDecimal:[productMLO[@"price"] decimalValue]];
    productMO.originalPrice = [NSDecimalNumber decimalNumberWithDecimal:[productMLO[@"original_price"] decimalValue]];
    productMO.intro = productMLO[@"intro"];
    
    NSArray *icons = productMLO[@"icons"];
    productMO.icons = icons;
    productMO.services = productMLO[@"services"];
    productMO.info = productMLO[@"info"];
    productMO.custom_info1 = productMLO[@"custom_info1"];
    productMO.custom_info2 = productMLO[@"custom_info2"];
    productMO.custom_info3 = productMLO[@"custom_info3"];
    
    return productMO;
}

@end
