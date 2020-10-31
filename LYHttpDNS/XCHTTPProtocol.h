//
//  XCHTTPProtocol.h
//  DNSTest
//
//  Created by JixinZhang on 2020/5/6.
//  Copyright © 2020 JixinZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCHTTPProtocolDelegate.h"

#define kXYPOST_ELEMENT_FLAG @"_POST_ELEMENT_FLAG" // JS 添加 POST 截取标签标识
#define kXYPOST_URL_FLAG @"_POST_FLAG" // POST URL 标识
#define kXYPOST_BODY_RESPONSE @"postBodyResponse" // 请求到 post body 时回调 oc 方

@interface XCHTTPProtocol : NSURLProtocol

+ (void)start;

+ (void)setDelegate:(id<XCHTTPProtocolDelegate>)newValue;

/** TODO: POST Body 缓存 */
@property (nonatomic, strong, class, readonly) NSMutableDictionary<NSString *, NSData *> *cacheBody;


@end

