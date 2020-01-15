//
//  YPDeviceInfoUtil.m
//  YPItools
//
//  Created by qipeng_yuhao on 2020/1/15.
//  Copyright © 2020 qipeng_yuhao. All rights reserved.
//

#import "YPDeviceInfoUtil.h"
#import <UIKit/UIDevice.h>
#include <sys/sysctl.h>

@implementation YPDeviceInfoUtil

#pragma mark - public method
+ (NSString *)retrivePhoneMode {
    return [self getSysInfoByName:"hw.machine"];
}

+ (NSString *)retriveBundleId {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleId = [infoDictionary objectForKey:@"CFBundleIdentifier"];
    return bundleId;
}

+ (NSString *)retriveOSVersion {
    NSString *sysversion = [[UIDevice currentDevice] systemVersion];
    return sysversion;
}

+ (NSString *)retriveAppVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSNumber *)retriveAppVersionCode {
    NSString *vc = [self retriveAppVersion];
    NSLog(@"dd:%@",vc);
    NSArray *array = [vc componentsSeparatedByString:@"."];
    NSInteger f = 0;
    NSInteger s = 0;
    NSInteger t = 0;
    switch (array.count) {
        case 3:
            f = [array[0] integerValue];
            s = [array[1] integerValue];
            t = [array[2] integerValue];
            break;
        case 2:
            f = [array[0] integerValue];
            s = [array[1] integerValue];
            break;
        case 1:
            f = [array[0] integerValue];
            break;
    }
    if (f >= 1000) {
        NSInteger quotient = f / 10;
        NSInteger remainder = f % 10;
        f = remainder + quotient;
    }
    NSInteger result = f * 1000000 + s * 1000 + t;
    return [NSNumber numberWithInteger:result];
}
#pragma mark - private method
+ (NSString *)getSysInfoByName:(char *)typeSpecifier {
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding:NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

+ (NSString *)retriveIDFA {
    
    NSUUID *uuid = nil;
    
    @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        Class class = NSClassFromString(@"ASIdentifierManager");
        SEL sel = NSSelectorFromString(@"sharedManager");
        if (class && [class respondsToSelector:sel]) {
            id objc = [class performSelector:NSSelectorFromString(@"sharedManager")];
            uuid = [objc performSelector:NSSelectorFromString(@"advertisingIdentifier")];
            return uuid ? [uuid UUIDString] : @"";
        } else {
            return @"";
        }
#pragma clang diagnostic pop
    }
    @catch (NSException *exception) {
        return @"";
    }
}

+ (NSString *)retriveAppName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

@end
