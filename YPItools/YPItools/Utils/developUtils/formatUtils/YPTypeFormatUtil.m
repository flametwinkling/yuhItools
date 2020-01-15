//
//  YPTypeFormatUtil.m
//  YPItools
//
//  Created by qipeng_yuhao on 2020/1/15.
//  Copyright © 2020 qipeng_yuhao. All rights reserved.
//

#import "YPTypeFormatUtil.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation YPTypeFormatUtil

+ (instancetype)modelWithDict:(NSDictionary *)dict
{
    id objc = [[self alloc] init];
    
    unsigned int count = 0;
    
    Ivar *ivarList = class_copyIvarList(self, &count);
    
    for (int i = 0; i < count; i++) {
        
        // 实例变量
        Ivar ivar = ivarList[i];
        
        // 获取成员属性名
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        NSString *key = [ivarName substringFromIndex:1];
        
        id value = dict[key];
        if (value == nil) {
            continue;
        }
        
        // 获得成员变量的类型
        NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        NSLog(@"ivar - %@, type - %@", ivarName, ivarType);
        ivarType = [ivarType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        ivarType = [ivarType stringByReplacingOccurrencesOfString:@"@" withString:@""];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            
            Class modelClass = NSClassFromString(ivarType);
            value = [modelClass modelWithDict:value];
            
        } else if ([value isKindOfClass:[NSArray class]]) {

//            if ([self respondsToSelector:@selector(arrayContainModelClass)]) {
//
//                NSString *type = [dict arrayContainModelClass][key];
//                Class classModel = NSClassFromString(type);
//                NSMutableArray *arrM = [NSMutableArray array];
//                for (NSDictionary *dict in value) {
//                    id model =  [classModel modelWithDict:dict];
//                    if (model) {
//                        [arrM addObject:model];
//                    }
//                }
//
//                value = arrM;
//            }
        }

        if (value) {
            [objc setValue:value forKey:key];
        }
    }
    
    return objc;
}

+ (NSDictionary *)dictWithModel:(NSObject *)object {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int count;
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        objc_property_t property = propertyList[i];
        const char *cName = property_getName(property);
        NSString *name = [NSString stringWithUTF8String:cName];
        NSObject *value = [object valueForKey:name]; //valueForKey返回的数字和字符串都是对象
        
        if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
            //string , bool, int ,NSinteger
            [dic setObject:value forKey:name];
            
        } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
            //字典或字典
            [dic setObject:[self arrayOrDicWithObject:(NSArray *) value] forKey:name];
            
        } else if (value == nil) {
            //null
            //[dic setObject:[NSNull null] forKey:name];//这行可以注释掉?????
            
        } else {
            //model
            [dic setObject:[self dictWithModel:value] forKey:name];
        }
    }
    free(propertyList);
    return [dic copy];
}

//将可能存在model数组转化为普通数组
+ (id)arrayOrDicWithObject:(id)origin {
    if ([origin isKindOfClass:[NSArray class]]) {
        //数组
        NSMutableArray *array = [NSMutableArray array];
        for (NSObject *object in origin) {
            if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
                //string , bool, int ,NSinteger
                [array addObject:object];
                
            } else if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]]) {
                //数组或字典
                [array addObject:[self arrayOrDicWithObject:(NSArray *) object]];
                
            } else {
                //model
                [array addObject:[self dictWithModel:object]];
            }
        }
        
        return [array copy];
        
    } else if ([origin isKindOfClass:[NSDictionary class]]) {
        //字典
        NSDictionary *originDic = (NSDictionary *) origin;
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        for (NSString *key in originDic.allKeys) {
            id object = [originDic objectForKey:key];
            
            if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
                //string , bool, int ,NSinteger
                [dic setObject:object forKey:key];
                
            } else if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]]) {
                //数组或字典
                [dic setObject:[self arrayOrDicWithObject:object] forKey:key];
                
            } else {
                //model
                [dic setObject:[self dictWithModel:object] forKey:key];
            }
        }
        
        return [dic copy];
    }
    
    return [NSNull null];
}

@end
