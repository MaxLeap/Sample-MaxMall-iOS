//
//  MLFFAddingAddressViewController.h
//  MaxLeapFood
//
//  Created by Michael on 11/10/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MLFFAddingAddressViewController;

@protocol MLFFAddingAddressViewControllerProtocol <NSObject>
- (void)addingAddressViewController:(MLFFAddingAddressViewController *)vc didSelectAddress:(MLEBAddress *)address;
@end

@interface MLFFAddingAddressViewController : MLEBBaseViewController
@property (nonatomic, strong) MLEBAddress *address;
@property (nonatomic, weak) id<MLFFAddingAddressViewControllerProtocol> delegate;
@end
