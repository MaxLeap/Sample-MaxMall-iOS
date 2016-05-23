//
//  MLFFCommentTableViewCell.m
//  MaxLeapFood
//
//  Created by Michael on 11/9/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import "MLEBCommentTableViewCell.h"

@interface MLEBCommentTableViewCell ()
@property (weak, nonatomic) IBOutlet TQStarRatingView *starView;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end

@implementation MLEBCommentTableViewCell

#pragma mark - init Method
- (void)awakeFromNib {
    self.starView.allowEditing = NO;
}

#pragma mark- View Life Cycle
#pragma mark- Override Parent Methods

#pragma mark- SubViews Configuration

#pragma mark- Actions

#pragma mark- Public Methods
- (void)configureCell:(MLEBComment *)comment {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    float score = MAX(comment.score.floatValue, 0);
    [self.starView setScore:MIN(5, score) / 5.0f withAnimation:NO];
    self.commentLabel.text = comment.content;
    self.timeLabel.text = [comment.createdAt humanDateString];
    self.userNameLabel.text = comment.user.nickname;
    [self addBottomBorderWithColor:UIColorFromRGB(0xDCDCDC) width:0.5];
}

#pragma mark- Delegate，DataSource, Callback Method

#pragma mark- Private Methods

#pragma mark- Getter Setter

#pragma mark- Helper Method

#pragma mark Temporary Area

@end
