//
//  DetailController.h
//  VKClient
//
//  Created by Александр Алгашев on 19.01.15.
//  Copyright (c) 2015 Александр Алгашев. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Items.h"
#import "Profiles.h"

@interface DetailController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Items *item;

@end
