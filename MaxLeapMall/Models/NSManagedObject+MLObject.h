//
//  NSManagedObject+MLObject.h
//  MaxLeapMall
//
//  Created by julie on 15/11/19.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (MLObject)
@property (nonatomic, strong) MLObject *mlObject;
@end
