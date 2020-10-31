//
//  DNSPodManager.m
//  TLMHttpDNS_Example
//
//  Created by JixinZhang on 2020/5/24.
//  Copyright © 2020 JixinZhang1989@sina.com. All rights reserved.
//

#import "DNSPodManager.h"
#import "XCIPDefinition.h"
#import "NSURLSession+SynchronousTask.h"
#import "XCHTTPProtocol.h"
#define kXYMapIp @"https://ns.yndmr.com/query?ct=application/dns-json&type=A&name="
//#endif

#define kXYHostMapIpUrlString(host) [kXYMapIp stringByAppendingString:host] // 组成请求映射 URL

static NSString *const urlStr = @"http://119.29.29.29/d?dn=%@&ttl=1";

static NSString *const kTLMURLProtocolKey = @"kTLMURLProtocolKey";
static NSMutableDictionary<NSString *, XCIPDefinition *> *hostIPMap = nil;

@interface DNSPodManager ()

// 是否从HTTPDNS异步请求ip地址
@property (nonatomic, assign) BOOL async;

@end

@implementation DNSPodManager

+ (instancetype)sharedInstance {
    static DNSPodManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (void)replaceHostWithIPAsync:(BOOL)async {
    _async = async;
}

- (void)start {
    [XCHTTPProtocol start];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _async = YES;
        [XCHTTPProtocol setDelegate:(id<XCHTTPProtocolDelegate>)self];
    }
    return self;
}

+ (NSArray *)prepareOtherURLProtocols {
    //return @[[NSClassFromString(@"CustomHTTPProtocol") class]];
    return @[];
}

#pragma mark - private

+ (NSString *)ipForHost:(NSString *)host {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hostIPMap = [[NSMutableDictionary alloc] init];
    });
    
    XCIPDefinition *ipDefinition = hostIPMap[host];
    if (!ipDefinition) {
        if ([DNSPodManager sharedInstance].async == YES) {
            [self getIPFromHTTPDNSAsync:host];
            return nil;
        } else {
            ipDefinition = [self getIPFromHTTPDNSSync:host];
            hostIPMap[host] = ipDefinition;
        }
    }
    
    // 过期检查
    if (ipDefinition) {
        if ([ipDefinition isServerTTLTimeout]) {
            if ([DNSPodManager sharedInstance].async == YES) {
                [self getIPFromHTTPDNSAsync:host];
                return nil;
            } else {
                ipDefinition = [self getIPFromHTTPDNSSync:host];
                hostIPMap[host] = ipDefinition;
            }
        }
    }
    
    return ipDefinition.ip;
}

// 从HTTPDNS中异步获取IP地址
+ (void)getIPFromHTTPDNSAsync:(NSString *)host {
    
//    NSString *url = [NSString stringWithFormat:@"http://119.29.29.29/d?dn=%@&ttl=1", host];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    NSURL *mapUrl = [NSURL URLWithString:kXYHostMapIpUrlString(host)];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:mapUrl ];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCIPDefinition *ipDefinition = [self parseHTTPDNSResponse:data];
        hostIPMap[host] = ipDefinition;
    }];
    [dataTask resume];
}
// 从HTTPDNS中同步获取IP地址
+ (XCIPDefinition *)getIPFromHTTPDNSSync:(NSString *)host {
//    NSString *url = [NSString stringWithFormat:@"http://119.29.29.29/d?dn=%@&ttl=1", host];
    NSURL *mapUrl = [NSURL URLWithString:kXYHostMapIpUrlString(host)];
//    NSString *basrUrl = @"https://ns.yndmr.com/query?ct=application/dns-json&type=A&name=";
    
//    NSString *url = [basrUrl stringByAppendingString:host];
    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:mapUrl ];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] ];
    request.timeoutInterval = 5;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [session sendSynchronousDataTaskWithRequest:request returningResponse:&response error:&error];
    
    XCIPDefinition *ipDefinition = [self parseHTTPDNSResponse:data];
    return ipDefinition;
}




+ (XCIPDefinition *)parseHTTPDNSResponse:(NSData *)data {
    // 解析ip地址和ttl
    NSString *ip;
    NSInteger ttl = 0;
    NSDictionary *turnDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSArray<NSDictionary<NSString *, id> *> *answer = turnDic[@"Answer"];
    if (answer == nil) {
        NSArray<NSDictionary<NSString *, id> *> *question = turnDic[@"Question"];
        
        NSArray<NSDictionary<NSString *, id> *> *Authority = turnDic[@"Authority"];
        NSString *ipData = [[question firstObject] objectForKey:@"name"];
        NSInteger TTL = [[[Authority firstObject] objectForKey:@"TTL"] integerValue];
        XCIPDefinition *ipDefinition = [[XCIPDefinition alloc] initWithIP:ipData serverTTL:TTL];
        return ipDefinition;
    }
    NSDictionary *top1Data = answer[0];
    NSString *ipData = top1Data[@"data"];
    NSString *TTL = top1Data[@"TTL"];
    XCIPDefinition *ipDefinition = [[XCIPDefinition alloc] initWithIP:ipData serverTTL:TTL];
    return ipDefinition;
    
    NSString *result = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSArray *partArray = [result componentsSeparatedByString:@","];
    if (partArray.count == 2) {
        // ttl部分
        ttl = [partArray[1] integerValue];
        
        // ip地址部分
        NSArray *ipArray = [partArray[0] componentsSeparatedByString:@";"];
        if (ipArray.count > 0) {
            // 使用返回的第一个ip地址
            ip = ipArray[0];
        }
        if ([self isIPAddressValid:ip]) {
            XCIPDefinition *ipDefinition = [[XCIPDefinition alloc] initWithIP:ip serverTTL:ttl];
            return ipDefinition;
        }
    }
    
    return nil;
}
+ (BOOL)isIPAddressValid:(NSString *)ipAddress {
    NSArray *components = [ipAddress componentsSeparatedByString:@"."];
    if (components.count != 4) {
        return NO;
    }
    NSCharacterSet *unwantedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    if ([ipAddress rangeOfCharacterFromSet:unwantedCharacters].location != NSNotFound) {
        return NO;
    }
    for (NSString *string in components) {
        if ((string.length < 1) || (string.length > 3 )) {return NO;}
        if (string.intValue > 255) {return NO;}
    }
    if  ([[components objectAtIndex:0] intValue]==0){return NO;}
    return YES;
}


