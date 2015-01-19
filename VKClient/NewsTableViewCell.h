//
//  NewsTableViewCell.h
//  VKClient
//
//  Created by Александр Алгашев on 15.01.15.
//  Copyright (c) 2015 Александр Алгашев. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
