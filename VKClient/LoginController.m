//
//  ViewController.m
//  VKClient
//
//  Created by Александр Алгашев on 14.01.15.
//  Copyright (c) 2015 Александр Алгашев. All rights reserved.
//

#import "LoginController.h"
#import "VKAPIClient.h"
#import "NewsController.h"

@interface LoginController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LoginController {
    
    BOOL isWebViewDidFailLoadWithErrorEnabled;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _activityIndicator.hidden = YES;
    _webView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _loginButton.hidden = NO;
    
    isWebViewDidFailLoadWithErrorEnabled = YES;
}

- (IBAction)login:(id)sender {
    
    [_webView loadRequest:[[VKAPIClient sharedClient] authorizationRequest]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    _loginButton.hidden = YES;
    _activityIndicator.hidden = NO;
    [_activityIndicator startAnimating];
    
}

- (IBAction)logout:(id)sender {
    
    [[VKAPIClient sharedClient] logoutUser];
    
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    
    if (request.mainDocumentURL.fragment != nil) {
        [[VKAPIClient sharedClient] getParametersFromRequest:request];
        
        NewsController *controller = (NewsController *)[self.storyboard instantiateViewControllerWithIdentifier:@"NewsController"];
        controller.managedObjectContext = self.managedObjectContext;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:navigationController animated:YES completion:^(void) {
            isWebViewDidFailLoadWithErrorEnabled = NO;
            [_webView loadHTMLString:@"" baseURL:nil];
        }];
        
    }
    
    return YES;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [_activityIndicator stopAnimating];
    _activityIndicator.hidden = YES;
    _loginButton.hidden = YES;
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    if (!isWebViewDidFailLoadWithErrorEnabled) return;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    _loginButton.hidden = NO;
    [_activityIndicator stopAnimating];
    _activityIndicator.hidden = YES;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"VKClient"
                                                    message:[NSString stringWithFormat:@"Connection error: %@", [error localizedDescription]]
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    NSLog(@"Authorization Request Error: %@", error);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
