//
//  MLFFEditNickNameController.m
//  MaxLeapFood
//
//  Created by julie on 15/11/6.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBEditNicknameViewController.h"

@interface MLEBEditNicknameViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic, strong) MLEBUser *user;
@end

@implementation MLEBEditNicknameViewController
#pragma mark - init Method

#pragma mark- View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"用户名", nil);
    self.user = [MLEBUser MR_findFirst];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"确定", @"") style:UIBarButtonItemStyleDone target:self action:@selector(confirmNickName)];
    
    [self.textField becomeFirstResponder];
    self.textField.text = self.user.nickname;
}

#pragma mark- SubView Configuration

#pragma mark- Action
- (void)confirmNickName {
    if (self.textField.text.length > 0) {
        if (![self.textField.text isEqualToString:self.user.nickname]) {
            [kSharedWebService updateNickName:self.textField.text completion:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [SVProgressHUD showSuccessWithStatus:@"更新成功!"];
                    [self.navigationController popViewControllerAnimated:YES];
                    
                } else {
                    if (error.code == 100) {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络连接超时", nil)];
                    } else {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"出错了", nil)];
                    }
                }
            }];
        } else {
           [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark- Delegate，DataSource, Callback Method

#pragma mark- Override Parent Method

#pragma mark- Private Method

#pragma mark- Getter Setter

#pragma mark- Helper Method


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
