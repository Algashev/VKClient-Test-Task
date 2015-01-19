//
//  ViewController.h
//  VKClient
//
//  Created by Александр Алгашев on 14.01.15.
//  Copyright (c) 2015 Александр Алгашев. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginController : UIViewController

@property  (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (IBAction)login:(id)sender;
- (IBAction)logout:(id)sender;

@end

