//
//  NewsController.m
//  VKClient
//
//  Created by Александр Алгашев on 15.01.15.
//  Copyright (c) 2015 Александр Алгашев. All rights reserved.
//

#import "NewsController.h"
#import "VKAPIClient.h"
#import "NewsTableViewCell.h"
#import "DetailController.h"

#import "Items.h"
#import "Profiles.h"

@implementation NewsController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    DetailController *detailController = segue.destinationViewController;
    detailController.managedObjectContext = self.managedObjectContext;
    detailController.item = [_fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:(NewsTableViewCell *)sender]];
    
}

- (IBAction)logout:(id)sender {
    
    [[VKAPIClient sharedClient] logoutUser];
    [NSFetchedResultsController deleteCacheWithName:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(getLatestNews)
                  forControlEvents:UIControlEventValueChanged];
    
    [self coreDataInsertingGetLastNews:YES];
    [self coreDataFetching];
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext *context = self.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Items" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id == %@", [VKAPIClient sharedClient].user_id];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:10];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:context sectionNameKeyPath:nil
                                                   cacheName:@"Root"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

#pragma mark - Core Data Managment

- (void)coreDataInsertingGetLastNews:(BOOL)isLastNews
{
    NSManagedObjectContext *context = self.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Items" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id == %@", [VKAPIClient sharedClient].user_id];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:!isLastNews];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:1];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    NSDate *start_time;
    NSDate *end_time;
    if (fetchedObjects.count > 0) {
        Items *item = [fetchedObjects firstObject];
        start_time = [NSDate dateWithTimeInterval:(isLastNews) ? 1.0 : -86400.0 sinceDate:item.date];
        end_time = (isLastNews) ? nil : [NSDate dateWithTimeInterval: -1.0 sinceDate:item.date];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[VKAPIClient sharedClient] getNewsfeedWithStartTime:start_time
                                                 endTime:end_time
                                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                     
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                     
        NSDictionary *response = [(NSDictionary *)responseObject objectForKey:@"response"];
        NSArray *itemsArray = [response objectForKey:@"items"];
        NSArray *profilesArray = [response objectForKey:@"profiles"];
        
        [itemsArray enumerateObjectsUsingBlock:^(id itemObj, NSUInteger idx, BOOL *stop) {
            
            NSArray *photosArray = [itemObj objectForKey:@"photos"];
            NSString *text = [[itemObj objectForKey:@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            [profilesArray enumerateObjectsUsingBlock:^(id profileObj, NSUInteger idx, BOOL *stop) {
                
                BOOL isContentForShowExist = (photosArray != nil || (text !=nil && [text length] != 0));
                
                if ([[itemObj objectForKey:@"source_id"] compare:[profileObj objectForKey:@"uid"]] == NSOrderedSame && isContentForShowExist) {
                    
                    Profiles *profile = [NSEntityDescription insertNewObjectForEntityForName:@"Profiles" inManagedObjectContext:context];
                    profile.uid = [profileObj objectForKey:@"uid"];
                    profile.first_name = [profileObj objectForKey:@"first_name"];
                    profile.last_name = [profileObj objectForKey:@"last_name"];
                    profile.photo = [profileObj objectForKey:@"photo"];
                    
                    Items *item = [NSEntityDescription insertNewObjectForEntityForName:@"Items" inManagedObjectContext:context];
                    item.source_id = [itemObj objectForKey:@"source_id"];
                    item.date = [NSDate dateWithTimeIntervalSince1970:[[itemObj objectForKey:@"date"] doubleValue]];
                    item.text = text;
                    item.user_id = [VKAPIClient sharedClient].user_id;
                    item.relationshipProfiles = profile;
                    if (photosArray != nil) {
                        item.photos_src = [[photosArray lastObject] objectForKey:@"src"];
                        item.photos_src_big = [[photosArray lastObject] objectForKey:@"src_big"];
                    }
                    
                    return;
                }
            }];
        }];
        
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Couldn't save: %@", [error localizedDescription]);
        }
      
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"Getting news error: %@", error);
    
    }];

}

- (void)coreDataFetching
{
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
}

- (void)getLatestNews
{
    [self coreDataInsertingGetLastNews:YES];
    [self.tableView reloadData];
    
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.timeStyle = NSDateFormatterShortStyle;
        formatter.dateStyle = NSDateFormatterShortStyle;
        NSString *title = [NSString stringWithFormat:@"Последнее обновление: %@", [formatter stringFromDate:[NSDate date]]];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:nil];
        
        [self.refreshControl endRefreshing];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void)configureCell:(NewsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Items *item = [_fetchedResultsController objectAtIndexPath:indexPath];
    Profiles *profile = item.relationshipProfiles;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeStyle = NSDateFormatterMediumStyle;
    formatter.dateStyle = NSDateFormatterMediumStyle;
    
    cell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", profile.first_name, profile.last_name];
    cell.dateLabel.text = [formatter stringFromDate:item.date];
    
    
    
    __weak NewsTableViewCell *weakCell = cell;
    [[VKAPIClient sharedClient] setImageWithStringURL:profile.photo
                                 success:^(AFHTTPRequestOperation *operation, UIImage *image) {
                                     weakCell.photoImageView.image = image;
                                     [weakCell setNeedsLayout];
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     NSLog(@"%@", error);
                                 }];
    [cell.webView loadHTMLString:[self htmlStringWithImageURL:item.photos_src text:item.text] baseURL:nil];
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
        htmlString = [NSString stringWithFormat:@"<img src=%@ height='100' style='display:block; margin:0 auto !important'>",imageStringURL];
    } else return nil;
        
    return htmlString;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[NewsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger lastCellNumber = [tableView numberOfRowsInSection:0];
    if (indexPath.row == lastCellNumber - 1 && ![UIApplication sharedApplication].networkActivityIndicatorVisible) {
        [self coreDataInsertingGetLastNews:NO];
        [self.tableView reloadData];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

@end
