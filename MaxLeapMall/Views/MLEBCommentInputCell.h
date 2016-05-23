//
//  MLEBCommentInputCell.h
//  MaxLeapMall
//
//  Created by julie on 15/11/24.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLEBCommentInputCell : UITableViewCell
@property (nonatomic, copy) void(^starRatingHandler)(float score);
@property (nonatomic, copy) void(^commentHandler)(NSString *content);
@end
