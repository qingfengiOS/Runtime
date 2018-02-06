//
//  Person.h
//  Runtime
//
//  Created by iosyf-02 on 2018/2/2.
//  Copyright © 2018年 情风. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "score.h"
#import "subject.h"

@interface Person : NSObject
/// 名字
@property (nonatomic, copy) NSString *name;

/// 年龄
@property (nonatomic, copy) NSString *age;

@property (nonatomic, strong) score *score;

@property (nonatomic, strong) NSArray <subject*>*subjectArray;

- (void)run;

- (void)study;

+ (void)firstClassMethod;
+ (void)secondClassMethod;
@end
