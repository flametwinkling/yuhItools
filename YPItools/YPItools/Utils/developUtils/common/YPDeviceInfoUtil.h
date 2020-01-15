//
//  YPDeviceInfoUtil.h
//  YPItools
//
//  Created by qipeng_yuhao on 2020/1/15.
//  Copyright © 2020 qipeng_yuhao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YPDeviceInfoUtil : NSObject

+ (NSString *)retrivePhoneMode;     //手机型号
+ (NSString *)retriveOSVersion;     //手机系统版本
+ (NSString *)retriveBundleId;     //boundleid
+ (NSString *)retriveAppVersion;   //APP版本号
+ (NSNumber *)retriveAppVersionCode;
+ (NSString *)retriveIDFA; //IDFA
+ (NSString *)retriveAppName;  //APP名字

@end

NS_ASSUME_NONNULL_END
