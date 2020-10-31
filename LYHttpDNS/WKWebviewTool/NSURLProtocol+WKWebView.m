//
//  NSURLProtocol+WKWebView.m
//  DNSTest
//
//  Created by JixinZhang on 2020/5/9.
//  Copyright © 2020 JixinZhang. All rights reserved.
//

#import "NSURLProtocol+WKWebView.h"

@implementation NSURLProtocol (WKWebView)

+ (void)wk_registerScheme:(NSString *)scheme {
    Class cls = NSClassFromString(@"WKBrowsingContextController");
    SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
    if ([cls respondsToSelector:sel]) {
        // 放弃编辑器警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [cls performSelector:sel withObject:scheme];
#pragma clang diagnostic pop
    }
}

+ (void)wk_unregisterScheme:(NSString *)scheme {
    Class cls = NSClassFromString(@"WKBrowsingContextController");
    SEL sel = NSSelectorFromString(@"unregisterSchemeForCustomProtocol:");
    if ([cls respondsToSelector:sel]) {
        // 放弃编辑器警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [cls performSelector:sel withObject:scheme];
#pragma clang diagnostic pop
    }
}

@end
