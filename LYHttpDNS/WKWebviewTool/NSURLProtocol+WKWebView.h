//
//  NSURLProtocol+WKWebView.h
//  DNSTest
//
//  Created by JixinZhang on 2020/5/9.
//  Copyright © 2020 JixinZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLProtocol (WKWebView)

+ (void)wk_registerScheme:(NSString*)scheme;

+ (void)wk_unregisterScheme:(NSString*)scheme;

@end

NS_ASSUME_NONNULL_END
