//
//  MLFFRemarksViewController.m
//  MaxLeapFood
//
//  Created by Michael on 11/10/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import "MLEBRemarksViewController.h"

@interface MLEBRemarksViewController ()
@property (weak, nonatomic) IBOutlet UITextField *remarkdsTextField;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@end

@implementation MLEBRemarksViewController

#pragma mark - init Method

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"备注", nil);
    self.view.backgroundColor = UIColorFromRGB(0xeeeeee);    
    [self.containerView addTopBorderWithColor:UIColorFromRGB(0xDCDCDC) width:0.5];
    [self.containerView addBottomBorderWithColor:UIColorFromRGB(0xDCDCDC) width:0.5];
    self.remarkdsTextField.placeholder = NSLocalizedString(@"请输入备注", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"确定", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(comfirmRemarks:)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.remarkdsTextField becomeFirstResponder];
}

#pragma mark- Override Parent Methods

#pragma mark- SubViews Configuration

#pragma mark- Actions
- (void)comfirmRemarks:(id)sender {
    NSString *remarks = self.remarkdsTextField.text;
    if (remarks.length) {
        [self.delegate remarksViewController:self didSetRemarks:remarks];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark- Public Methods

#pragma mark- Delegate，DataSource, Callback Method

#pragma mark- Private Methods

#pragma mark- Getter Setter

#pragma mark- Helper Method

#pragma mark Temporary Area

@end
