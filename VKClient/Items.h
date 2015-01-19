//
//  Items.h
//  VKClient
//
//  Created by Александр Алгашев on 18.01.15.
//  Copyright (c) 2015 Александр Алгашев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Profiles;

@interface Items : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * photos_src;
@property (nonatomic, retain) NSString * photos_src_big;
@property (nonatomic, retain) NSNumber * source_id;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * user_id;
@property (nonatomic, retain) Profiles *relationshipProfiles;

@end
