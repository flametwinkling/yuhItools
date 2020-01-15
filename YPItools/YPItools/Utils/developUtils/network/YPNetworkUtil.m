//
//  YPNetworkUtil.m
//  YPItools
//
//  Created by qipeng_yuhao on 2020/1/10.
//  Copyright © 2020 qipeng_yuhao. All rights reserved.
//

#import "YPNetworkUtil.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@interface YPNetworkUtil ()
{
    YPReachability *_reachability;
}
@end

@implementation YPNetworkUtil

static YPNetworkUtil *_networkUtil = nil;

+ (YPNetworkUtil *)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _networkUtil = [[YPNetworkUtil alloc] init];
    });
    
    return _networkUtil;
}

- (instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - network info

- (YPNetworkStatus)checkNetworkStatus{
    _reachability = [YPReachability reachabilityForInternetConnection];
    _netWorkStatus = [_reachability currentReachabilityStatus];
    return _netWorkStatus;
}

- (NSString *)fetchCurrentConnectWifiInfo {
    NSString *bssid = nil;
    NSString *ssid = nil;

    NSDictionary *ifs = [self fetchSSIDInfo];
    if (ifs) {
        ssid = [ifs objectForKey:@"SSID"];
        bssid = [ifs objectForKey:@"BSSID"];
    }

    if (bssid) {
        NSMutableString *buffer = [[NSMutableString alloc] init];
        NSArray *bssidAry = [bssid componentsSeparatedByString:@":"];

        NSInteger count = [bssidAry count];

        for (int i = 0; i < count; i++) {
            if ([bssidAry[i] length] == 1) {
                [buffer appendFormat:@"0%@", bssidAry[i]];
            } else {
                [buffer appendFormat:@"%@", bssidAry[i]];
            }

            if (i < count - 1) {
                [buffer appendFormat:@"%@", @":"];
            }
        }

        bssid = buffer;
    }

    NSString *wifiInfo = [[[[[[NSString alloc] initWithString:ssid ? ssid : @""] stringByAppendingString:@"|"] stringByAppendingString:bssid ? bssid : @""] stringByAppendingString:@"|"] stringByAppendingString:@"0"];
    return wifiInfo;
}

- (id)fetchSSIDInfo {

    @try {
        if (_netWorkStatus != YPReachableViaWiFi) {
            return nil;
        }

        NSArray *ifs = (id)CFBridgingRelease(CNCopySupportedInterfaces());
        NSMutableDictionary *info = nil;
        for (NSString *ifnam in ifs) {
            NSDictionary *newInfo = (id)CFBridgingRelease(CNCopyCurrentNetworkInfo((CFStringRef)ifnam));
            if ([newInfo isKindOfClass:[NSDictionary class]] && [newInfo count]) {

                info = [[NSMutableDictionary alloc] init];
                [info setObject:newInfo[@"SSID"] forKey:@"SSID"];
                [info setObject:newInfo[@"BSSID"] forKey:@"BSSID"];

                break;
            }
        }

        return info;
    }
    @catch (NSException *exception) {
        
        return nil;
    }
}

- (void)startWifiReach:(YPNetworkChangeBlock)statusChanged{
    if (!_reachability) {
        _reachability = [YPReachability reachabilityForInternetConnection];
    }
    _netWorkStatus = [_reachability currentReachabilityStatus];
    _networkChangeBlock = statusChanged;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kQPNotiNetworkReachabilityChangedNotification
                                               object:nil];
    [_reachability startNotifier];

}

- (void)reachabilityChanged:(NSNotification *)note {
    _netWorkStatus = [_reachability currentReachabilityStatus];
    _networkChangeBlock(_netWorkStatus);
}

- (void)stopWifiReach{
    if (_reachability && [_reachability isKindOfClass:[YPReachability class]]) {
        [_reachability stopNotifier];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kQPNotiNetworkReachabilityChangedNotification
                                                  object:nil];
}


#pragma mark - carrier info

- (NSString *)getCarrier {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    CTCarrier *carrier = [[[CTTelephonyNetworkInfo alloc] init] subscriberCellularProvider];
#pragma clang diagnostic pop
    // Use setValue semantics to avoid adding keys where value can be nil.
    return [self getCarrierNameByCarrier:carrier];
}

- (NSString *)getCarrierNameByCarrier:(CTCarrier *)carrier{
    if (carrier != nil) {
        NSString *networkCode = [carrier mobileNetworkCode];
        NSString *countryCode = [carrier mobileCountryCode];
        NSString *carrierName = nil;
        //中国运营商
        if (countryCode && [countryCode isEqualToString:@"460"]) {
            if (networkCode) {
                
                //中国移动
                if ([networkCode isEqualToString:@"00"] || [networkCode isEqualToString:@"02"] || [networkCode isEqualToString:@"07"] || [networkCode isEqualToString:@"08"]) {
                    carrierName= @"中国移动";
                }
                //中国联通
                if ([networkCode isEqualToString:@"01"] || [networkCode isEqualToString:@"06"] || [networkCode isEqualToString:@"09"]) {
                    carrierName= @"中国联通";
                }
                //中国电信
                if ([networkCode isEqualToString:@"03"] || [networkCode isEqualToString:@"05"] || [networkCode isEqualToString:@"11"]) {
                    carrierName= @"中国电信";
                }
                //中国卫通
                if ([networkCode isEqualToString:@"04"]) {
                    carrierName= @"中国卫通";
                }
                //中国铁通
                if ([networkCode isEqualToString:@"20"]) {
                    carrierName= @"中国铁通";
                }
            }
        }
        
        if (!countryCode) {
            return @"";
        }
        
        if (carrierName != nil) {
            return carrierName;
        } else {
            if (carrier.carrierName) {
                return carrier.carrierName;
            }
        }
    }
    return @"";
}

- (NSString *)getNetWorkStates {
    NSString *network = @"NULL";
    @try {
        YPNetworkStatus status = [_reachability currentReachabilityStatus];
        if (status == YPReachableViaWiFi) {
            network = @"WIFI";
        } else if (status == YPReachableViaWWAN) {
            static CTTelephonyNetworkInfo *netinfo = nil;
            if (!netinfo) {
                netinfo = [[CTTelephonyNetworkInfo alloc] init];
            }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
            if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
                network = @"2G";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge]) {
                network = @"2G";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA]) {
                network = @"3G";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA]) {
                network = @"3G";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA]) {
                network = @"3G";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
                network = @"3G";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]) {
                network = @"3G";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]) {
                network = @"3G";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
                network = @"3G";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD]) {
                network = @"3G";
            } else if ([netinfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
                network = @"4G";
            } else if (netinfo.currentRadioAccessTechnology) {
                network = @"UNKNOWN";
            }
#pragma clang diagnostic pop
        }
    } @catch(NSException *exception) {
        NSLog(@"%@: %@", self, exception);
    }
    return network;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kQPNotiNetworkReachabilityChangedNotification
                                                  object:nil];
}


@end
