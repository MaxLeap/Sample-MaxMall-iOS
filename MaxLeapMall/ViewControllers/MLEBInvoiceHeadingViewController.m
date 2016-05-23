//
//  MLEBInvoiceHeadingViewController.m
//  MaxLeapMall
//
//  Created by julie on 15/11/23.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBInvoiceHeadingViewController.h"

@interface MLEBInvoiceHeadingViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *headingTextField;

@end

@implementation MLEBInvoiceHeadingViewController

#pragma mark - init Method

#pragma mark- View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"完成", @"") style:UIBarButtonItemStyleDone target:self action:@selector(confirmReceipt)];
   
    self.headingTextField.placeholder = NSLocalizedString(@"请输入发票抬头", @"");
    self.headingTextField.delegate = self;
}

#pragma mark- SubView Configuration

#pragma mark- Action
- (void)confirmReceipt {
    __block UIViewController *vcSubmitOrder = nil;
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[MLEBSubmitOrderViewController class]]) {
            vcSubmitOrder = obj;
            *stop = YES;
        }
    }];
  
    self.receipt.heading = self.headingTextField.text;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"confirmReceiptNotification" object:self.receipt];
    
    [self.navigationController popToViewController:vcSubmitOrder animated:YES];
}

#pragma mark- Delegate，DataSource, Callback Method


#pragma mark- Override Parent Method

#pragma mark- Private Method

#pragma mark- Getter Setter

#pragma mark- Helper Method

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}


@end
