//
//  YPNetworkEngine.h
//  YPItools
//
//  Created by qipeng_yuhao on 2020/1/10.
//  Copyright © 2020 qipeng_yuhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YPNetworkOperation.h"


@interface YPNetworkEngine : NSObject

- (instancetype)initWithHostName:(NSString *)host
                         headers:(NSDictionary *)headers;

- (YPNetworkOperation *) operationWithPath:(NSString *)path
                                    params:(NSDictionary *)bodyDic
                                httpMothod:(NSString *)method;

- (void)enqueueOperation:(YPNetworkOperation *)operation;

@end

