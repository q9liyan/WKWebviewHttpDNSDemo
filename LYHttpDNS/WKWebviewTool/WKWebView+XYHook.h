//
//  WKWebView+Hook.h
//  HttpProxyDemo
//
//  Created by Nemo on 2020/2/22.
//  Copyright © 2020 Nemo. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface WKWebView (XYHook)
/**
 * 代理模式 POST 支持
 */
- (void)openPostSupport;
@end
NS_ASSUME_NONNULL_END
