//
//  MLFDWebService.h
//  MaxLeapFood
//
//  Created by Michael on 11/2/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MLEBProduct;
@class MLEBProductCategory;

#define kSharedWebService [MLEBWebService sharedInstance]

static NSUInteger const kPerPage = 6;

typedef NS_ENUM(NSUInteger, MLEBCommentType) {
    MLEBCommentTypePraises,
    MLEBCommentTypeAssessments,
    MLEBCommentTypeBadReviews
};


@interface MLEBWebService : NSObject
@property (nonatomic, strong) NSManagedObjectContext *defaultContext;
@property (nonatomic, strong) NSManagedObjectContext *scratchContext;

+ (MLEBWebService *)sharedInstance;

- (MLEBProduct*)productMOFromProductMLO:(MLObject *)productMLO;
@end

#import "MLEBWebService+HomePage.h"
#import "MLEBWebService+ShoppingCart.h"
#import "MLEBWebService+UserInfo.h"
