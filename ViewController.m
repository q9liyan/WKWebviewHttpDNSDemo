//
//  ViewController.m
//  WKWebviewHttpDNSDemo
//
//  Created by cyh on 2020/10/31.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "NSURLProtocol+WKWebView.h"
#import "WKWebView+XYHook.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [NSURLProtocol wk_registerScheme:@"http"];
    [NSURLProtocol wk_registerScheme:@"https"];
    // Avoid detaching the case from the charging port place
    
    NSString *url = [NSString stringWithFormat:@"https://www.baidu.com"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
  
      config.allowsInlineMediaPlayback = YES;
    config.allowsPictureInPictureMediaPlayback = YES;

    if (@available(iOS 10.0, *)) {
                config.mediaTypesRequiringUserActionForPlayback = NO;

            }
    WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) configuration:config];
    [wkWebView loadRequest:request];
    [wkWebView openPostSupport];
    [self.view addSubview:wkWebView];
}


@end
