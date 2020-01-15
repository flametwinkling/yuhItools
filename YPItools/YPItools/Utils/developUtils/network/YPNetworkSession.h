//
//  YPNetworkSession.h
//  YPItools
//
//  Created by qipeng_yuhao on 2020/1/10.
//  Copyright © 2020 qipeng_yuhao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YPNetworkSession : NSObject

+ (void)dataTaskSessionAsynch:(NSString *)urlStr Parameter:(NSDictionary *)parameter HttpMethod:(NSString *)httpMethod HttpHeaderFields:(NSDictionary *)headerFields Timeout:(float)timeout Success:(void(^)(NSData * _Nullable data))success Faile:(void(^)(NSError *error))faile;

+ (BOOL)dataTaskSessionSynch:(NSString *)urlStr Parameter:(NSDictionary *)parameter HttpMethod:(NSString *)httpMethod HttpHeaderFields:(NSDictionary *)headerFields Timeout:(float)timeout;

@end

NS_ASSUME_NONNULL_END
