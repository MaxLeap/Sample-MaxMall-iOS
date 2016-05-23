//
//  MLEBProduct+Helper.h
//  MaxLeapMall
//
//  Created by Michael on 11/19/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import "MLEBProduct.h"

@interface MLEBProduct (Helper)
+ (MLEBProduct *)cloneProduct:(MLEBProduct *)product toContext:(NSManagedObjectContext *)context;
+ (MLEBProduct *)cloneProductToDefaultContext:(MLEBProduct *)product;

- (NSString *)customInfo1Name;
- (NSArray *)customInfo1Items;

- (NSString *)customInfo2Name;
- (NSArray *)customInfo2Items;

- (NSString *)customInfo3Name;
- (NSArray *)customInfo3Items;
@end
