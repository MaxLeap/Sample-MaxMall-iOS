//
//  MLEBProduct+Helper.m
//  MaxLeapMall
//
//  Created by Michael on 11/19/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import "MLEBProduct+Helper.h"

@implementation MLEBProduct (Helper)
+ (MLEBProduct *)cloneProduct:(MLEBProduct *)product toContext:(NSManagedObjectContext *)context {
    if (product.managedObjectContext == context) {
        return product;
    }
    
    MLEBProduct *productInNewContext = [MLEBProduct MR_findFirstOrCreateByAttribute:@"title" withValue:product.title inContext:context];
    productInNewContext.services = [product.services copy];
    productInNewContext.price = product.price;
    productInNewContext.originalPrice = product.originalPrice;
    productInNewContext.intro = product.intro;
    productInNewContext.icons = [product.icons copy];
    productInNewContext.detail = product.detail;
    productInNewContext.custom_info1 = [product.custom_info1 copy];
    productInNewContext.custom_info2 = [product.custom_info2 copy];
    productInNewContext.custom_info3 = [product.custom_info3 copy];
    productInNewContext.mlObjectId = product.mlObjectId;
    
    return productInNewContext;
}

+ (MLEBProduct *)cloneProductToDefaultContext:(MLEBProduct *)product {
    MLEBProduct *productInDefaultContext = [MLEBProduct MR_findFirstOrCreateByAttribute:@"title" withValue:product.title];
    productInDefaultContext.services = [product.services copy];
    productInDefaultContext.price = product.price;
    productInDefaultContext.originalPrice = product.originalPrice;
    productInDefaultContext.intro = product.intro;
    productInDefaultContext.icons = [product.icons copy];
    productInDefaultContext.detail = product.detail;
    productInDefaultContext.custom_info1 = [product.custom_info1 copy];
    productInDefaultContext.custom_info2 = [product.custom_info2 copy];
    productInDefaultContext.custom_info3 = [product.custom_info3 copy];
    productInDefaultContext.mlObjectId = product.mlObjectId;
    
    return productInDefaultContext;
}

- (NSDictionary *)customInfo1Dic {
    if (self.custom_info1.length > 0) {
        NSError *jsonError;
        NSData *objectData = [self.custom_info1 dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        if (!jsonError) {
            return json;
        }
    }
    
    return nil;
}

- (NSDictionary *)customInfo2Dic {
    if (self.custom_info2.length > 0) {
        NSError *jsonError;
        NSData *objectData = [self.custom_info2 dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        if (!jsonError) {
            return json;
        }
    }
    
    return nil;
}

- (NSDictionary *)customInfo3Dic {
    if (self.custom_info3.length > 0) {
        NSError *jsonError;
        NSData *objectData = [self.custom_info3 dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        if (!jsonError) {
            return json;
        }
    }
    
    return nil;
}

- (NSString *)customInfo1Name {
    NSDictionary *json = [self customInfo1Dic];
    if (json.allKeys.count > 0) {
        return json.allKeys[0];
    }
    
    return nil;
}

- (NSArray *)customInfo1Items {
    NSDictionary *dic = [self customInfo1Dic];
    NSString *key = [self customInfo1Name];
    if (key.length > 0) {
        return dic[key];
    }
    
    return nil;
}

- (NSString *)customInfo2Name {
    NSDictionary *json = [self customInfo2Dic];
    if (json.allKeys.count > 0) {
        return json.allKeys[0];
    }
    
    return nil;
}

- (NSArray *)customInfo2Items {
    NSDictionary *dic = [self customInfo2Dic];
    NSString *key = [self customInfo2Name];
    if (key.length > 0) {
        return dic[key];
    }
    
    return nil;
}

- (NSString *)customInfo3Name {
    NSDictionary *json = [self customInfo3Dic];
    if (json.allKeys.count > 0) {
        return json.allKeys[0];
    }
    
    return nil;
}

- (NSArray *)customInfo3Items {
    NSDictionary *dic = [self customInfo3Dic];
    NSString *key = [self customInfo3Name];
    if (key.length > 0) {
        return dic[key];
    }
    
    return nil;
}

@end
