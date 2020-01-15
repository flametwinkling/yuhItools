//
//  YPJsonEngine.m
//  YPItools
//
//  Created by qipeng_yuhao on 2020/1/15.
//  Copyright © 2020 qipeng_yuhao. All rights reserved.
//

#import "YPJsonEngine.h"

@implementation YPJsonEngine

+ (NSString *)jsonStringFromDic:(NSDictionary *)dic{
    if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    @try {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:&error];
        if (!jsonData || error) {
            
            return nil;
        }
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (jsonString) {
            return jsonString;
        }
    }
    @catch (NSException *exception) {
        
    }
    
    return nil;

}
+ (NSData *)jsonDataFromDictionary:(NSDictionary *)dictionary{
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    @try {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&error];
        if (!jsonData || error) {
            
            return nil;
        }
        
        return jsonData;
    }
    @catch (NSException *exception) {
        
    }
    
    return nil;

}
+ (NSString *)jsonStringFromArray:(NSArray *)array{
    if (!array || ![array isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    @try {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:kNilOptions error:&error];
        if (!jsonData || error) {
            
            return nil;
        }
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (jsonString) {
            return jsonString;
        }
    }
    @catch (NSException *exception) {
        
    }
    
    return nil;

}
+ (id)objectFromJsonData:(NSData *)jsonData{
    if (!jsonData || ![jsonData isKindOfClass:[NSData class]]) {
        return nil;
    }
    
    @try {
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        if (!jsonObject || error) {
            
            return nil;
        }
        return jsonObject;
    }
    @catch (NSException *exception) {
        
    }
    
    return nil;

}

+ (id)objectFromJsonString:(NSString *)aJsonString{
    if (!aJsonString || ![aJsonString isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    @try {
        NSString *jsonString = [aJsonString stringByReplacingOccurrencesOfString:@"\":null" withString:@"\":\"\""];
        
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        if (!jsonData) {
            return nil;
        }
        
        NSError *error = nil;
        
        
        id jsonObject = [self objectFromJsonData:jsonData];
        if (!jsonObject || error) {
            
            return nil;
        }
        return jsonObject;
    }
    @catch (NSException *exception) {
        
    }
    
    return nil;
}

@end
