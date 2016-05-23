//
//  MLEBAddressesViewController.m
//  MaxLeapMall
//
//  Created by julie on 15/11/17.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

#import "MLEBAddressesViewController.h"

@interface MLEBAddressesViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UILabel *emptyNotesLabel;

@property (nonatomic, strong) NSMutableArray *addresses;
@property (nonatomic, strong) MLEBAddress *selectedAddress;

@end

@implementation MLEBAddressesViewController

#pragma mark - init Method

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"收货地址", @"");
    
    [self configureSubViews];
    
    [self reloadViews];
}

- (void)reloadViews {
    self.addresses = [[MLEBAddress MR_findAll] mutableCopy];
    [self.tableView reloadData];
    
    self.emptyView.hidden = (self.addresses.count != 0);
    self.tableView.hidden = (self.addresses.count == 0);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadViews];
}

#pragma mark- SubView Configuration
- (void)configureSubViews {
    [self configureNavigationBar];
    [self configureTableView];
    [self configureEmptyView];
}

- (void)configureNavigationBar {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAddress:)];
}

- (void)configureTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.estimatedRowHeight = 76;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)configureEmptyView {
    self.emptyView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.emptyNotesLabel.textColor = kTextLightGrayColor;
    self.emptyNotesLabel.numberOfLines = 0;
    self.emptyNotesLabel.text = NSLocalizedString(@"您还没有收货地址\n\n点击+开始添加", @"");
    self.emptyNotesLabel.textAlignment = NSTextAlignmentCenter;
}

#pragma mark- Action
- (void)addAddress:(id)sender {
    self.selectedAddress = nil;
    [self performSegueWithIdentifier:@"MLEBEditAddressViewControllerSegueIdentifier" sender:nil];
}

#pragma mark- Delegate，DataSource, Callback Method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.addresses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MLEBAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MLEBAddressTableViewCell" forIndexPath:indexPath];
    
    MLEBAddress *address = self.addresses[indexPath.row];
    cell.nameLabel.text = address.name;
    cell.telLabel.text = address.tel;
    cell.addressLabel.text = address.street;
    cell.editAddressHandler = ^{
        self.selectedAddress = address;
        [self performSegueWithIdentifier:@"MLEBEditAddressViewControllerSegueIdentifier" sender:nil];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   
    if (self.delegate) {
        [self.navigationController popViewControllerAnimated:YES];
        
        MLEBAddress *address = self.addresses[indexPath.row];
        [self.delegate addingAddressViewControllerDidSelectAddress:address];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MLEBAddress *oneAddress = self.addresses[indexPath.row];
        [self.addresses removeObjectAtIndex:indexPath.row];

        [oneAddress MR_deleteEntity];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        [self reloadViews];
        
        [kSharedWebService syncAddressesToMaxLeapWithCompletion:nil];
    }
}

#pragma mark- Override Parent Method

#pragma mark- Private Method

#pragma mark- Getter Setter

#pragma mark- Helper Method

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *vc = [segue destinationViewController];
    if ([vc isKindOfClass:[MLFFAddingAddressViewController class]]) {
        MLFFAddingAddressViewController *vcEditAddress = (MLFFAddingAddressViewController *)vc;
        vcEditAddress.address = self.selectedAddress;
    }
}


@end
