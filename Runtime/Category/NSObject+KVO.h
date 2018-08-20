//
//  NSObject+KVO.h
//  Runtime
//
//  Created by 情风 on 2018/8/20.
//  Copyright © 2018年 情风. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ObservingBlock)(id object, NSString *observerKey, id oldValue, id newValue);

@interface NSObject (KVO)

- (void)qf_addObserver:(NSObject *)observer
                forKey:(NSString *)key
             withBlock:(ObservingBlock)block;

- (void)qf_removeObserver:(NSObject *)observer forkey:(NSString *)key;

@end
