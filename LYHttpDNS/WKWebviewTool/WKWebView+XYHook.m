//
//  WKWebView+Hook.m
//  HttpProxyDemo
//
//  Created by Nemo on 2020/2/22.
//  Copyright © 2020 Nemo. All rights reserved.
//

//#import "XYConstant.h"
#import <objc/runtime.h>
#import "WKWebView+XYHook.h"
#import "XCHTTPProtocol.h"

@interface XYPostSupportDelegate : NSObject
<
    WKScriptMessageHandler
>
@end


@implementation WKWebView (XYHook)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method origin = class_getClassMethod(self, @selector(handlesURLScheme:));
        Method hook = class_getClassMethod(self, @selector(xy_handlesURLScheme:));
        // 交换方法
        method_exchangeImplementations(origin, hook);
    });
}

+ (BOOL)xy_handlesURLScheme:(NSString *)urlScheme {
    if ([urlScheme isEqualToString:@"http"] || [urlScheme isEqualToString:@"https"]) {
        return NO;
    }
    return [self xy_handlesURLScheme:urlScheme];
}

- (void)openPostSupport {
    XYPostSupportDelegate *postDelegate = [[XYPostSupportDelegate alloc] init];
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:[self javascript] injectionTime:WKUserScriptInjectionTimeAtDocumentStart | WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    [self.configuration.userContentController addUserScript:userScript];
    [self.configuration.userContentController addScriptMessageHandler:postDelegate name:kXYPOST_BODY_RESPONSE];
}

- (NSString *)javascript {
    NSString *elementJs = [NSString stringWithFormat:@"function generateRandom() {\
                           return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);\
                           }\
                           requestID = null;\
                           XMLHttpRequest.prototype.reallyOpen = XMLHttpRequest.prototype.open;\
                           XMLHttpRequest.prototype.open = function(method, url, async, user, password) {\
                           if(method.toLowerCase() == 'post'){\
                           requestID = generateRandom();\
                           var signed_url = url + '%@' + requestID;\
                           this.reallyOpen(method, signed_url , async, user, password);\
                           }else{\
                           this.reallyOpen(method, url , async, user, password);\
                           }\
                           };\
                           XMLHttpRequest.prototype.reallySend = XMLHttpRequest.prototype.send;\
                           XMLHttpRequest.prototype.send = function(body) {\
                           window.webkit.messageHandlers.%@.postMessage({'requestId':requestID,'HTTPBody':body});\
                           this.reallySend(body);\
                           };",kXYPOST_URL_FLAG,kXYPOST_BODY_RESPONSE];
    NSString *js = [NSString stringWithFormat:@"\
                    (function() {\
                    var parent = document.getElementsByTagName('head').item(0);\
                    var script = document.getElementById('%@');\
                    if(!script) { \
                    script = document.createElement('script');\
                    script.language = 'JavaScript';\
                    script.id = '%@';\
                    script.language = 'JavaScript';\
                    script.innerHTML = \"%@\";\
                    parent.appendChild(script);\
                    }\
                    })();",kXYPOST_ELEMENT_FLAG,kXYPOST_ELEMENT_FLAG,elementJs];
    return js;
}
@end


@implementation XYPostSupportDelegate
- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
 
    if ([message.name isEqualToString:kXYPOST_BODY_RESPONSE]) {
        // 处理 POST Body 保存
        NSDictionary *body = message.body;
        id httpBody = body[@"HTTPBody"];
        NSString *requestId = body[@"requestId"];
        NSData *requestD = [[NSData alloc] init];
        if ([httpBody isKindOfClass:[NSString class]]) {
            requestD = [httpBody dataUsingEncoding:NSUTF8StringEncoding];
        }else if ([httpBody isKindOfClass:[NSData class]]) {
            requestD = httpBody;
        }else if ([NSJSONSerialization isValidJSONObject:httpBody]) {
            NSError *err = nil;
            requestD = [NSJSONSerialization dataWithJSONObject:httpBody options:0 error:&err];
            if (err) {
                NSLog(@"请求数据 JSON 格式解释异常: %@",err);
            }
        }
        // 保存请求数据
        @synchronized (XCHTTPProtocol.cacheBody) {
            [XCHTTPProtocol.cacheBody setValue:requestD forKey:requestId];
        }
    }
}
@end
