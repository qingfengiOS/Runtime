//
//  NSObject+KVO.m
//  Runtime
//
//  Created by 情风 on 2018/8/20.
//  Copyright © 2018年 情风. All rights reserved.
//

#import "NSObject+KVO.h"
#import <objc/message.h>

NSString *const kQFKVOClassPrefix = @"QFKVO_";
NSString *const kQFKVOAssociatedObservers = @"QFKVOAssociatedObservers";

#pragma mark - QFObservationInfo
@interface QFObservationInfo : NSObject

@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) ObservingBlock block;

@end

@implementation QFObservationInfo

- (instancetype)initWithObserver:(NSObject *)observer Key:(NSString *)key block:(ObservingBlock)block
{
    self = [super init];
    if (self) {
        _observer = observer;
        _key = key;
        _block = block;
    }
    return self;
}

@end

@implementation NSObject (KVO)

#pragma mark - Public
/*
 1、检查对象的类有没有相应的 setter 方法。如果没有抛出异常；
 2、检查对象 isa 指向的类是不是一个 KVO 类。如果不是，新建一个继承原来类的子类，并把 isa 指向这个新建的子类；
 3、检查对象的 KVO 类重写过没有这个 setter 方法。如果没有，添加重写的 setter 方法；
 4、添加这个观察者
 */
- (void)qf_addObserver:(NSObject *)observer forKey:(NSString *)key withBlock:(ObservingBlock)block {
    // 1. 检查对象的类有没有相应的 setter 方法。如果没有抛出异常
    SEL setterSelector =  NSSelectorFromString(setterForGetter(key));
    Method setterMethod = class_getInstanceMethod([self class], setterSelector);
    if (!setterMethod) {
        NSString *reason = [NSString stringWithFormat:@"Object %@ does not have a setter for key %@", self, key];
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:reason
                                     userInfo:nil];
        
        return;
    }
    
    // 2. 检查对象 isa 指向的类是不是一个 KVO 类。如果不是，新建一个继承原来类的子类，并把 isa 指向这个新建的子类
    Class class = object_getClass(self);
    NSString *className = NSStringFromClass(class);
    if (![className hasPrefix:kQFKVOClassPrefix]) {
        class = [self makeKvoClassWithOriginalClassName:className];
        object_setClass(self, class);
    }
    
    // 到这里为止, object的类已不是原类了, 而是KVO新建的类
    // 例如, Person -> QFKVOClassPrefixPerson
    // QFKVOClassPrefix是一个宏, = @"QFKVO_"
    
    // 3. 为kvo class添加setter方法的实现
    if (![self hasSelector:setterSelector]) {
        const char *types = method_getTypeEncoding(setterMethod);
        class_addMethod(class, setterSelector, (IMP)kvo_setter, types);
    }
    QFObservationInfo *info = [[QFObservationInfo alloc] initWithObserver:observer Key:key block:block];
    NSMutableArray *observers = objc_getAssociatedObject(self, (__bridge const void *)(kQFKVOAssociatedObservers));
    if (!observers) {
        observers = [NSMutableArray array];
        objc_setAssociatedObject(self, (__bridge const void *)(kQFKVOAssociatedObservers), observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [observers addObject:info];
}

- (void)qf_removeObserver:(NSObject *)observer forkey:(NSString *)key {
    
    NSMutableArray *observers = objc_getAssociatedObject(self, (__bridge const void *)(kQFKVOAssociatedObservers));
    QFObservationInfo *infoToRemove;
    for (QFObservationInfo* info in observers) {
        if (info.observer == observer && [info.key isEqual:key]) {
            infoToRemove = info;
            break;
        }
    }
    
    [observers removeObject:infoToRemove];
}

#pragma mark - Private

- (Class)makeKvoClassWithOriginalClassName:(NSString *)originalClassName {
    
    NSString *kvoClassName = [kQFKVOClassPrefix stringByAppendingString:originalClassName];
    
    Class clazz = NSClassFromString(kvoClassName);
    
    if (clazz) {
        return  clazz;
    }
    
    // class doesn't exist yet, make it
    Class originalClazz = object_getClass(self);
    Class kvoClazz = objc_allocateClassPair(originalClazz, kvoClassName.UTF8String, 0);
    
    // grab class method's signature so we can borrow it
    Method clazzMethod = class_getInstanceMethod(originalClazz, @selector(class));
    const char *types = method_getTypeEncoding(clazzMethod);
    class_addMethod(kvoClazz, @selector(class), (IMP)kvo_class, types);
    
    objc_registerClassPair(kvoClazz);
    
    return kvoClazz;
}

- (BOOL)hasSelector:(SEL)selector
{
    Class clazz = object_getClass(self);
    unsigned int methodCount = 0;
    Method* methodList = class_copyMethodList(clazz, &methodCount);
    for (unsigned int i = 0; i < methodCount; i++) {
        SEL thisSelector = method_getName(methodList[i]);
        if (thisSelector == selector) {
            free(methodList);
            return YES;
        }
    }
    
    free(methodList);
    return NO;
}

static Class kvo_class(id self, SEL _cmd)
{
    return class_getSuperclass(object_getClass(self));
}

static void kvo_setter(id self, SEL _cmd, id newValue) {
    NSString *setterName = NSStringFromSelector(_cmd);
    NSString *getterName = getterForSetter
    (setterName);
    if (!getterName) {
        NSLog(@"getter方法没有实现");
    }
    
    id oldValue = [self valueForKey:getterName];
    // 调用原类的setter方法
    struct objc_super superClazz = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    void (*objc_msgSendSuperCasted)(void *, SEL, id) = (void *)objc_msgSendSuper;
    
    objc_msgSendSuperCasted(&superClazz, _cmd, newValue);
    
    // look up observers and call the blocks
    NSMutableArray *observers = objc_getAssociatedObject(self, (__bridge const void *)(kQFKVOAssociatedObservers));
    for (QFObservationInfo *each in observers) {
        if ([each.key isEqualToString:getterName]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                each.block(self, getterName, oldValue, newValue);
            });
        }
    }
}

#pragma mark - Helpers
static NSString * getterForSetter(NSString *setter) {
    if (setter.length <=0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) {
        return nil;
    }
    
    // remove 'set' at the begining and ':' at the end
    NSRange range = NSMakeRange(3, setter.length - 4);
    NSString *key = [setter substringWithRange:range];
    
    // lower case the first letter
    NSString *firstLetter = [[key substringToIndex:1] lowercaseString];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                       withString:firstLetter];
    
    return key;
}


static NSString * setterForGetter(NSString *getter) {
    if (getter.length <= 0) {
        return nil;
    }
    
    // upper case the first letter
    NSString *firstLetter = [[getter substringToIndex:1] uppercaseString];
    NSString *remainingLetters = [getter substringFromIndex:1];
    
    // add 'set' at the begining and ':' at the end
    NSString *setter = [NSString stringWithFormat:@"set%@%@:", firstLetter, remainingLetters];
    
    return setter;
}

@end
