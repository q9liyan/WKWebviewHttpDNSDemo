//
//  DNSPodManager.h
//  TLMHttpDNS_Example
//
//  Created by JixinZhang on 2020/5/24.
//  Copyright © 2020 JixinZhang1989@sina.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCHTTPProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DNSPodManager : NSObject <XCHTTPProtocolDelegate>

// XCHTTPProtocol处理之后，还需要其他URLProtocol处理的URLProtocol数组
@property (nonatomic, strong) NSArray *succeedProtocolNames;

+ (instancetype)sharedInstance;

- (void)start;

- (void)replaceHostWithIPAsync:(BOOL)async;

@end

NS_ASSUME_NONNULL_END
