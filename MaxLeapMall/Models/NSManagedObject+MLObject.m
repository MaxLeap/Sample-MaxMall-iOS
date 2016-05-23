//
//  NSManagedObject+MLObject.m
//  MaxLeapMall
//
//  Created by julie on 15/11/19.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "NSManagedObject+MLObject.h"
#import <objc/runtime.h>

static void *kMLObject;

@implementation NSManagedObject (MLObject)
- (MLObject *)mlObject {
    MLObject *mlObject = objc_getAssociatedObject(self, &kMLObject);
    return mlObject;
}

- (void)setMlObject:(MLObject *)mlObject {
    objc_setAssociatedObject(self, &kMLObject, mlObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end