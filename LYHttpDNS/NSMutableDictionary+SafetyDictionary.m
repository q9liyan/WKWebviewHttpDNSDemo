//
//  NSMutableDictionary+SafetyDictionary.m
//  Pods
//
//  Created by JixinZhang on 2020/6/4.
//

#import "NSMutableDictionary+SafetyDictionary.h"

@implementation NSMutableDictionary (SafetyDictionary)

- (void)_safety_setObject:(id)object forKey:(NSString *)key {
    object = object ? : @"";
    [self setObject:object forKey:key];
}

- (void)_safety_setInteger:(long long)integer forKey:(NSString *)key {
    [self _safety_setObject:@(integer) forKey:key];
}

@end
