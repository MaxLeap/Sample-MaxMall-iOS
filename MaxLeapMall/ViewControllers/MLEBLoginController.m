//
//  MLFFLoginController.m
//  MaxLeapFood
//
//  Created by julie on 15/11/6.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBLoginController.h"

#define kGrayBgColor    UIColorFromRGB(0xBFBFBF)
#define kBlueBgColor    UIColorFromRGB(0x0076FF)
#define kGreenBgColor   UIColorFromRGB(0x2ECC71)

@interface MLEBLoginController ()
@property (weak, nonatomic) IBOutlet UITextField *telInputTextField;
@property (weak, nonatomic) IBOutlet UITextField *passcodeInputTextField;
@property (weak, nonatomic) IBOutlet UIButton *gainPasscodeButton;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@property (weak, nonatomic) IBOutlet UILabel *footerNotesLabel;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (nonatomic, copy) NSString *telNumber;
@property (nonatomic, copy) NSString *passcode;

@end

@implementation MLEBLoginController
#pragma mark - init Method

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"登录", @"");
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self configureSubViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark- SubView Configuration
- (void)configureSubViews {
    self.telInputTextField.placeholder = @"输入您的手机号码";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextFieldTextDidChangeNotification object:self.telInputTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextFieldTextDidChangeNotification object:self.passcodeInputTextField];
    
    self.passcodeInputTextField.placeholder = NSLocalizedString(@"输入验证码", @"");
    [self.gainPasscodeButton setTitle:NSLocalizedString(@"获取验证码", @"") forState:UIControlStateNormal];
    self.gainPasscodeButton.backgroundColor = kGrayBgColor;
    [self.gainPasscodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.gainPasscodeButton.layer.cornerRadius = 2;
    
    self.timerLabel.hidden = YES;
    self.timerLabel.text = NSLocalizedString(@"45s", @"");
    self.timerLabel.textAlignment = NSTextAlignmentCenter;
    self.timerLabel.backgroundColor = kGrayBgColor;
    self.timerLabel.textColor = [UIColor whiteColor];
    
    self.footerNotesLabel.numberOfLines = 0;
    self.footerNotesLabel.textColor = UIColorFromRGB(0x808080);
    self.footerNotesLabel.font = [UIFont systemFontOfSize:15];
    self.footerNotesLabel.text = NSLocalizedString(@"未注册过的手机将自动创建为MaxLeap用户", @"");
    
    self.loginButton.backgroundColor = kGrayBgColor;
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.loginButton setTitle:NSLocalizedString(@"验证并登录", @"") forState:UIControlStateNormal];
    self.loginButton.layer.cornerRadius = 2;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"取消", nil)
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(cancelButtonPressed:)];
}

- (void)cancelButtonPressed:(id)sender {
    [self.telInputTextField resignFirstResponder];
    [self.passcodeInputTextField resignFirstResponder];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)textDidChange {
    self.telNumber = self.telInputTextField.text;
    if (self.telNumber.isMobileNumber) {
        self.gainPasscodeButton.backgroundColor = kBlueBgColor;
        if (self.passcode.length == 6) {
            self.loginButton.backgroundColor = kBlueBgColor;
        }
    } else {
        self.gainPasscodeButton.backgroundColor = kGrayBgColor;
        self.loginButton.backgroundColor = kGrayBgColor;
    }
}

- (void)updateLoginButtonStatus {
    if (self.telNumber.isMobileNumber && self.passcode.length == 6) {
        self.loginButton.backgroundColor = kGreenBgColor;
    } else {
        self.loginButton.backgroundColor = kGrayBgColor;
    }
}

#pragma mark- Action

- (IBAction)gainPasscodeButtonPressed:(id)sender {
    if (self.telNumber.isMobileNumber) {
        self.gainPasscodeButton.hidden = YES;
        self.timerLabel.hidden = NO;
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimer:) userInfo:nil repeats:45];
        
        [MLUser requestLoginSmsCodeWithPhoneNumber:self.telNumber block:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                
            } else {
                [timer invalidate];
                self.gainPasscodeButton.hidden = NO;
                self.timerLabel.hidden = YES;
                
                if (error.code == kMLErrorTimeout) {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络连接超时", nil)];
                } else {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"出错了", nil)];
                }
            }
        }];
    } else {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号"];
    }
}

- (void)updateTimer:(NSTimer *)timer {
    static NSInteger count = 45;
    count--;
    
    self.timerLabel.text = [NSString stringWithFormat:@"%lds", (unsigned long)count];
    
    if (count == 0) {
        [timer invalidate];
        
        self.gainPasscodeButton.hidden = NO;
        self.timerLabel.hidden = YES;
        
        count = 45;
    }
}

- (IBAction)loginButtonPressed:(id)sender {
    if (!self.telNumber.isMobileNumber || self.passcode.length != 6) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"正在登录"];
    [kSharedWebService loginWithMobilePhone:self.telNumber smsCode:self.passcode completion:^(MLUser *user, BOOL succeeded, NSError *error) {
        if (succeeded) {
            
            [kSharedWebService fetchUserBasicInfoWithCompletion:^(MLEBUser *user, NSError *error) {
                if (user && !error) {
                    [SVProgressHUD showSuccessWithStatus:@"登录成功!"];
                    
                    [self.telInputTextField resignFirstResponder];
                    [self.passcodeInputTextField resignFirstResponder];
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                  
                    [kSharedWebService syncUserIconWithMaxLeapWithCompletion:nil];
                    [kSharedWebService fetchUserAddressesWithCompletion:nil];
                    [kSharedWebService fetchFavoritesWithCompletion:nil];
                    
                    [kSharedWebService fetchShoppingItemsWithCompletion:nil];
                    
                } else {
                    if (error.code == NSURLErrorTimedOut) {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络连接超时", nil)];
                    } else {
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"出错了", nil)];
                    }
                }
            }];
            
        } else {
            if (error.code == NSURLErrorTimedOut) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络连接超时", nil)];
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"出错了", nil)];
            }
        }
    }];
}

#pragma mark- Delegate，DataSource, Callback Method

#pragma mark- Override Parent Method

#pragma mark- Private Method

#pragma mark- Getter Setter

- (NSString *)passcode {
    return self.passcodeInputTextField.text;
}

- (void)setPasscode:(NSString *)passcode {
    self.passcodeInputTextField.text = passcode;
}

@end
