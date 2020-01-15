//
//  YPNetworkOperation.h
//  YPItools
//
//  Created by qipeng_yuhao on 2020/1/10.
//  Copyright © 2020 qipeng_yuhao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class YPNetworkOperation;
// 网络操作状态
typedef NS_ENUM(NSInteger,YPNetworkOperationState){
    YPNetworkOperationStateReady = 1,
    YPNetworkOperationStateExecuting = 2,
    YPNetworkOperationStateFinished = 3
};

// 数据传输类型
typedef enum : NSUInteger {
    YPNetworkPostDataContentTypeURL = 0,
    YPNetworkPostDataContentTypeJSON,
    YPNetworkPostDataContentTypePlist,
    YPNetworkPostDataContentTypeCustom
} YPNetworkPostDataContentType;

// 定义回调block
typedef void(^YPNetworkResponseBlock)(YPNetworkOperation * completedOperation);
typedef void(^YPNetworkErrorBlcok)(YPNetworkOperation * completedOperation, NSError *error);

// 自定义数据编码block
typedef NSString *_Nullable(^YPNetworkPostDataEncodingBlock)(NSDictionary *postDataDic);

@interface YPNetworkOperation : NSOperation

@property (nonatomic, assign) YPNetworkPostDataContentType postDataContentType;   //数据传输组装类型
@property (nonatomic, assign) NSStringEncoding stringEncoding;                     //数据传输编码格式
@property (nonatomic, strong) NSHTTPURLResponse *response;                           //http response


- (instancetype)initWithUrlString:(NSString *)urlString params:(NSDictionary *)params httpMethod:(NSString *)method;
- (void)addCompleteHandler:(YPNetworkResponseBlock)response errorHandler:(YPNetworkErrorBlcok)error;
- (void)addHeaders:(NSDictionary *)headers;
- (void)addCustomPostData:(NSData *)data;
- (NSData *)responseData;
- (NSString *)responseString;
- (NSDictionary *)responseHeaders;

@end
NS_ASSUME_NONNULL_END
