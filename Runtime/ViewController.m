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
#import "NSObject+Model.h"
#import "subject.h"
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
    
    [self dicToModel];
}

#pragma mark - 方法交换
/**
 实例方法交换
 */
- (void)instanceMethodExchange {
    Person *p = [[Person alloc]init];
    p.name = @"张三";
    p.age = @"18";
    
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

#pragma mark - 获取成员变量
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

#pragma mark - 给分类添加属性
/**
 通过定义属性
 */
- (void)addPropertyForCategory {
    NSLog(@"................分割线................");
    NSObject *obj = [[NSObject alloc]init];
    obj.propertyName = @"添加属性的名字";
    NSLog(@"%@",obj.propertyName);
}

#pragma mark - 通过字典生成属性字符串
/**
 通过字典生成属性字符串
 */
- (void)printDic {
    NSLog(@"................分割线................");
    NSDictionary *testDic = @{@"name" : @"情风",
                              @"age" : @(18),
                              @"score" : @{@"chinese" : @(90),@"math" : @"100"},
                              };
    [NSObject printDic:testDic];
    
    
    
}

- (void)dicToModel {
    NSLog(@"................分割线................");
    NSDictionary *testDic = @{@"name" : @"情风",
                              @"age" : @"18",
                              @"score" : @{@"chinese" : @(90),@"math" : @"100"},
                              @"subjectArray" : @[@{@"subjectName":@"体育",@"option":@"1"},@{@"subjectName":@"外语",@"option":@"0"},@{@"subjectName":@"美术",@"option":@"1"},],
                              };
    
    Person *person = [Person modelByDic:testDic];
    
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSDictionary *dic in testDic[@"subjectArray"]) {
        subject *s = [subject modelByDic:dic];
        [tempArray addObject:s];
    }
    person.subjectArray = [NSArray arrayWithArray:tempArray];
    
    NSLog(@"%@-%ld-%@-%ld-%@",person.name,(long)person.age,person.score.math,person.score.chinese,person.subjectArray);
}

@end


