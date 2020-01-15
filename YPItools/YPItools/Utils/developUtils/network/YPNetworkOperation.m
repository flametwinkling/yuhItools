//
//  YPNetworkOperation.m
//  YPItools
//
//  Created by qipeng_yuhao on 2020/1/10.
//  Copyright © 2020 qipeng_yuhao. All rights reserved.
//

#import "YPNetworkOperation.h"

#define kYPNetworkOperationRequestTimeOutInSeconds 30

@interface YPNetworkOperation () <NSURLConnectionDataDelegate, NSURLConnectionDelegate>
{
@private
    YPNetworkOperationState networkState_;
}

@property (nonatomic, assign) BOOL isCancelled;                       //是否取消
@property (nonatomic, assign) YPNetworkOperationState networkState;  //网络操作状态
@property (nonatomic, strong) NSMutableURLRequest *request;           //网络请求
@property (nonatomic, strong) NSURLConnection *connection;            //网络连接
@property (nonatomic, strong) NSMutableDictionary *fieldsToBePostDic; //传递的参数

@property (nonatomic, strong) NSMutableArray *responseBlocks;                        //正确响应回调
@property (nonatomic, strong) NSMutableArray *errorBlocks;                           //错误回调
@property (nonatomic, copy) YPNetworkPostDataEncodingBlock postDataEncodingHandler; //自定义的数据编码
@property (nonatomic, strong) NSMutableData *mutableData;                            //返回数据
@property (nonatomic, strong) NSData *customPostData;                                //自定义请求数据
@end

@implementation YPNetworkOperation

#pragma mark - public method
- (instancetype)initWithUrlString:(NSString *)urlString params:(NSDictionary *)params httpMethod:(NSString *)method {
    if (self = [super init]) {
        self.responseBlocks = [NSMutableArray array];
        self.errorBlocks = [NSMutableArray array];
        self.stringEncoding = NSUTF8StringEncoding;
        if (params) {
            self.fieldsToBePostDic = [params mutableCopy];
        }
        if (!method) {
            method = @"GET";
        }
        NSURL *finalURL = nil;
        if ([method isEqualToString:@"GET"] && (params && [params count] > 0)) {
            finalURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", urlString, [self urlEncodedWithDic:params]]];
        } else {
            finalURL = [NSURL URLWithString:urlString];
        }
        self.request = [NSMutableURLRequest requestWithURL:finalURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kYPNetworkOperationRequestTimeOutInSeconds];
        [self.request setHTTPMethod:method];
        // 设置post类型数据默认传输 json格式
        if ([method isEqualToString:@"POST"] && (params && [params count] > 0)) {
            self.postDataContentType = YPNetworkPostDataContentTypeJSON;
        }
        self.networkState = YPNetworkOperationStateReady;
    }
    return self;
}

- (void)addCompleteHandler:(YPNetworkResponseBlock)response errorHandler:(YPNetworkErrorBlcok)error {
    if (response) {
        [self.responseBlocks addObject:response];
    }
    if (error) {
        [self.errorBlocks addObject:error];
    }
}

- (void)addHeaders:(NSDictionary *)headers {
    [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self.request addValue:obj forHTTPHeaderField:key];
    }];
}

- (void)addCustomPostData:(NSData *)data {
    self.customPostData = data;
}
- (NSData *)responseData {
    if ([self isFinished]) {
        return self.mutableData;
    } else {
        return nil;
    }
}

- (NSString *)responseString {
    return [[NSString alloc] initWithData:[self responseData] encoding:self.stringEncoding];
}

- (NSDictionary *)responseHeaders {
    if ([self isFinished]) {
        return [self.response allHeaderFields];
    } else {
        return nil;
    }
}
#pragma mark - request params

// 请求数据编码
- (NSData *)bodyData {
    if (self.customPostData) {
        return self.customPostData;
    } else {
        return [[self encodedPostDataString] dataUsingEncoding:self.stringEncoding];
    }
}

