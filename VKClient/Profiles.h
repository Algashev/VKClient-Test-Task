//
//  Profiles.h
//  VKClient
//
//  Created by Александр Алгашев on 15.01.15.
//  Copyright (c) 2015 Александр Алгашев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Items;

@interface Profiles : NSManagedObject

@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * last_name;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) Items *relationshipItems;

@end
