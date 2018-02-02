//
//  NSObject+Property.m
//  Runtime
//
//  Created by iosyf-02 on 2018/2/2.
//  Copyright © 2018年 情风. All rights reserved.
//

#import "NSObject+Property.h"
#import <objc/runtime.h>

static const char *key = "propertyName";

@implementation NSObject (Property)
- (NSString *)propertyName {
    return objc_getAssociatedObject(self, key);
}

- (void)setPropertyName:(NSString *)propertyName {
    objc_setAssociatedObject(self, key, propertyName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (void)printDic:(NSDictionary *)dic {
    
    // 拼接属性字符串代码
    NSMutableString *strM = [NSMutableString string];
    
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *type;//类型
        if ([obj isKindOfClass:NSClassFromString(@"__NSCFString")]) {
            type = @"NSString";
        } else if ([obj isKindOfClass:NSClassFromString(@"__NSCFArray")]) {
            type = @"NSArray";
        } else if ([obj isKindOfClass:NSClassFromString(@"__NSCFNumber")]) {
            type = @"NSInteger";
        } else if ([obj isKindOfClass:NSClassFromString(@"__NSDictionaryI")]) {
            type = @"NSDictionary";
        }
        
        //属性字符串
        NSString *str;
        if (![type isEqualToString:@"NSInteger"]) {
            str = [NSString stringWithFormat:@"@property (nonatomic, strong) %@ *%@;",type,key];
        } else {
            str = [NSString stringWithFormat:@"@property (nonatomic, assign) %@ %@;",type,key];
        }
        
        // 每生成属性字符串，就自动换行。
        [strM appendFormat:@"\n%@\n",str];
    }];
    
    NSLog(@"%@",strM);
}
@end
