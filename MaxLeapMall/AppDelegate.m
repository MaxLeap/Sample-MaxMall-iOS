//
//  AppDelegate.m
//  MaxLeapMall
//
//  Created by julie on 15/11/16.
//  Copyright © 2015年 MaxLeapMobile. All rights reserved.
//

@import MaxLeapPay;
#import "AppDelegate.h"
#import "WXApi.h"

#define WECHAT_APPID            @"wx85fcd0162fdd8c11"


@interface AppDelegate () <WXApiDelegate>
@property (nonatomic) DDFileLogger *fileLogger;
@end

@implementation AppDelegate

#pragma mark payment delegate and methods

- (void)onResp:(BaseResp*)resp {
    // 将 PayResponse 交给 MaxLeapPay 处理
    if ([resp isKindOfClass:[PayResp class]]) {
        [MaxLeapPay handleWXPayResponse:(PayResp *)resp];
    }
}

// iOS 4.2 -- iOS 8.4
// 如果需要兼容 iOS 6, iOS 7, iOS 8，需要实现这个代理方法
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    // 注意，这里由 `MaxLeapPay` 统一调用各支付平台 SDK 的 `handleOpenUrl:` 方法，可能与其他 SDK 的发生重复调用问题，请注意处理
    
    return [MaxLeapPay handleOpenUrl:url completion:^(MLPayResult * _Nonnull result) {
        // 支付应用结果回调，保证跳转支付应用过程中，即使调用方app被系统kill时，能通过这个回调取到支付结果。
    }];
}

// iOS 9.0 or later
// iOS 9 以及更新版本会优先调用这个代理方法，如果没有实现这个，则会调用上面那个
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:  (NSDictionary<NSString *,id> *)options {
    
    // 注意，这里由 `MaxLeapPay` 统一调用各支付平台 SDK 的 `handleOpenUrl:` 方法，可能与其他 SDK 的发生重复调用问题，请注意处理
    
    return [MaxLeapPay handleOpenUrl:url completion:^(MLPayResult * _Nonnull result) {
        // 支付应用结果回调，保证跳转支付应用过程中，即使调用方app被系统kill时，能通过这个回调取到支付结果。
    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configureGlobalAppearance];
    [self configureMaxLeap];
    [self configureMagicalRecord];
    [self configureCocoaLumberjack];
    
    [self syncUserInfoFromMaxLeap];
    
    
    [MaxLeapPay setWXAppId:WECHAT_APPID wxDelegate:self description:@"Payment sample"];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // 将 device token 保存到 MaxLeap 服务器，以便服务器向本设备发送远程推送
    [[MLInstallation currentInstallation] setDeviceTokenFromData:deviceToken];
    [[MLInstallation currentInstallation] saveInBackgroundWithBlock:nil];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    completionHandler(UIBackgroundFetchResultNoData);
}

#pragma mark - Private Methods

- (void)configureGlobalAppearance {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [UITabBarItem.appearance setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0x404040),
                                                      NSFontAttributeName : [UIFont systemFontOfSize:10]}
                                           forState:UIControlStateNormal];
    [UITabBarItem.appearance setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0xFF7700),
                                                      NSFontAttributeName : [UIFont systemFontOfSize:10]}
                                           forState:UIControlStateSelected];
    
    UIImage *barLineImage = [UIImage imageWithColor:[UIColor clearColor]];
    UIImage *barBGImage = [UIImage imageWithColor:UIColorFromRGB(0xFF4400)];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0xffffff),
                                                           NSFontAttributeName : [UIFont systemFontOfSize:17]}];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0xffffff),
                                                           NSFontAttributeName : [UIFont systemFontOfSize:17]}
                                                forState:UIControlStateNormal];
    [[UINavigationBar appearance] setBackgroundImage:barBGImage forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:barLineImage];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
}

- (void)configureMaxLeap {
    [MaxLeap setNetworkTimeoutInterval:60];
    [MLLogger setLogLevel:MLLogLevelError];
    [MaxLeap setApplicationId:kMaxLeap_Application_ID clientKey:kMaxLeap_Client_Key site:MLSiteCN];
    [self registerRemoteNotifications];
}

- (void)registerRemoteNotifications {
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *pushsettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:pushsettings];
    } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert];
#endif
    }
}

- (void)configureMagicalRecord {
#ifdef DEBUG
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelWarn];
#endif
    [MagicalRecord setupAutoMigratingCoreDataStack];
}

- (void)configureCocoaLumberjack {
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    
    [fileLogger setMaximumFileSize:(1024 * 1024)];
    [fileLogger setRollingFrequency:(3600.0 * 24.0)];
    [[fileLogger logFileManager] setMaximumNumberOfLogFiles:7];
    [DDLog addLogger:fileLogger];
    
    self.fileLogger = fileLogger;
}

- (void)syncUserInfoFromMaxLeap {
    
    if ([kSharedWebService isLoggedIn]) {
        [[kSharedWebService currentUser] fetchInBackgroundWithBlock:^(MLObject * _Nullable object, NSError * _Nullable error) {
            if (!error) {
                [kSharedWebService fetchUserBasicInfoWithCompletion:^(MLEBUser *user, NSError *error) {
                    
                    [kSharedWebService syncUserIconWithMaxLeapWithCompletion:nil];
                    
                    [kSharedWebService fetchUserAddressesWithCompletion:nil];
                    
                    [kSharedWebService fetchShoppingItemsWithCompletion:nil];
                    
                    [kSharedWebService fetchFavoritesWithCompletion:nil];
                }];
            }
        }];
    }
}

@end
