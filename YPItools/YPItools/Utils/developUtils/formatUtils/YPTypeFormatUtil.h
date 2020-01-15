//
//  YPTypeFormatUtil.h
//  YPItools
//
//  Created by qipeng_yuhao on 2020/1/15.
//  Copyright © 2020 qipeng_yuhao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YPTypeFormatUtil : NSObject

//字典转模型
+ (instancetype)modelWithDict:(NSDictionary *)dict;

//模型转字典
+ (NSDictionary *)dictWithModel:(NSObject *)object;

@end

NS_ASSUME_NONNULL_END
