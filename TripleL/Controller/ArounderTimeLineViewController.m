//
//  ArrounderTimeLineViewController.m
//  TripleL
//
//  Created by h1r0 on 15/5/26.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "ArounderTimeLineViewController.h"
#import "WebControlView.h"
#import "MyHeader.h"

@interface ArounderTimeLineViewController () <UIWebViewDelegate, WebControlDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) WebControlView *webControlView;

@end

@implementation ArounderTimeLineViewController


- (void) viewDidLoad {
    [super viewDidLoad];
    
    _webView = [[UIWebView alloc] init];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    _webControlView = [[WebControlView alloc] init];
    [_webControlView setBackgroundColor:DEFAULT_WHITE_COLOR];
    _webControlView.delegate = self;
    [self.view addSubview:_webControlView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController.navigationBar setHidden:YES];
    
    NSURLRequest *request = [[MyServer getServer] getArounderTimelineRequest];
    [_webView loadRequest:request];
    [_webView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height + 10)];
    [_webControlView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - self.tabBarController.tabBar.frame.size.height + 10, [UIScreen mainScreen].bounds.size.width, self.tabBarController.tabBar.frame.size.height - 10)];
    
    UIView *topBgVC = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
    [topBgVC setBackgroundColor:[AppConfig getStatusBarColor]];
    [self.view addSubview:topBgVC];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *token = [[request allHTTPHeaderFields] objectForKey:AUTH_TOKEN];
    
    if([token isEqualToString:[[MyServer getServer] getAUTH_TOKEN]]){
        return YES;
    }
    else{
        NSURL *url = [request URL];
        NSMutableURLRequest* newRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        
        [newRequest addValue:[[MyServer getServer] getAUTH_TOKEN] forHTTPHeaderField:AUTH_TOKEN];
        
        [webView loadRequest:newRequest];
    }
    
    return NO;
}

#pragma mark - WebContrlDelegate

- (void) closeButtonDown
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) backButtonDown
{
    [_webView goBack];
}

- (void) preButtonDown
{
    [_webView goForward];
}

- (void) homeButtonDown
{
    NSURLRequest *request = [[MyServer getServer] getArounderTimelineRequest];
    [_webView loadRequest:request];
}

- (void) refreshButtonDown
{
    [_webView reload];
}


@end
