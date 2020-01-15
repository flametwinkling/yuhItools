//
//  YPNetworkEngine.m
//  YPItools
//
//  Created by qipeng_yuhao on 2020/1/10.
//  Copyright © 2020 qipeng_yuhao. All rights reserved.
//

#import "YPNetworkEngine.h"

@interface YPNetworkEngine()
@property (nonatomic, copy) NSString *hostName;
@property (nonatomic, strong) NSDictionary *headers;
@end

// 创建一个唯一的队列,管理所有的网络操作
static NSOperationQueue *_shareNetworkQueue;

@implementation YPNetworkEngine

+ (void)initialize{
    if (!_shareNetworkQueue) {
        _shareNetworkQueue = [[NSOperationQueue alloc] init];
        [_shareNetworkQueue setMaxConcurrentOperationCount:6];
    }
}

- (instancetype)init{
    return [self initWithHostName:nil headers:nil];
}

- (instancetype)initWithHostName:(NSString *)host headers:(NSDictionary *)headers{
    if (self = [super init]) {
        self.hostName = host;
        self.headers = headers;
    }
    return self;
}

- (YPNetworkOperation *)operationWithPath:(NSString *)path params:(NSDictionary *)bodyDic httpMothod:(NSString *)method{
    if (self.hostName == nil) {
        NSLog(@"[operationWithPath] hostName is nil");
        return nil;
    }
    NSString *urlString = self.hostName;
    if (path) {
        urlString = [NSString stringWithFormat:@"%@/%@",self.hostName,path];
    }
    NSLog(@"request url String : %@",urlString);
    YPNetworkOperation *operation = [[YPNetworkOperation alloc] initWithUrlString:urlString params:bodyDic httpMethod:method];
    [operation addHeaders:self.headers];
    return operation;
}

- (void)enqueueOperation:(YPNetworkOperation *)operation{
    if (operation == nil) {
        NSLog(@"[enqueueOperation] operation cannot be nil");
        return;
    }
    [_shareNetworkQueue addOperation:operation];
}


@end
