//
//  NewsTableViewCell.m
//  VKClient
//
//  Created by Александр Алгашев on 15.01.15.
//  Copyright (c) 2015 Александр Алгашев. All rights reserved.
//

#import "NewsTableViewCell.h"

@implementation NewsTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.webView setBackgroundColor:[UIColor clearColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
