//
//  YPNetworkSession.m
//  YPItools
//
//  Created by qipeng_yuhao on 2020/1/10.
//  Copyright © 2020 qipeng_yuhao. All rights reserved.
//

#import "YPNetworkSession.h"

@implementation YPNetworkSession

+ (void)dataTaskSessionAsynch:(NSString *)urlStr Parameter:(NSDictionary *)parameter HttpMethod:(NSString *)httpMethod HttpHeaderFields:(NSDictionary *)headerFields Timeout:(float)timeout Success:(void(^)(NSData * _Nullable data))success Faile:(void(^)(NSError *error))faile{
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeout>0?timeout:0];
    mutableRequest.HTTPMethod = httpMethod?httpMethod:@"GET";
    if (headerFields) {
        mutableRequest.allHTTPHeaderFields = headerFields;
    }
    if (parameter) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:parameter options:(NSJSONWritingOptions)0 error:nil];
        mutableRequest.HTTPBody = data;
    }
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.networkServiceType = NSURLNetworkServiceTypeDefault;
    
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    [[urlSession dataTaskWithRequest:mutableRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            faile(error);
        }else{
            success(data);
        }
    }] resume];
}


+ (BOOL)dataTaskSessionSynch:(NSString *)urlStr Parameter:(NSDictionary *)parameter HttpMethod:(NSString *)httpMethod HttpHeaderFields:(NSDictionary *)headerFields Timeout:(float)timeout{
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeout>0?timeout:0];
    mutableRequest.HTTPMethod = httpMethod?httpMethod:@"GET";
    if (headerFields) {
        mutableRequest.allHTTPHeaderFields = headerFields;
    }
    if (parameter) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:parameter options:(NSJSONWritingOptions)0 error:nil];
        mutableRequest.HTTPBody = data;
    }
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.networkServiceType = NSURLNetworkServiceTypeDefault;
    
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    dispatch_semaphore_t semaphoreT = dispatch_semaphore_create(0);
    __block BOOL isSuccess = NO;
    [[urlSession dataTaskWithRequest:mutableRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        isSuccess = error?NO:YES;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_semaphore_signal(semaphoreT);
        });

       }] resume];

    dispatch_semaphore_wait(semaphoreT, DISPATCH_TIME_FOREVER);
    
    return isSuccess;
}

@end
