//
//  MLEBWebService+HomePage.m
//  MaxLeapMall
//
//  Created by Michael on 11/26/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import "MLEBWebService+HomePage.h"

@implementation MLEBWebService (HomePage)
- (void)fetchBannersCompletion:(void(^)(NSArray *banners, NSError *error))completion {
    MLQuery *query = [MLQuery queryWithClassName:@"Banner"];
    [query includeKey:@"product"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *bannerMLOs, NSError *error) {
        NSMutableArray *bannerMOs = [NSMutableArray new];
        [bannerMLOs enumerateObjectsUsingBlock:^(MLObject *obj, NSUInteger idx, BOOL * stop) {
            NSString *imageURLString = obj[@"url"];
            NSNumber *status = obj[@"status"];
            NSNumber *priority = obj[@"priority"];
            MLObject *productMLO = obj[@"product"];
            MLEBProduct *oneProductMO = [self productMOFromProductMLO:productMLO];
            
            MLEBBanner *oneBannerMO = [MLEBBanner MR_findFirstOrCreateByAttribute:@"urlString" withValue:imageURLString inContext:self.scratchContext];
            oneBannerMO.urlString = imageURLString;
            oneBannerMO.status = status;
            oneBannerMO.priority = priority;
            oneBannerMO.product = oneProductMO;
            
            [bannerMOs addObject:oneBannerMO];
        }];
        
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, bannerMOs, error);
    }];
}

- (void)fetchProductCategoryCompletion:(void(^)(NSArray *productCategorys, NSError *error))completion {
    MLQuery *query = [MLQuery queryWithClassName:@"ProductType"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *merchantTypeMLOs, NSError *error) {
        NSMutableArray *productCategorys = [NSMutableArray new];
        [merchantTypeMLOs enumerateObjectsUsingBlock:^(MLObject *oneProductTypeMLO, NSUInteger idx, BOOL * _Nonnull stop) {
            MLFile *iconFile = oneProductTypeMLO[@"iconFile"];
            NSString *title = oneProductTypeMLO[@"title"];
            MLEBProductCategory *oneProductCategoryMO = [MLEBProductCategory MR_findFirstOrCreateByAttribute:@"title" withValue:title inContext:self.scratchContext];
            oneProductCategoryMO.iconUrlString = iconFile.url;
            oneProductCategoryMO.title = title;
            oneProductCategoryMO.mlObject = oneProductTypeMLO;
            [productCategorys addObject:oneProductCategoryMO];
        }];
        
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, productCategorys, error);
    }];
}

- (void)fetchProductsFromPage:(NSUInteger)page completion:(void(^)(NSArray *merchaints, BOOL isReachEnd, NSError *error))completion {
    MLQuery *query = [MLQuery queryWithClassName:@"Product"];
    query.skip = page * kPerPage;
    query.limit = kPerPage;
    [query findObjectsInBackgroundWithBlock:^(NSArray *productMLOs, NSError *error) {
        NSMutableArray *productMOs = [NSMutableArray new];
        [productMLOs enumerateObjectsUsingBlock:^(MLObject *oneProductMLO, NSUInteger idx, BOOL * _Nonnull stop) {
            MLEBProduct *oneProductMO = [self productMOFromProductMLO:oneProductMLO];
            [productMOs addObject:oneProductMO];
        }];
        
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, productMOs, productMOs.count < kPerPage, error);
    }];
}

- (void)fetchProductWithProductCategory:(MLEBProductCategory *)productCategory
                               fromPage:(NSUInteger)page
                             completion:(void(^)(NSArray *products, BOOL isReacheEnd, NSError *error))completion {
    MLRelation *relation = [productCategory.mlObject relationForKey:@"products"];
    MLQuery *productsQuery = relation.query;
    if (!productsQuery) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, NO, nil);
        return;
    }
    
    productsQuery.skip = page * kPerPage;
    productsQuery.limit = kPerPage;
    
    [productsQuery findObjectsInBackgroundWithBlock:^(NSArray *allProductMLOs, NSError *error) {
        NSMutableArray *oneBatchProduct = [NSMutableArray new];
        [allProductMLOs enumerateObjectsUsingBlock:^(MLObject *oneProductMLO, NSUInteger idx, BOOL * _Nonnull stop) {
            MLEBProduct *oneProductMO = [self productMOFromProductMLO:oneProductMLO];
            [oneBatchProduct addObject:oneProductMO];
        }];
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, oneBatchProduct, oneBatchProduct.count < kPerPage, error);
    }];
}

