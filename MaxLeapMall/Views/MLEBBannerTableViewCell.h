//
//  MLFFBannerTableViewCell.h
//  MaxLeapFood
//
//  Created by Michael on 11/3/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLEBBannerTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIScrollView *bannerScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic, copy) void(^bannerTapHandler)(MLEBBannerTableViewCell *cell, NSUInteger index);

- (void)configureCell:(NSArray *)banner;
@end
