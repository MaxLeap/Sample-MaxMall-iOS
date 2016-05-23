//
//  MLEBAccountInfoController.m
//  MaxLeapMall
//
//  Created by julie on 15/11/17.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBAccountInfoController.h"

@interface MLEBAccountInfoController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) MLEBUser *user;

@property (nonatomic, strong) UIAlertController *actionController;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@end

@implementation MLEBAccountInfoController

#pragma mark - init Method

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"帐户信息", @"");
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.user = [MLEBUser MR_findFirst];
    [self.tableView reloadData];
  
    [kSharedWebService fetchUserBasicInfoWithCompletion:^(MLEBUser *user, NSError *error) {
        [kSharedWebService syncUserIconWithMaxLeapWithCompletion:^(BOOL succeeded, NSError *error) {
            self.user = [MLEBUser MR_findFirst];
            [self.tableView reloadData];
        }];
        
        [kSharedWebService fetchUserAddressesWithCompletion:^(NSOrderedSet *addresses, NSError *error) {
            self.user = [MLEBUser MR_findFirst];
            [self.tableView reloadData];
        }];
        
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark- SubView Configuration

#pragma mark- Action


#pragma mark- Delegate，DataSource, Callback Method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = (indexPath.section == 0 && indexPath.row == 0) ? @"MLEBUserIconCell" : @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            MLEBUserIconCell *iconCell = (MLEBUserIconCell *)cell;
            iconCell.titleLabel.text = NSLocalizedString(@"头像", @"");
            iconCell.iconImageView.image = self.user.iconImage ? : ImageNamed(@"default_portrait");
            
        } else {
            cell.textLabel.text = NSLocalizedString(@"用户名", @"");
            cell.detailTextLabel.text = self.user.nickname;
        }
    } else {
        cell.textLabel.text = NSLocalizedString(@"收货地址", @"");
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d个", (int)self.user.addresses.count];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self presentViewController:self.actionController animated:YES completion:nil];
        
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        [self performSegueWithIdentifier:@"MLEBEditNicknameViewControllerSegueIdentifier" sender:nil];
        
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"MLEBAddressesViewControllerSegueIdentifier" sender:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        if (self.imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
       
        [SVProgressHUD showWithStatus:@"正在更新" maskType:SVProgressHUDMaskTypeBlack];
        [self.imagePickerController dismissViewControllerAnimated:YES completion:^{
            
            [kSharedWebService saveNewIcon:image completion:^(BOOL succeeded) {
                if (succeeded) {
                   [SVProgressHUD dismiss];
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    
                    [[MLEBWebService sharedInstance] syncUserIconWithMaxLeapWithCompletion:^(BOOL succeeded, NSError *error) {
                        if (succeeded && !error) {
                            [SVProgressHUD showSuccessWithStatus:@"头像上传成功!"];
                            
                        } else {
                            if (error.code == NSURLErrorTimedOut) {
                                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"网络连接超时", nil)];
                            } else {
                                [SVProgressHUD showErrorWithStatus:@"头像上传失败!"];
                            }
                        }
                    }];
                    
                } else {
                    [SVProgressHUD showErrorWithStatus:@"出错了!"];
                }
                
            }];
        }];
    }
}
#pragma mark- Override Parent Method

#pragma mark- Private Method

#pragma mark- Getter Setter

- (UIAlertController *)actionController {
    if (!_actionController) {
        _actionController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
                self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:self.imagePickerController animated:YES completion:nil];
            }
        }];
        UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"从相册中选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:self.imagePickerController animated:YES completion:nil];
            }
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [_actionController addAction:takePhotoAction];
        [_actionController addAction:albumAction];
        [_actionController addAction:cancelAction];
    }
    return _actionController;
}

- (UIImagePickerController *)imagePickerController {
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
    }
    return _imagePickerController;
}

#pragma mark- Helper Method

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}
 

@end
