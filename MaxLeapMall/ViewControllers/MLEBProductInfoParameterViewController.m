//
//  MLEBProductParameterViewController.m
//  MaxLeapMall
//
//  Created by Michael on 11/19/15.
//  Copyright © 2015 MaxLeap. All rights reserved.
//

#import "MLEBProductInfoParameterViewController.h"

@interface MLEBProductInfoParameterViewController() <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDictionary *productInfo;
@end

@implementation MLEBProductInfoParameterViewController
#pragma mark - init Method

#pragma mark- View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"规格参数", nil);
    [self configureTableView];
    
    if (self.product.info.length > 0) {
        NSError *jsonError;
        NSData *objectData = [self.product.info dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        if (!jsonError) {
            self.productInfo = json;
        }
    }
}

#pragma mark- Override Parent Methods

#pragma mark- SubViews Configuration
- (void)configureTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80.0;
    self.tableView.backgroundColor = UIColorFromRGB(0xeeeeee);
}

#pragma mark- Actions

#pragma mark- Public Methods

#pragma mark- Delegate，DataSource, Callback Method
#pragma mark -UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"BasicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSString *key = self.productInfo.allKeys[indexPath.row];
    NSString *value = self.productInfo[key];
    cell.textLabel.text = key;
    cell.detailTextLabel.text = value;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.productInfo.allKeys count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark- Private Methods

#pragma mark- Getter Setter

#pragma mark- Helper Method

#pragma mark Temporary Area

@end