- (NSString *)encodedPostDataString {
    NSString *result = @"";
    if (self.postDataEncodingHandler) {
        result = self.postDataEncodingHandler(self.fieldsToBePostDic);
    } else if (self.postDataContentType == YPNetworkPostDataContentTypeURL) {
        [self.request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        result = [self urlEncodedWithDic:self.fieldsToBePostDic];
    } else if (self.postDataContentType == YPNetworkPostDataContentTypeJSON) {
        [self.request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        result = [self jsonEncodedWithDic:self.fieldsToBePostDic];
    } else if (self.postDataContentType == YPNetworkPostDataContentTypePlist) {
        [self.request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
        result = [self plistEncodedWithDic:self.fieldsToBePostDic];
    }
    NSLog(@"req json = %@", result);
    return result;
}

// get 参数创建
- (NSString *)urlEncodedWithDic:(NSDictionary *)params {
    NSMutableString *result = [NSMutableString string];
    for (NSString *key in params.allKeys) {
        NSObject *value = [params objectForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            [result appendFormat:@"%@=%@&", [self urlEncodedString:key], [self urlEncodedString:((NSString *) value)]];
        } else {
            [result appendFormat:@"%@=%@&", [self urlEncodedString:key], value];
        }
    }
    return result;
}

- (NSString *)urlEncodedString:(NSString *)string {
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CFStringRef encodedCFString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                          (__bridge CFStringRef) string,
                                                                          nil,
                                                                          CFSTR("?!@#$^&%*+,:;='\"`<>()[]{}/\\| "),
                                                                          kCFStringEncodingUTF8);
#pragma clang diagnostic pop
    
    NSString *encodedString = [[NSString alloc] initWithString:(__bridge_transfer NSString *) encodedCFString];
    
    if (!encodedString)
        encodedString = @"";
    
    return encodedString;
}

// JSON 编码格式
- (NSString *)jsonEncodedWithDic:(NSDictionary *)params {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    if (error) {
        NSLog(@"[jsonEncodedWithDic] Json parsing error: %@", error);
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

// plist xml 编码格式
- (NSString *)plistEncodedWithDic:(NSDictionary *)params {
    NSError *error = nil;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:params format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    if (error) {
        NSLog(@"[plistEncodedWithDic] plist parsing error: %@", error);
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - custom operation

- (void)main {
    @autoreleasepool {
        [self start];
    }
}

- (void)start {
    if (!self.isCancelled) {
        if ([self.request.HTTPMethod isEqualToString:@"POST"]) {
            [self.request setHTTPBody:[self bodyData]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
#pragma clang diagnostic pop
            [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                       forMode:NSRunLoopCommonModes];
            [self.connection start];
        });
        self.networkState = YPNetworkOperationStateExecuting;
    } else {
        self.networkState = YPNetworkOperationStateFinished;
    }
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isReady {
    return (networkState_ == YPNetworkOperationStateReady && [super isReady]);
}

- (BOOL)isExecuting {
    return (networkState_ == YPNetworkOperationStateExecuting);
}

- (BOOL)isFinished {
    return (networkState_ == YPNetworkOperationStateFinished);
}

- (void)cancel {
    if ([self isFinished]) {
        return;
    }
    @synchronized(self) {
        //TODO 清理资源变量
        self.isCancelled = YES;
        networkState_ = YPNetworkOperationStateFinished;
    }
    [super cancel];
}

// KVO KVC 处理

- (YPNetworkOperationState)networkState {
    return networkState_;
}

- (void)setNetworkState:(YPNetworkOperationState)newState {
    switch (newState) {
        case YPNetworkOperationStateReady:
            [self willChangeValueForKey:@"isReady"];
            break;
        case YPNetworkOperationStateExecuting:
            [self willChangeValueForKey:@"isReady"];
            [self willChangeValueForKey:@"isExecuting"];
            break;
        case YPNetworkOperationStateFinished:
            [self willChangeValueForKey:@"isExecuting"];
            [self willChangeValueForKey:@"isFinished"];
            break;
    }
    
    networkState_ = newState;
    
    switch (newState) {
        case YPNetworkOperationStateReady:
            [self didChangeValueForKey:@"isReady"];
            break;
        case YPNetworkOperationStateExecuting:
            [self didChangeValueForKey:@"isReady"];
            [self didChangeValueForKey:@"isExecuting"];
            break;
        case YPNetworkOperationStateFinished:
            [self didChangeValueForKey:@"isExecuting"];
            [self didChangeValueForKey:@"isFinished"];
            break;
    }
    
}
#pragma mark - operation callback
- (void)operationFailedWithError:(NSError *)error {
    for (YPNetworkErrorBlcok errorBlock in self.errorBlocks) {
        if (errorBlock) {
            errorBlock(self,error);
        }
    }
}

- (void)operationSucceed {
    for (YPNetworkResponseBlock responseBlock in self.responseBlocks) {
        if (responseBlock) {
            responseBlock(self);
        }
    }
}
#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    //使用系统默认方式验证trust object
    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
        NSString *host = [self.request valueForHTTPHeaderField:@"host"];
        if (!host) {
            host = self.request.URL.host;
        }
        NSMutableArray *policies = [NSMutableArray array];
        SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
        if (host) {
            [policies addObject:(__bridge_transfer id) SecPolicyCreateSSL(true, (__bridge CFStringRef) host)];
        } else {
            //标准 509
            [policies addObject:(__bridge_transfer id) SecPolicyCreateBasicX509()];
        }
        //1)绑定校验策略到服务端的证书上
        SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef) policies);
        SecTrustResultType result;
        
        //2)SecTrustEvaluate对trust进行验证
        OSStatus status = SecTrustEvaluate(serverTrust, &result);
        if (status == errSecSuccess && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:serverTrust] forAuthenticationChallenge:challenge];
        } else {
            [challenge.sender cancelAuthenticationChallenge:challenge];
        }
    } else {
        [challenge.sender cancelAuthenticationChallenge:challenge];
    }
}
// 连接错误
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.networkState = YPNetworkOperationStateFinished;
    [self operationFailedWithError:error];
}
// 第一次收到响应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.mutableData = [[NSMutableData alloc] init];
    self.response = (NSHTTPURLResponse *) response;
}
// 收到数据，可能是分段发送过来的
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.mutableData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if ([self isCancelled]) {
        return;
    }
    self.networkState = YPNetworkOperationStateFinished;
    if (self.response.statusCode >= 200 && self.response.statusCode <= 300) {
        [self operationSucceed];
    } else {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:self.response.statusCode userInfo:self.response.allHeaderFields];
        [self operationFailedWithError:error];
    }
}

@end
