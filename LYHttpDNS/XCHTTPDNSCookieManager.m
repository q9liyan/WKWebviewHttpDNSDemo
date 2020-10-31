//
//  XCHTTPDNSCookieManager.m
//  Pods
//
//  Created by JixinZhang on 2020/5/23.
//

#import "XCHTTPDNSCookieManager.h"

@interface XCHTTPDNSCookieManager ()

@end

@implementation XCHTTPDNSCookieManager
{
    XCHTTPDNSCookieFilterBlock filterBlock;
}

+ (instancetype)sharedInstance {
    static XCHTTPDNSCookieManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[XCHTTPDNSCookieManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        //If the domain does not start with a dot, then the cookie is only sent to the exact host specified by the domain. If the domain does start with a dot, then the cookie is sent to other hosts in that domain as well, subject to certain restrictions. See RFC 6265 for more detail.
        filterBlock = ^BOOL(NSHTTPCookie *cookie, NSURL *URL) {
            if ([URL.host containsString:cookie.domain]) {
                return YES;
            }
            return NO;
        };
    }
    return self;
}

- (void)setFilterBlock:(XCHTTPDNSCookieFilterBlock)aFilter
{
    if (aFilter != nil) {
        filterBlock = aFilter;
    }
}

- (NSArray <NSHTTPCookie *> *)handleHeaderFields:(NSDictionary *)headerFields forURL:(NSURL *)URL
{
    NSArray *cookieArray = [NSHTTPCookie cookiesWithResponseHeaderFields:headerFields forURL:URL];
    if (cookieArray != nil) {
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in cookieArray) {
            if (filterBlock(cookie,URL)) {
                [cookieStorage setCookie:cookie];
            }
        }
    }
    return cookieArray;
}

- (NSArray <NSHTTPCookie *> *)getCookiesForURL:(NSURL *)URL
{
    NSMutableArray *cookieArray = [NSMutableArray array];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieStorage cookies]) {
        if (filterBlock(cookie, URL)) {
            [cookieArray addObject:cookie];
        }
    }
    return cookieArray;
}

- (NSString *)getRequestCookieHeaderForURL:(NSURL *)URL {
    NSArray *cookieArray = [self getCookiesForURL:URL];
    if (cookieArray != nil && cookieArray.count > 0) {
        NSDictionary *cookieDic = [NSHTTPCookie requestHeaderFieldsWithCookies:cookieArray];
        if ([cookieDic objectForKey:@"Cookie"]) {
            NSString *returnString = cookieDic[@"Cookie"];
            return returnString;
        }
    }
    return nil;
}

@end
