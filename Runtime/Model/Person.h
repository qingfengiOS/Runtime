//
//  Person.h
//  Runtime
//
//  Created by iosyf-02 on 2018/2/2.
//  Copyright © 2018年 情风. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject
/// 名字
@property (nonatomic, strong) NSString *name;

/// 年龄
@property (nonatomic, assign) NSInteger age;

- (void)run;

- (void)study;

+ (void)firstClassMethod;
+ (void)secondClassMethod;
@end
