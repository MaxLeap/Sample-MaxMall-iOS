//
//  MLEBCustomTabBarController.m
//  MaxLeapFood
//
//  Created by Michael on 11/3/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import "MLEBCustomTabBarController.h"

@interface MLEBCustomTabBarController () <UITabBarControllerDelegate>

@end

@implementation MLEBCustomTabBarController

#pragma mark - init Method

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    [self configureTabbar];
}

#pragma mark- Override Parent Methods

#pragma mark- SubViews Configuration
#pragma mark- SubView Configuration
- (void)configureTabbar {
    NSDictionary *deliveryItemUI = @{@"title"          : NSLocalizedString(@"主页", nil),
                                     @"image"          : OriginalImageNamed(@"btn_home_normal"),
                                     @"selectedImage"  : OriginalImageNamed(@"btn_home_selected")};
    
    NSDictionary *orderItemUI = @{@"title"          : NSLocalizedString(@"分类", nil),
                                  @"image"          : OriginalImageNamed(@"btn_categories_normal"),
                                  @"selectedImage"  : OriginalImageNamed(@"btn_categories_selected")};
   
    NSDictionary *shoppingCartItemUI = @{@"title"          : NSLocalizedString(@"购物车", nil),
                                  @"image"          : OriginalImageNamed(@"btn_shoppingcart_normal"),
                                  @"selectedImage"  : OriginalImageNamed(@"btn_shoppingcart_selected")};
    
    
    NSDictionary *meItemUI = @{@"title"         : NSLocalizedString(@"我", nil),
                               @"image"         : OriginalImageNamed(@"btn_my_food_normal"),
                               @"selectedImage" : OriginalImageNamed(@"btn_my_food_selected")};
    
    NSDictionary *allTabbarItemUI = @{@(0) : deliveryItemUI, @(1) : orderItemUI, @(2) : shoppingCartItemUI, @(3) : meItemUI};
    
    [self.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem *oneTabbarItem, NSUInteger idx, BOOL *stop) {
        NSDictionary *oneTabbarItemUI = allTabbarItemUI[@(idx)];
        oneTabbarItem.title = oneTabbarItemUI[@"title"];
        oneTabbarItem.image = oneTabbarItemUI[@"image"];
        oneTabbarItem.selectedImage = oneTabbarItemUI[@"selectedImage"];
    }];
}

#pragma mark- Actions

#pragma mark- Public Methods

#pragma mark- Private Methods

#pragma mark- Delegate，DataSource, Callback Method

#pragma mark- Getter Setter

#pragma mark- Helper Method

#pragma mark Temporary Area


@end
