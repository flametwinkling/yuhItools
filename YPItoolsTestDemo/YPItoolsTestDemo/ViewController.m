//
//  ViewController.m
//  YPItoolsTestDemo
//
//  Created by qipeng_yuhao on 2020/1/10.
//  Copyright © 2020 qipeng_yuhao. All rights reserved.
//

#import "ViewController.h"
#import <YPItools/YPItools.h>

#define kQPNotiNetworkReachabilityChangedNotification @"kQpcNotiNetworkReachabilityChangedNotification"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self checkNetwork];
    
//    [self testNetworkUtil];
    
    [self getDeviceinfo];
}

- (void)getDeviceinfo{
    NSLog(@"%@ %@ %@ %@",[YPDeviceInfoUtil retrivePhoneMode],[YPDeviceInfoUtil retriveAppVersionCode],[YPDeviceInfoUtil retriveAppVersion],[YPDeviceInfoUtil retriveAppName]);
}

- (void)testNetworkUtil{
    YPNetworkUtil *util = [YPNetworkUtil sharedInstance];
     YPNetworkStatus networkStatus = [util checkNetworkStatus];
     switch (networkStatus) {
         case YPNotReachable:
             NSLog(@"no network");
             break;
         case YPReachableViaWWAN:
             NSLog(@"wwan open");
             break;
        case YPReachableViaWiFi:
             NSLog(@"wifi open");
             break;
         default:
             break;
     }
    
    NSLog(@"wifi ssid info:%@",[util fetchCurrentConnectWifiInfo]);
    
    [util startWifiReach:^(YPNetworkStatus status) {
        NSLog(@"status change");
    }];
    
    NSLog(@"operator :%@",[util getCarrier]);
}

- (void)checkNetwork{
  
//    YPReachability *reachability = [YPReachability reachabilityWithHostName:@"https://baidu.com"];
    
//    YPReachability *reachability = [YPReachability reachabilityForInternetConnection];
    
    YPReachability *reachability = [YPReachability reachabilityForLocalWiFi];
    
    YPNetworkStatus networkStatus = [reachability currentReachabilityStatus];
    switch (networkStatus) {
        case YPNotReachable:
            NSLog(@"no network");
            break;
        case YPReachableViaWiFi:
            NSLog(@"wifi open");
            break;
        case YPReachableViaWWAN:
            NSLog(@"wwan open");
            break;
        default:
            break;
    }

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kQPNotiNetworkReachabilityChangedNotification
                                               object:nil];
    [reachability startNotifier];
}

- (void)reachabilityChanged:(NSNotification *)note {
    YPReachability *curReach = [note object];
    YPNetworkStatus netStatus = [curReach currentReachabilityStatus];
    NSLog(@"network change to %ld",(long)netStatus);
}


- (void)dealloc{
    
}

@end
