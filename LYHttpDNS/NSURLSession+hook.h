//
//  NSURLSession+hook.h
//  DNSTest
//
//  Created by tom555cat on 2020/5/6.
//  Copyright © 2020年 JixinZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSession (hook)

+ (void)hookHTTPProtocol;

@end
