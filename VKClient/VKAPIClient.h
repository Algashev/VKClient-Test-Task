//
//  VKAPIClient.h
//  VKClient
//
//  Created by Александр Алгашев on 14.01.15.
//  Copyright (c) 2015 Александр Алгашев. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

extern NSString *cachePathForImageURL(NSString *imageStringURL);

@interface VKAPIClient : AFHTTPRequestOperationManager

@property (nonatomic, copy, readonly) NSString *user_id;

+ (VKAPIClient *)sharedClient;

- (NSURLRequest *)authorizationRequest;
- (void)logoutUser;
- (void)getParametersFromRequest:(NSURLRequest *)request;

- (void)getNewsfeedWithStartTime:(NSDate *)start_time
                         endTime:(NSDate *)end_time
                         success:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success
                       failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)setImageWithStringURL:(NSString *)imageStringURL
         success:(void(^)(AFHTTPRequestOperation *operation, UIImage *image))success
         failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)saveImageWithStringURL:(NSString *)imageStringURL;

@end
