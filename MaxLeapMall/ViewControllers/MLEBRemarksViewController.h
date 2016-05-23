//
//  MLFFRemarksViewController.h
//  MaxLeapFood
//
//  Created by Michael on 11/10/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MLEBRemarksViewController;

@protocol MLEBRemarksViewControllerProtocol <NSObject>
- (void)remarksViewController:(MLEBRemarksViewController *)vc didSetRemarks:(NSString *)remarksString;
@end

@interface MLEBRemarksViewController : MLEBBaseViewController
@property (nonatomic, weak) id<MLEBRemarksViewControllerProtocol> delegate;
@end
