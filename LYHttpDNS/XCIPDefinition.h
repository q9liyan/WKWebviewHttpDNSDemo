//
//  XCIPDefinition.h
//  DNSTest
//
//  Created by JixinZhang on 2020/5/16.
//  Copyright © 2020 JixinZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XCIPDefinition : NSObject

@property (nonatomic, copy, readonly) NSString *ip;

// 从HTTPDNS返回的TTL
@property (nonatomic, strong, readonly) NSDate *serverTTL;

// 本地设置的TTL，为60s
@property (nonatomic, strong, readonly) NSDate *localTTL;

- (instancetype)initWithIP:(NSString *)ip serverTTL:(NSInteger)ttl NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

/**
 判断DNSHTTP返回TTL是否超时

 @return 超时返回YES，否则返回NO
 */
- (BOOL)isServerTTLTimeout;

/**
 判断本地设置的TTL是否超时

 @return 超时返回YES，否则返回NO
 */
- (BOOL)isLocalTTLTimeout;

@end

NS_ASSUME_NONNULL_END
