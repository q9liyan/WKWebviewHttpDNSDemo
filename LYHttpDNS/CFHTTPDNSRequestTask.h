//
//  CFHTTPDNSRequestTask.h
//  CFHTTPDNSRequest
//
//  Created by junmo on 16/12/8.
//  Copyright © 2016年 junmo. All rights reserved.
//

#ifndef CFHTTPDNSRequestTask_h
#define CFHTTPDNSRequestTask_h

@class CFHTTPDNSRequestTask;
@protocol CFHTTPDNSRequestTaskDelegate <NSObject>

- (void)task:(CFHTTPDNSRequestTask *)task didReceiveResponse:(NSURLResponse *)response cachePolicy:(NSURLCacheStoragePolicy)cachePolicy;
- (void)task:(CFHTTPDNSRequestTask *)task didReceiveRedirection:(NSURLRequest *)request response:(NSURLResponse *)response;
- (void)task:(CFHTTPDNSRequestTask *)task didReceiveData:(NSData *)data;
- (void)task:(CFHTTPDNSRequestTask *)task didCompleteWithError:(NSError *)error;

@end

@interface CFHTTPDNSRequestResponse : NSObject

@property (nonatomic, assign) CFIndex statusCode;
@property (nonatomic, copy) NSDictionary *headerFields;
@property (nonatomic, copy) NSString *httpVersion;

@end

@interface CFHTTPDNSRequestTask : NSObject

@property (nonatomic, strong, readonly) CFHTTPDNSRequestResponse *response;   // 请求Response


- (CFHTTPDNSRequestTask *)initWithURLRequest:(NSURLRequest *)request swizzleRequest:(NSURLRequest *)swizzleRequest delegate:(id<CFHTTPDNSRequestTaskDelegate>)delegate;
- (void)startLoading;
- (void)stopLoading;
- (NSString *)getOriginalRequestHost;
- (NSHTTPURLResponse *)getRequestResponse;

@end


@interface NSInputStream (ReadOutData)

- (NSData *)readOutData;

@end

#endif /* CFHTTPDNSRequestTask_h */


