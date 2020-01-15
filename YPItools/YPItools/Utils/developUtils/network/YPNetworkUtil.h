//
//  YPNetworkUtil.h
//  YPItools
//
//  Created by qipeng_yuhao on 2020/1/10.
//  Copyright © 2020 qipeng_yuhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YPReachability.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^YPNetworkChangeBlock)(YPNetworkStatus status);

@interface YPNetworkUtil : NSObject


@property (nonatomic, assign, readonly) YPNetworkStatus netWorkStatus;

@property (nonatomic, copy) YPNetworkChangeBlock networkChangeBlock;

+ (YPNetworkUtil *)sharedInstance;

/// net status,if wifi&wwan return wifi
- (YPNetworkStatus)checkNetworkStatus;

/// fetch wifi SSID info
- (NSString *)fetchCurrentConnectWifiInfo;

/// start monitoring
- (void)startWifiReach:(YPNetworkChangeBlock)statusChanged;

/// stop monitoring,if not need notif,please stop it
- (void)stopWifiReach;

/// carrier info
- (NSString *)getCarrier;

@end

NS_ASSUME_NONNULL_END
