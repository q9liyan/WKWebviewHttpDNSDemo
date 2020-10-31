//
//  NSURLSessionConfiguration+protocol.m
//  TLMHttpDNS
//
//  Created by JixinZhang on 2020/5/29.
//

#import "NSURLSessionConfiguration+protocol.h"
#import <objc/runtime.h>

@implementation NSURLSessionConfiguration (protocol)

+ (void)hookDefaultSessionConfiguration
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class clazz = NSClassFromString(@"NSURLSessionConfiguration");
        Method originMethod = class_getClassMethod(clazz, @selector(defaultSessionConfiguration));
        Method newMethod = class_getClassMethod(clazz, @selector(newDefaultSessionConfiguration));
        
        if (originMethod && newMethod) {
            method_exchangeImplementations(originMethod, newMethod);
        } else {
            //NSLog(@"origMethod:%@ newMethod:%@",originMethod,newMethod);
        }
    });
}

+ (instancetype)newDefaultSessionConfiguration
{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration newDefaultSessionConfiguration];
    sessionConfiguration.protocolClasses = @[[NSClassFromString(@"XCHTTPProtocol") class]];
    return sessionConfiguration;
}

@end
