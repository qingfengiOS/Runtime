//
//  Person.m
//  Runtime
//
//  Created by iosyf-02 on 2018/2/2.
//  Copyright © 2018年 情风. All rights reserved.
//

#import "Person.h"

@implementation Person
- (void)run {
    NSLog(@"runing...");
}

- (void)study {
    NSLog(@"studying...");
}

+ (void)firstClassMethod {
    NSLog(@"this is firstClassMethod");
}
+ (void)secondClassMethod {
    NSLog(@"this is secondClassMethod");
}

@end
