//
//  NSObject+Property.h
//  Runtime
//
//  Created by iosyf-02 on 2018/2/2.
//  Copyright © 2018年 情风. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Property)

@property (nonatomic, copy) NSString *propertyName;

+ (void)printDic:(NSDictionary *)dic;

@end
