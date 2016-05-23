//
//  MLEBProductQuantityTableViewCell.m
//  MaxLeapMall
//
//  Created by Michael on 11/18/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import "MLEBProductQuantityTableViewCell.h"

@interface MLEBProductQuantityTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (nonatomic, strong) MLEBShoppingItem *shoppingItem;
@end

@implementation MLEBProductQuantityTableViewCell

#pragma mark - init Method
- (void)awakeFromNib {
    [self.minusButton setImage:ImageNamed(@"btn_minus_one_normal") forState:UIControlStateNormal];
    [self.minusButton setImage:ImageNamed(@"btn_minus_one_selected") forState:UIControlStateHighlighted];
    
    [self.plusButton setImage:ImageNamed(@"btn_add_one_normal") forState:UIControlStateNormal];
    [self.plusButton setImage:ImageNamed(@"btn_add_one_selected") forState:UIControlStateHighlighted];

    self.mainLabel.text = @"数量";
}

#pragma mark- View Life Cycle

#pragma mark- Override Parent Methods

#pragma mark- SubViews Configuration

#pragma mark- Actions
- (IBAction)plusButtonPressed:(id)sender {
    int quantity = (int)self.shoppingItem.quantity.integerValue + 1;
    self.shoppingItem.quantity = @(MAX(0, quantity));
    if (self.shoppingItem.quantity == 0) {
        self.minusButton.hidden = YES;
        self.quantityLabel.hidden = YES;
    } else {
        self.minusButton.hidden = NO;
        self.quantityLabel.hidden = NO;
        self.quantityLabel.text = [self.shoppingItem.quantity stringValue];
    }
    BLOCK_SAFE_ASY_RUN_MainQueue(self.plusProductOrderHandler, self);
}

- (IBAction)minusButtonPressed:(id)sender {
    int quantity = (int)self.shoppingItem.quantity.integerValue - 1;
    self.shoppingItem.quantity = @(MAX(0, quantity));
    if (self.shoppingItem.quantity.integerValue == 0) {
        self.minusButton.hidden = YES;
        self.quantityLabel.hidden = YES;
    } else {
        self.minusButton.hidden = NO;
        self.quantityLabel.hidden = NO;
        self.quantityLabel.text = [self.shoppingItem.quantity stringValue];
    }
    BLOCK_SAFE_ASY_RUN_MainQueue(self.minusProductOrderHandler, self);
}

#pragma mark- Public Methods
- (void)configureCell:(MLEBShoppingItem *)shoppingItem {
    self.shoppingItem = shoppingItem;
    if (shoppingItem.quantity.integerValue == 0) {
        self.minusButton.hidden = YES;
        self.quantityLabel.hidden = YES;
    } else {
        self.minusButton.hidden = NO;
        self.quantityLabel.hidden = NO;
        self.quantityLabel.text = [shoppingItem.quantity stringValue];
    }
}

#pragma mark- Delegate，DataSource, Callback Method

#pragma mark- Private Methods

#pragma mark- Getter Setter

#pragma mark- Helper Method

#pragma mark Temporary Area


@end
