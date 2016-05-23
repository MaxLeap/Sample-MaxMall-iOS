//
//  MLEBUser.m
//  MaxLeapMall
//
//  Created by julie on 15/11/19.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBUser.h"
#import "MLEBAddress.h"
#import "MLEBOrder.h"
#import "MLEBProduct.h"
#import "MLEBShoppingItem.h"

@implementation MLEBUser

// Insert code here to add functionality to your managed object subclass
+ (MLEBUser *)currentUser {
    MLEBUser *currentUser = [MLEBUser MR_findFirst];
    return currentUser;
}

@end
