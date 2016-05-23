//
//  MLEBCustomViewController.m
//  MaxLeapFood
//
//  Created by Michael on 11/3/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import "MLEBCustomViewController.h"

@implementation MLEBCustomViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName hasSuffix:@"EmbedSegue"]) {
        UIViewController * viewController = (UINavigationController *) [segue destinationViewController];
        viewController.parentController = self;
    }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

#import <objc/runtime.h>

static void *kParentController;

@implementation UIViewController (MLFFEmbedSegueSupport)

- (UIViewController *)parentController {
    UIViewController *parentController = objc_getAssociatedObject(self, &kParentController);
    return parentController;
}

- (void)setParentController:(UIViewController *)parentController {
    objc_setAssociatedObject(self, &kParentController, parentController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
