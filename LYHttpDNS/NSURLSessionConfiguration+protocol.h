//
//  NSURLSessionConfiguration+protocol.h
//  TLMHttpDNS
//
//  Created by JixinZhang on 2020/5/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSessionConfiguration (protocol)

+ (void)hookDefaultSessionConfiguration;

@end

NS_ASSUME_NONNULL_END
