//
//  MLFFBannerTableViewCell.m
//  MaxLeapFood
//
//  Created by Michael on 11/3/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import "MLEBBannerTableViewCell.h"

@interface MLEBBannerTableViewCell () <UIScrollViewDelegate>
@property (nonatomic, assign) NSUInteger page;
@property (nonatomic, strong) NSArray *banners;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation MLEBBannerTableViewCell
#pragma mark - init Method
- (void)awakeFromNib {
    self.bannerScrollView.backgroundColor = UIColorFromRGB(0xE7EBEE);
    self.bannerScrollView.pagingEnabled = YES;
    self.bannerScrollView.showsHorizontalScrollIndicator = NO;
    self.bannerScrollView.showsVerticalScrollIndicator = NO;
    self.bannerScrollView.delegate = self;
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.pageIndicatorTintColor = UIColorFromRGBWithAlpha(0xffffff, 0.5);
    [self.bannerScrollView addGestureRecognizer:self.tapGesture];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5
                                                  target:self
                                                selector:@selector(autoScroll:)
                                                userInfo:nil
                                                 repeats:YES];
}

#pragma mark- Override Parent Methods

#pragma mark- SubViews Configuration

#pragma mark- Actions
- (void)autoScroll:(id)sender {
    if (self.banners.count > 0) {
        self.page = (self.page + 1) % self.banners.count;
        [self.bannerScrollView setContentOffset:CGPointMake(self.page * self.bannerScrollView.width, 0) animated:YES];
    }
}

- (IBAction)pageControlTouchupInside:(UIPageControl *)pageController {
    NSUInteger page = pageController.currentPage;
    [self.bannerScrollView setContentOffset:CGPointMake(page * self.bannerScrollView.width, 0)
                                   animated:YES];
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (self.page < self.banners.count) {
        BLOCK_SAFE_ASY_RUN_MainQueue(self.bannerTapHandler, self, self.page);
    }
}

#pragma mark- Public Methods
- (void)configureCell:(NSArray *)banners {
    self.banners = banners;
    
    self.pageControl.numberOfPages = banners.count;
    for (int i = 0; i < [banners count]; i++) {
        UIImageView *oneImageView = (UIImageView *)[self.bannerScrollView viewWithTag:100 + i];
        if (!oneImageView) {
            oneImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            oneImageView.contentMode = UIViewContentModeScaleAspectFill;
            oneImageView.clipsToBounds = YES;
            oneImageView.userInteractionEnabled = NO;
            oneImageView.backgroundColor = UIColorFromRGB(0xeeeeee);
            oneImageView.tag = 100 + i;
            MLEBBanner *oneBanner = banners[i];
            UIImage *placeImage = [UIImage imageWithColor:UIColorFromRGB(0xE7EBEE)];
            [oneImageView sd_setImageWithURL:oneBanner.urlString.toURL placeholderImage:placeImage options:SDWebImageRetryFailed];
            [self.bannerScrollView addSubview:oneImageView];
        }
        
        CGRect frame = CGRectMake(0, 0, self.bannerScrollView.width, self.bannerScrollView.height);
        frame.origin = CGPointMake(self.bannerScrollView.frame.size.width * i, 0);
        oneImageView.frame = frame;
    }
    
    CGSize size = CGSizeMake(self.bannerScrollView.width * banners.count, self.bannerScrollView.height);
    self.bannerScrollView.contentSize = size;
    
    [self updateConstraints];
}

#pragma mark- Delegate，DataSource, Callback Method
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.bannerScrollView.width;
    NSUInteger newPage = floor((self.bannerScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (newPage != self.page) {
        self.page = newPage;
    }
    self.pageControl.currentPage = self.page;
}

#pragma mark- Private Methods

#pragma mark- Getter Setter
- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    }
    
    return _tapGesture;
}

#pragma mark- Helper Method

#pragma mark Temporary Area

@end
