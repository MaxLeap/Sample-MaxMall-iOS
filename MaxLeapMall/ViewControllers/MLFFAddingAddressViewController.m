//
//  MLFFAddingAddressViewController.m
//  MaxLeapFood
//
//  Created by Michael on 11/10/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import "MLFFAddingAddressViewController.h"

@interface MLFFAddingAddressViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIView *separtorLine;
@property (weak, nonatomic) IBOutlet UIView *separtorLine2;
@property (weak, nonatomic) IBOutlet UILabel *cellPhoneLabel;
@property (weak, nonatomic) IBOutlet UITextField *cellPhoenTextField;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separtorlineHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separtorline2Height;
@property (nonatomic, assign) BOOL isAddressSelfCreation;

@end

@implementation MLFFAddingAddressViewController

#pragma mark - init Method

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.address ? NSLocalizedString(@"编辑地址", @"") : NSLocalizedString(@"添加地址", nil);
    [self configureTableView];
    [self configureNavigationBar];
    if (!self.address) {
        self.isAddressSelfCreation = YES;
        self.address = [MLEBAddress MR_createEntityInContext:kSharedWebService.defaultContext];
    }
}

#pragma mark- Override Parent Methods

#pragma mark- SubViews Configuration
- (void)configureTableView {
    self.view.backgroundColor = UIColorFromRGB(0xeeeeee);
    self.separtorLine.backgroundColor = UIColorFromRGB(0xeeeeee);
    self.separtorLine2.backgroundColor = UIColorFromRGB(0xeeeeee);
    self.separtorlineHeight.constant = 0.5;
    self.separtorline2Height.constant = 0.5;
    self.nameLabel.text = NSLocalizedString(@"联系人", nil);
    self.cellPhoneLabel.text = NSLocalizedString(@"联系电话", nil);
    self.addressLabel.text = NSLocalizedString(@"收货地址", nil);
    self.nameTextField.placeholder = NSLocalizedString(@"请输入姓名", nil);
    self.cellPhoenTextField.placeholder = NSLocalizedString(@"您的手机号", nil);
    self.addressTextField.placeholder = NSLocalizedString(@"请输入详细地址", nil);
    self.nameTextField.text = self.address.name;
    self.cellPhoenTextField.text = self.address.tel;
    self.addressTextField.text = self.address.street;
    DDLogInfo(@"%@, %@, %@", self.address.name, self.address.tel, self.address.street);
}

- (void)configureNavigationBar {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"确定", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(comfirmAddress:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"取消", nil)
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(cancelButtonPressed:)];
}

#pragma mark- Actions
- (void)comfirmAddress:(id)sender {
    self.address.name = self.nameTextField.text;
    self.address.tel = self.cellPhoenTextField.text;
    self.address.street = self.addressTextField.text;
    
    if (self.address.name.length == 0 || self.address.tel.length == 0 || self.address.street.length == 0) {
        return;
    }
    
    if (!self.address.tel.isMobileNumber) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号"];
        [self.cellPhoenTextField becomeFirstResponder];
        return;
    }

    self.address.user = [MLEBUser MR_findFirst];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [self.navigationController popViewControllerAnimated:YES];
   
    [kSharedWebService syncAddressesToMaxLeapWithCompletion:^(BOOL succeeded, NSError *error) {
        
    }];
}

- (void)cancelButtonPressed:(id)sender {
    if (self.isAddressSelfCreation) {
        [self.address MR_deleteEntity];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark- Public Methods

#pragma mark- Delegate，DataSource, Callback Method


#pragma mark- Private Methods

#pragma mark- Getter Setter

#pragma mark- Helper Method

#pragma mark Temporary Area

@end
