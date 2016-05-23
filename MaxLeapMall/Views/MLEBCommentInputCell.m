//
//  MLEBCommentInputCell.m
//  MaxLeapMall
//
//  Created by julie on 15/11/24.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBCommentInputCell.h"

NSString * const placeHolderText = @"请输入评价内容...";

@interface MLEBCommentInputCell () <StarRatingViewDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *serviceTextLabel;
@property (weak, nonatomic) IBOutlet TQStarRatingView *starView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *textLengthLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorLine;

@end

@implementation MLEBCommentInputCell

- (void)awakeFromNib {
    // Initialization code
    self.serviceTextLabel.font = [UIFont systemFontOfSize:17];
    self.serviceTextLabel.text = NSLocalizedString(@"服务态度", @"");
    
    self.starView.allowEditing = YES;
    self.starView.delegate = self;
   
    self.separatorLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.textLengthLabel.font = [UIFont systemFontOfSize:17];
    self.textLengthLabel.text = @"0/255";
    self.textLengthLabel.textAlignment = NSTextAlignmentRight;
    self.textLengthLabel.textColor = [UIColor grayColor];
    
    self.textView.font = [UIFont systemFontOfSize:17];
    self.textView.text = placeHolderText;
    self.textView.textColor = [UIColor grayColor];
    self.textView.returnKeyType = UIReturnKeyDone;
    self.textView.enablesReturnKeyAutomatically = YES;
    self.textView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidBeginEditing) name:UITextViewTextDidBeginEditingNotification object:self.textView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChange) name:UITextViewTextDidChangeNotification object:self.textView];
}

#pragma mark - StarRatingViewDelegate
- (void)starRatingView:(TQStarRatingView *)view score:(float)score {
    BLOCK_SAFE_ASY_RUN_MainQueue(self.starRatingHandler, score * 5);
}

- (void)textViewDidBeginEditing {
    if ([self.textView.text isEqualToString:placeHolderText]) {
        self.textView.textColor = [UIColor blackColor];
        self.textView.text = @"";
    }
}

- (void)textViewDidChange {
    if (self.textView.text.length > 140) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"评论不得超过140字!", @"")];
        return;
    }
    
    self.textLengthLabel.text = [NSString stringWithFormat:@"%lu/140", (unsigned long)self.textView.text.length];
    BLOCK_SAFE_ASY_RUN_MainQueue(self.commentHandler, self.textView.text);
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSRange resultRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch];
    if ([text length] == 1 && resultRange.location != NSNotFound) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

@end
