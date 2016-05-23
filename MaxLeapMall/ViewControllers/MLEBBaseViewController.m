//
//  MLEBBaseViewController.m
//  MaxLeapMall
//
//  Created by Sun Jin on 1/21/16.
//  Copyright © 2016 MaxLeapMobile. All rights reserved.
//

#import "MLEBBaseViewController.h"

@interface MLEBBaseViewController ()

@end

@implementation MLEBBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSString *)pageName {
    NSString *name = NSStringFromClass([self class]);
    name = [name stringByReplacingOccurrencesOfString:@"MLEB" withString:@""];
    name = [name stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
    name = [name stringByReplacingOccurrencesOfString:@"View" withString:@""];
    return name;
}

/**
 *  统计界面跳转情况
 *  调用 beginLogPageView 后，在 endLogPageView 调用之前，不要再发生调用 beginLogPageView 的情况
 *  如果出现上述情况，请检查是否有 embedded ViewController
 *  对于 UINavigationViewController 和 UITabbarViewController 等，要统计他们的 Child ViewController，而不是统计他们自身
 */
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [MLAnalytics beginLogPageView:[self pageName]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [MLAnalytics endLogPageView:[self pageName]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
