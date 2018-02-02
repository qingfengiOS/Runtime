//
//  ViewController.m
//  Runtime
//
//  Created by iosyf-02 on 2018/2/2.
//  Copyright © 2018年 情风. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"

#import <objc/runtime.h>
#import <objc/message.h>

#import "NSObject+Property.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self instanceMethodExchange];
    
    [self calssMethodExchange];
    
    [self getIvarList];
    
    [self addPropertyForCategory];
    
    [self printDic];
}

/**
 实例方法交换
 */
- (void)instanceMethodExchange {
    Person *p = [[Person alloc]init];
    p.name = @"张三";
    p.age = 18;
    
    [p run];
    [p study];
    
    Method m = class_getInstanceMethod([p class], @selector(run));
    Method m2 = class_getInstanceMethod([p class], @selector(study));
    
    method_exchangeImplementations(m, m2);
    
    NSLog(@"................分割线................");
    [p run];
    [p study];
}

/**
 类方法交换
 */
- (void)calssMethodExchange {
    
    [Person firstClassMethod];
    [Person secondClassMethod];
    
    Method m = class_getClassMethod([Person class], @selector(firstClassMethod));
    Method m2 = class_getClassMethod([Person class], @selector(secondClassMethod));
    
    method_exchangeImplementations(m, m2);
    
    NSLog(@"................分割线................");
    [Person firstClassMethod];
    [Person secondClassMethod];
    
}


/**
 获取成员变量
 */
- (void)getIvarList {
    NSLog(@"................分割线................");
    // 成员变量的数量
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([Person class], &count);
    // 遍历所有的成员变量
    for (int i = 0 ; i < count; i++) {
        // 取出i位置对应的成员变量
        Ivar ivar = ivars[i];
        NSLog(@"%s    %s",ivar_getName(ivar),ivar_getTypeEncoding(ivar));
        
    }
}


/**
 通过字典定义属性
 */
- (void)addPropertyForCategory {
    NSLog(@"................分割线................");
    NSObject *obj = [[NSObject alloc]init];
    obj.propertyName = @"添加属性的名字";
    NSLog(@"%@",obj.propertyName);
}

- (void)printDic {
    NSLog(@"................分割线................");
    NSDictionary *testDic = @{@"name" : @"情风",
                              @"age" : @(18),
                              @"score" : @{@"chinese" : @(90),@"math" : @"100"},
                              };
    [NSObject printDic:testDic];
    
}

@end


