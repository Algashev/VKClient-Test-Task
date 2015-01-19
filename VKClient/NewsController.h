//
//  NewsController.h
//  VKClient
//
//  Created by Александр Алгашев on 15.01.15.
//  Copyright (c) 2015 Александр Алгашев. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface NewsController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (IBAction)logout:(id)sender;

@end
