//
//  YPJsonEngine.h
//  YPItools
//
//  Created by qipeng_yuhao on 2020/1/15.
//  Copyright © 2020 qipeng_yuhao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YPJsonEngine : NSObject


/// notice: return value is read by jsonformat,encode is utf-8
/// @param dic any dictionary
+ (NSString *)jsonStringFromDic:(NSDictionary *)dic;

+ (NSData *)jsonDataFromDictionary:(NSDictionary *)dictionary;
+ (NSString *)jsonStringFromArray:(NSArray *)array;

/// notice: id maybe is dic or array,options is NSJSONReadingAllowFragments
/// @param jsonData response data
+ (id)objectFromJsonData:(NSData *)jsonData;
+ (id)objectFromJsonString:(NSString *)aJsonString;

@end

NS_ASSUME_NONNULL_END
