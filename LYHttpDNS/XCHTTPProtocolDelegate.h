//
//  XCHTTPProtocolDelegate.h
//  Pods
//
//  Created by JixinZhang on 2020/6/4.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LDAPMMemoryType){
    LDAPMTypeControllerDidAppear    = 102,
    LDAPMTypeControllerDisAppear    = 103,
    LDAPMTypeControllerViewDidLoad  = 101,
    LDAPMTypeBigImage               = 201,
    LDAPMTypeLowMemoryWarning       = 301,
    LDAPMTypeOutOfMemory            = 401,
    LDAPMTypeLastCrash              = 501,
    LDAPMTypeOutOfLimit             = 601
};

@protocol XCHTTPProtocolDelegate <NSObject>
/**
 *  是否需要探测此url，这个调用不保证发生在主线程
 */
- (bool)protocolShouldHandleURL:(NSURL*)url;
- (void)protocolDidCompleteURL:(NSURL*)url from:(NSTimeInterval)startTime to:(NSTimeInterval)endTime withStatusCode:(NSInteger)code;
- (void)protocolDidCompleteURL:(NSURL*)url from:(NSTimeInterval)startTime to:(NSTimeInterval)endTime rxBytes:(NSUInteger)rxBytes txBytes:(NSUInteger)txBytes withStatusCode:(NSInteger)code;
- (void)protocolDidCompleteURL:(NSURL*)url from:(NSTimeInterval)startTime to:(NSTimeInterval)endTime withError:(NSError*)error;
- (void)protocolDidCompleteURL:(NSURL*)url from:(NSTimeInterval)startTime to:(NSTimeInterval)endTime rxBytes:(NSUInteger)rxBytes txBytes:(NSUInteger)txBytes netDetailTime:(NSDictionary *)detailTime withStatusCode:(NSInteger)code;

/**
 *  大对象的监控
 */
//- (void)protocolGetBigObjectWithTime:(NSTimeInterval)et size:(float)size stack:(NSArray *)stack;

/**
 *  内存走势的监控
 */
//- (void)protocolGetMemoryTrendWithType:(LDAPMMemoryType)type freeMemory:(float)free usedMemory:(float)used eventTime:(NSTimeInterval)et page:(NSString *)page;

/**
 *  内存走势的监控
 */
//- (void)protocolGetANRLog:(NSArray *)log;


@optional
/**
 *  是否需要探测某个host的dns监控
 */
- (BOOL)protocolShouldDNSResolve:(NSString *)host;
- (void)protocolDidCompleteDNSResolve:(NSString *)host dnsIP:(NSString *)dnsIP dnsResolveTime:(int)dnsResolveTime eventTime:(NSTimeInterval)et;


/**
 *  通过域名置换IP
 */
- (NSString *)protocolGetIPbyDomain:(NSString *)domain;

/**
 *  替换host
 */
- (NSString *)protocolReplacedHostForHost:(NSString *)host;

/**
 *  降级到http
 */
- (BOOL)protocolShouldDegradeToHttpByDomain:(NSString *)domain;


/**
 *  判断该url是否需要IP直连
 */
- (BOOL)protocolShouldHTTPDNSByURL:(NSURL *)url;

/**
 *  获取该url需要IP直连返回的IP
 *  返回nil则不需要，否则返回IP，对该url进行IP直连
 */
- (NSString *)protocolCheckURLIfNeededHTTPDNSByURL:(NSURL *)url;

/**
 *  通过CFNetwork发送请求，配置SNI扩展
 *  暂时与上面三项不兼容，优先级高于上面三项
 */
- (NSString *)protocolCFNetworkHTTPDNSGetIPByDomain:(NSString *)domain;

@end
