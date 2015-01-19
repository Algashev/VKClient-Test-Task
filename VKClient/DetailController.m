//
//  DetailController.m
//  VKClient
//
//  Created by Александр Алгашев on 19.01.15.
//  Copyright (c) 2015 Александр Алгашев. All rights reserved.
//

#import "DetailController.h"
#import "VKAPIClient.h"

@interface DetailController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation DetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.webView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self.webView loadHTMLString:[self htmlStringWithImageURL:self.item.photos_src_big text:self.item.text] baseURL:nil];
    
}

- (NSString *)htmlStringWithImageURL:(NSString *)imageStringURL text:(NSString *)text
{
    if (imageStringURL != nil) {
        UIImage *image = [UIImage imageNamed:cachePathForImageURL(imageStringURL)];
        if (image != nil) {
            imageStringURL = [NSString stringWithFormat:@"file://%@", cachePathForImageURL(imageStringURL)];
        } else {
            [[VKAPIClient sharedClient] saveImageWithStringURL:imageStringURL];
        }
    }
    
    NSString *htmlText = [NSString stringWithFormat:@"<font face='HelveticaNeue-Light'>%@", text];
    
    NSString *htmlString;
    if (text != nil && imageStringURL == nil) {
        htmlString = htmlText;
    } else if (text != nil && imageStringURL != nil) {
        htmlString = [NSString stringWithFormat:@"%@%@",
                      [NSString stringWithFormat:@"<img src=%@ align='right' height='100'>",imageStringURL], htmlText];
    } else if (text == nil && imageStringURL != nil) {
        htmlString = [NSString stringWithFormat:@"<img src=%@ width='%f' style='display:block; margin:0 auto !important'>",imageStringURL, self.view.frame.size.width - 20.0];
    } else return nil;
    
    return htmlString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"VKClient"
                                                    message:[NSString stringWithFormat:@"Loading error: %@", [error localizedDescription]]
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    NSLog(@"Loading Request Error: %@", error);
    
}


@end
