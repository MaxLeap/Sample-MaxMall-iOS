//
//  MLEBCustomViewController.h
//  MaxLeapFood
//
//  Created by Michael on 11/3/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLEBCustomViewController : UIViewController

@end

@interface UIViewController (MLFFEmbedSegueSupport)
@property (nonatomic, strong) UIViewController *parentController;
@end
