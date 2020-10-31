//
//  NSURLSession+hook.m
//  DNSTest
//
//  Created by tom555cat on 2020/5/6.
//  Copyright © 2020年 JixinZhang. All rights reserved.
//

#import "NSURLSession+hook.h"
#import <objc/runtime.h>
#import "XCHTTPProtocol.h"

@implementation NSURLSession (hook)

+ (void)hookHTTPProtocol {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method method1 = class_getClassMethod([NSURLSession class], @selector(sessionWithConfiguration:));
        Method method2 = class_getClassMethod([NSURLSession class], @selector(swizzle_sessionWithConfiguration:));
        if (method1 && method2) {
            method_exchangeImplementations(method1, method2);
        }
        
        
        Method method3 = class_getClassMethod([NSURLSession class], @selector(sessionWithConfiguration:delegate:delegateQueue:));
        Method method4 = class_getClassMethod([NSURLSession class], @selector(swizzle_sessionWithConfiguration:delegate:delegateQueue:));
        if (method3 && method4) {
            method_exchangeImplementations(method3, method4);
        }
        
    });
}

+ (NSURLSession *)swizzle_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration {
    NSURLSessionConfiguration *newConfiguration = configuration;
    if (configuration) {
        NSMutableArray *protocolArray = [NSMutableArray arrayWithArray:configuration.protocolClasses];
        [protocolArray insertObject:[XCHTTPProtocol class] atIndex:0];
        newConfiguration.protocolClasses = protocolArray;
    } else {
        newConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSMutableArray *protocolArray = [NSMutableArray arrayWithArray:configuration.protocolClasses];
        [protocolArray insertObject:[XCHTTPProtocol class] atIndex:0];
        newConfiguration.protocolClasses = protocolArray;
    }
    
    return [self swizzle_sessionWithConfiguration:newConfiguration];
}

+ (NSURLSession *)swizzle_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(nullable id <NSURLSessionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue {
    
    NSURLSessionConfiguration *newConfiguration = configuration;
    if (configuration) {
        NSMutableArray *protocolArray = [NSMutableArray arrayWithArray:configuration.protocolClasses];
        [protocolArray insertObject:[XCHTTPProtocol class] atIndex:0];
        newConfiguration.protocolClasses = protocolArray;
    } else {
        newConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSMutableArray *protocolArray = [NSMutableArray arrayWithArray:configuration.protocolClasses];
        [protocolArray insertObject:[XCHTTPProtocol class] atIndex:0];
        newConfiguration.protocolClasses = protocolArray;
    }
    
    return [self swizzle_sessionWithConfiguration:newConfiguration delegate:delegate delegateQueue:queue];
}

@end
