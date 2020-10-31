//
//  NSMutableDictionary+SafetyDictionary.h
//  Pods
//
//  Created by JixinZhang on 2020/6/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary (SafetyDictionary)

- (void)_safety_setObject:(id)object forKey:(NSString *)key;
- (void)_safety_setInteger:(long long)integer forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
