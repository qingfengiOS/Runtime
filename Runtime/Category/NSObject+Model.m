//
//  NSObject+Model.m
//  Runtime
//
//  Created by iosyf-02 on 2018/2/2.
//  Copyright © 2018年 情风. All rights reserved.
//

#import "NSObject+Model.h"
#import <objc/runtime.h>

@implementation NSObject (Model)

+ (instancetype)modelByDic:(NSDictionary *)dic {
    
    id object = [[self alloc]init];
    
    unsigned int count;
    
    //获取所有成员属性
    Ivar *ivarList = class_copyIvarList(self, &count);
    
    for (int i = 0; i < count; i++) {//根据下标，从数组中取出对应成员属性
        Ivar ivar = ivarList[i];
        
        //获取成员属性名
        NSString *name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        // 处理成员属性名->字典中的key,里面包含了一个下划线，从第一个角标开始截取
        NSString *key = [name substringFromIndex:1];
        
        id value = dic[key];
        
        // 二级转换:如果字典中还有字典，也需要把对应的字典转换成模型
        if ([value isKindOfClass:[NSDictionary class]]) {
            //字典转model
            NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
            
            //处理生成的转义字符串(获取两个转义字符串中间实际的值)
            NSRange range = [type rangeOfString:@"\""];
            
            type = [type substringFromIndex:range.location + range.length];
            
            range = [type rangeOfString:@"\""];
            
            type = [type substringToIndex:range.location];
            
            //生成类对象
            Class modelClass = NSClassFromString(type);
            
            if (modelClass) {
                value = [modelClass modelByDic:value];
            }
        }
        
        //三级转换，把数组中的字典转换成模型.
        if ([value isKindOfClass:[NSArray class]]) {
            if ([self respondsToSelector:@selector(arrayContainModelClass)]) {
                
                // 转换成id类型，就能调用任何对象的方法
                id idSelf = self;
                
                // 获取数组中字典对应的模型
                NSString *type = [idSelf arrayContainModelClass][key];
                // 生成模型
                Class classModel = NSClassFromString(type);
                
                NSMutableArray *modelArray = [NSMutableArray array];
                
                for (NSDictionary *everyDic in value) {
                    id model = [classModel modelByDic:everyDic];
                    [modelArray addObject:model];
                }
                value = modelArray;
            }
        }
        
        [object setValue:value forKey:key];
    
    }
    return object;
}

+ (id)arrayContainModelClass {
    
    NSMutableDictionary *dictM = [[NSMutableDictionary alloc] init];
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for(int i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        
        NSString *key = [NSString stringWithFormat:@"%s", property_getName(property)];
        NSString *value = [NSString stringWithFormat:@"%s", property_getAttributes(property)];
        
        // 裁剪
        NSRange range = [value rangeOfString:@"\""];
        value = [value substringFromIndex:range.location + range.length];
        range = [value rangeOfString:@"\""];
        value = [value substringToIndex:range.location];
        
        [dictM setValue:value forKey:key];
        
    }
    free(properties);
    return dictM;
}
@end
