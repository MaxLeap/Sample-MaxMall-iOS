//
//  MLEBProductImagePreviewTableViewCell.m
//  MaxLeapMall
//
//  Created by Michael on 11/18/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import "MLEBProductImagePreviewTableViewCell.h"

@interface MLEBProductImagePreviewTableViewCell () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *pageCountLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (nonatomic, strong) MLEBProduct *product;
@property (weak, nonatomic) IBOutlet UIView *pageBGView;

@end

@implementation MLEBProductImagePreviewTableViewCell

#pragma mark - init Method
- (void)awakeFromNib {
    self.imageScrollView.delegate = self;
    self.imageScrollView.pagingEnabled = YES;
    self.imageScrollView.showsHorizontalScrollIndicator = NO;
    self.imageScrollView.showsVerticalScrollIndicator = NO;
    self.pageBGView.backgroundColor = UIColorFromRGB(0xBFBFBF);
    self.pageBGView.layer.cornerRadius = 16;
    self.pageBGView.layer.masksToBounds = YES;
    [self.contentView addBottomBorderWithColor:UIColorFromRGB(0xE2E1E6) width:0.5];
}

#pragma mark- View Life Cycle


#pragma mark- Override Parent Methods

#pragma mark- SubViews Configuration

#pragma mark- Actions

#pragma mark- Public Methods
- (void)configureCell:(MLEBProduct *)product {
    self.product = product;
    [product.icons enumerateObjectsUsingBlock:^(NSString *oneImageURLString, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *oneProductImageView = (UIImageView *)[self.contentView viewWithTag:100 + idx];
        if (!oneProductImageView) {
            oneProductImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            oneProductImageView.contentMode = UIViewContentModeScaleAspectFit;
        }
        CGRect frame = CGRectMake(ScreenRect.size.width * idx, 0, ScreenRect.size.width, 214);
        oneProductImageView.frame = CGRectInset(frame, 1, 0);
        UIImage *placeImage = [UIImage imageWithColor:UIColorFromRGB(0xE7EBEE)];
        [oneProductImageView sd_setImageWithURL:oneImageURLString.toURL
                               placeholderImage:placeImage
                                        options:SDWebImageRetryFailed];
        [self.imageScrollView addSubview:oneProductImageView];
    }];
    [self.imageScrollView setContentSize:CGSizeMake(ScreenRect.size.width * self.product.icons.count, 214)];
    self.pageCountLabel.text = [NSString stringWithFormat:@"1/%d", (int)product.icons.count];
}

#pragma mark- Delegate，DataSource, Callback Method
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSUInteger page = scrollView.contentOffset.x / scrollView.width;
    self.pageCountLabel.text = [NSString stringWithFormat:@"%d/%d", (int)page + 1, (int)self.product.icons.count];
}

#pragma mark- Private Methods

#pragma mark- Getter Setter

#pragma mark- Helper Method

#pragma mark Temporary Area

@end