#pragma mark - TLMHTTPProtocolDelegate
static inline NSSet *ignorePathExtension() {
    return [[NSSet alloc] initWithObjects:@"tif", @"tiff", @"jpg", @"jpeg", @"gif", @"png", @"ico", @"bmp", @"cur", @"apng", @"webp", @"woff", @"otf",@"mp4",@"video", nil];
}

- (BOOL)protocolShouldHandleURL:(NSURL *)url {
    NSString *pathExtension = url.pathExtension;
    if ([ignorePathExtension() containsObject:[pathExtension lowercaseString]]) {
        return NO;
    }
    // DNSPod不需要进行ip直连
    if ([[url host] isEqualToString:@"119.29.29.29"]) {
        return NO;
    }
    if ([[url host] isEqualToString:@"ns.yndmr.com"]) {
        return NO;
    }
    
    return YES;
}

- (void)protocolDidCompleteURL:(NSURL*)url from:(NSTimeInterval)startTime to:(NSTimeInterval)endTime withStatusCode:(NSInteger)code {
//    NSString *stringUrl = [NSString stringWithFormat:@"%@",url];
//    if (stringUrl) {
//        [self addURLRecord:@{@"n":stringUrl,
//                             @"st":TIMESTAMP_NUMBER(startTime),
//                             @"et":TIMESTAMP_NUMBER(endTime),
//                             @"c":[NSNumber numberWithInteger:code]}];
//    }
}

- (void)protocolDidCompleteURL:(NSURL*)url from:(NSTimeInterval)startTime to:(NSTimeInterval)endTime rxBytes:(NSUInteger)rxBytes txBytes:(NSUInteger)txBytes withStatusCode:(NSInteger)code{
    //    NSString *stringUrl = [NSString stringWithFormat:@"%@",url];
    //    if (stringUrl) {
    //        [self addURLRecord:@{@"n":stringUrl,
    //                             @"st":TIMESTAMP_NUMBER(startTime),
    //                             @"et":TIMESTAMP_NUMBER(endTime),
    //                             @"dst":@(0),
    //                             @"det":@(0),
    //                             @"tst":@(0),
    //                             @"tet":@(0),
    //                             @"sst":@(0),
    //                             @"set":@(0),
    //                             @"rst":@(0),
    //                             @"ret":@(0),
    //                             @"rpst":@(0),
    //                             @"rpet":@(0),
    //                             @"rps":[NSNumber numberWithUnsignedInteger:rxBytes],
    //                             @"rqs":[NSNumber numberWithUnsignedInteger:txBytes],
    //                             @"c":[NSNumber numberWithInteger:code]}];
    //    }
}

- (void)protocolDidCompleteURL:(NSURL*)url from:(NSTimeInterval)startTime to:(NSTimeInterval)endTime withError:(NSError*)error {
    //    NSString *stringUrl = [NSString stringWithFormat:@"%@",url];
    //    if (stringUrl) {
    //        [self addURLRecord:@{@"n":stringUrl,
    //                             @"st":TIMESTAMP_NUMBER(startTime),
    //                             @"et":TIMESTAMP_NUMBER(endTime),
    //                             @"c":[NSNumber numberWithInteger:[error code]],
    //                             @"e":[error localizedDescription]}];
    //    }
}

- (void)protocolDidCompleteURL:(NSURL*)url from:(NSTimeInterval)startTime to:(NSTimeInterval)endTime rxBytes:(NSUInteger)rxBytes txBytes:(NSUInteger)txBytes netDetailTime:(NSDictionary *)detailDic withStatusCode:(NSInteger)code {
//    NSString *stringUrl = [NSString stringWithFormat:@"%@",url];
//    if (stringUrl) {
//        [self addURLRecord:@{@"n":stringUrl,
//                             @"st":TIMESTAMP_NUMBER(startTime),
//                             @"et":TIMESTAMP_NUMBER(endTime),
//                             @"dst":detailDic[@"dnsSTime"],
//                             @"det":detailDic[@"dnsETime"],
//                             @"tst":detailDic[@"tcpSTime"],
//                             @"tet":detailDic[@"tcpETime"],
//                             @"sst":detailDic[@"sslSTime"],
//                             @"set":detailDic[@"sslETime"],
//                             @"rst":detailDic[@"reqSTime"],
//                             @"ret":detailDic[@"reqETime"],
//                             @"rpst":detailDic[@"respSTime"],
//                             @"rpet":detailDic[@"respETime"],
//                             @"rps":[NSNumber numberWithUnsignedInteger:rxBytes],
//                             @"rqs":[NSNumber numberWithUnsignedInteger:txBytes],
//                             @"c":[NSNumber numberWithInteger:code]}];
//    }
}





- (NSString *)protocolCFNetworkHTTPDNSGetIPByDomain:(NSString *)domain {
    NSString *ip = [[self class] ipForHost:domain];
    return ip;
}

@end
