//
//  MLEBAddressesViewController.h
//  MaxLeapMall
//
//  Created by julie on 15/11/17.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MLEBAddressesViewController;
@protocol MLEBAddressesViewControllerProtocol <NSObject>
- (void)addingAddressViewControllerDidSelectAddress:(MLEBAddress *)address;
@end

@interface MLEBAddressesViewController : MLEBBaseViewController
@property (nonatomic, weak) id<MLEBAddressesViewControllerProtocol> delegate;
@end