- (void)fetchProductWithProductName:(NSString *)productName
                           fromPage:(NSUInteger)page
                         primaryKey:(NSString *)primaryKey
                    primaryKeyOrder:(NSComparisonResult)primaryKeyOrder
                       secondaryKey:(NSString *)secondaryKey
                  secondaryKeyOrder:(NSComparisonResult)secondaryKeyOrder
                         completion:(void(^)(NSArray *products, BOOL isReacheEnd, NSError *error))completion {
    MLQuery *productsQuery = [MLQuery queryWithClassName:@"Product"];
    [productsQuery whereKey:@"title" containsString:productName];
    if (!productsQuery) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, NO, nil);
        return;
    }
    productsQuery.skip = page * kPerPage;
    productsQuery.limit = kPerPage;
    
    if (primaryKeyOrder == NSOrderedDescending) {
        [productsQuery addDescendingOrder:primaryKey];
    } else {
        [productsQuery addAscendingOrder:primaryKey];
    }
    
    if (secondaryKeyOrder == NSOrderedDescending) {
        [productsQuery addDescendingOrder:secondaryKey];
    } else {
        [productsQuery addAscendingOrder:secondaryKey];
    }
    
    [productsQuery findObjectsInBackgroundWithBlock:^(NSArray *productMLOs, NSError *error) {
        NSMutableArray *productMOs = [NSMutableArray new];
        [productMLOs enumerateObjectsUsingBlock:^(MLObject *oneProductMLO, NSUInteger idx, BOOL * _Nonnull stop) {
            MLEBProduct *oneProductMO = [self productMOFromProductMLO:oneProductMLO];
            [productMOs addObject:oneProductMO];
        }];
        
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, productMOs, productMOs.count < kPerPage, error);
    }];
}

- (void)fetchProductCommentWithType:(MLEBCommentType)commentType
                            product:(MLEBProduct *)product
                           fromPage:(NSUInteger)page
                         completion:(void(^)(NSArray *comments, BOOL isReachEnd, NSError *error))completion {
    if (!product.mlObject) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, nil, YES, nil);
        return;
    }
    
    NSMutableArray *allComments = [NSMutableArray new];
    
    MLQuery *query = [MLQuery queryWithClassName:@"Comment"];
    query.skip = page * kPerPage;
    query.limit = kPerPage;
    [query whereKey:@"product" equalTo:product.mlObject];
    if (commentType == MLEBCommentTypePraises) {
        [query whereKey:@"score" greaterThanOrEqualTo:@(4)];
    }
    
    if (commentType == MLEBCommentTypeAssessments) {
        [query whereKey:@"score" equalTo:@(3)];
    }
    
    if (commentType == MLEBCommentTypeBadReviews) {
        [query whereKey:@"score" lessThan:@(3)];
    }
    
    [query includeKey:@"product"];
    [query includeKey:@"user"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *commentMLOs, NSError *error) {
        [commentMLOs enumerateObjectsUsingBlock:^(MLObject *oneCommentMLO, NSUInteger idx, BOOL * _Nonnull stop) {
            NSNumber *score = oneCommentMLO[@"score"];
            NSString *content = oneCommentMLO[@"content"];
            MLEBComment *oneCommentMO = [MLEBComment MR_createEntityInContext:self.scratchContext];
            oneCommentMO.score = score;
            oneCommentMO.content = content;
            oneCommentMO.createdAt = oneCommentMLO.updatedAt;
            oneCommentMO.product = product;
            
            MLObject *userMLO = oneCommentMLO[@"user"];
            MLEBUser *user = [MLEBUser MR_createEntityInContext:self.scratchContext];
            user.nickname = userMLO[@"nickname"];
            oneCommentMO.user = user;
            
            [allComments addObject:oneCommentMO];
        }];
        
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, allComments, allComments.count < kPerPage, error);
    }];
}

- (void)fetchCommentForProduct:(MLEBProduct *)product completion:(void(^)(NSUInteger commentCount, MLEBProduct *product, NSError *error))completion {
    if (!product.mlObject) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, 0, nil, nil);
        return;
    }
    
    MLQuery *query = [MLQuery queryWithClassName:@"Comment"];
    [query whereKey:@"product" equalTo:product.mlObject];
    [query findObjectsInBackgroundWithBlock:^(NSArray *commentMLOs, NSError *error) {
        BLOCK_SAFE_ASY_RUN_MainQueue(completion, commentMLOs.count, product, error);
    }];
}

@end
