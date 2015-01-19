//
//  VKAPIClient.m
//  VKClient
//
//  Created by Александр Алгашев on 14.01.15.
//  Copyright (c) 2015 Александр Алгашев. All rights reserved.
//

#import "VKAPIClient.h"

NSString *cachePathForImageURL(NSString *imageStringURL) {
    
    NSString *path = [NSURL URLWithString:imageStringURL].path;
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return [cachesDirectory stringByAppendingString:path];
    
}

void saveImageInCachesDirectory(UIImage *image, NSString *imageStringURL) {

    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:[cachePathForImageURL(imageStringURL) stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (error != nil) NSLog(@"Error creating directory: %@", [error localizedDescription]);
    
    [UIImageJPEGRepresentation(image, 1) writeToFile:cachePathForImageURL(imageStringURL) atomically:YES];

}

NSString * const kVKAuthURLString = @"https://oauth.vk.com/authorize";
NSString * const kClient_id = @"4730233";
NSString * const kScope = @"8194";
NSString * const kRedirect_uri = @"http://oauth.vk.com/blank.html";
NSString * const kDisplay = @"mobile";
NSString * const kResponse_type = @"token";

NSString * const kBaseDomain = @"vk.com";

NSString * const kVKAPIBaseURLString = @"https://api.vk.com/method/newsfeed.get";
NSString * const kNewsfeedCount = @"50";

NSString *unixtimeStringFromNSDate(NSDate *date) {
    return (date != nil) ? [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]]: @"";
};

@implementation VKAPIClient {
    NSDictionary *access_tokenParameters;
    NSString     *access_token;
}

+ (VKAPIClient *)sharedClient {
    
    static VKAPIClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [VKAPIClient manager];
    });
    
    return _sharedClient;
    
}

- (NSURLRequest *)authorizationRequest {
    
    NSString *stringRequest = [NSString stringWithFormat:@"%@?client_id=%@&scope=%@&redirect_uri=%@&display=%@&response_type=%@", kVKAuthURLString, kClient_id, kScope, kRedirect_uri, kDisplay, kResponse_type];
    NSURL *url = [NSURL URLWithString:stringRequest];
    
    return [NSURLRequest requestWithURL:url];
    
}

- (void)logoutUser {
    
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if([[cookie domain] rangeOfString:kBaseDomain].location != NSNotFound) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
    
    access_tokenParameters = nil;
    access_token = nil;
    
}

- (void)getParametersFromRequest:(NSURLRequest *)request {
    
    NSString *fragment = request.mainDocumentURL.fragment;

    NSArray *arrayOfParameters = [fragment componentsSeparatedByString:@"&"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    for (NSString *pair in arrayOfParameters) {
        NSArray *separatedPair = [pair componentsSeparatedByString:@"="];
        [parameters setObject:[separatedPair lastObject] forKey:[separatedPair firstObject]];
    }

    access_tokenParameters = parameters;
    access_token = [parameters objectForKey:@"access_token"];
    _user_id = [parameters objectForKey:@"user_id"];

}

- (void)getNewsfeedWithStartTime:(NSDate *)start_time
                         endTime:(NSDate *)end_time
                         success:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    NSString *start_time_unix = unixtimeStringFromNSDate(start_time);
    NSString *end_time_unix = unixtimeStringFromNSDate(end_time);
    
    NSDictionary *parametrs = @{
                                @"source_ids": @"",
                                @"filters": @"",
                                @"start_time": start_time_unix,
                                @"end_time": end_time_unix,
                                @"offset": @"0",
                                @"from": @"",
                                @"count": kNewsfeedCount,
                                @"max_photos": @"1",
                                @"access_token": access_token
                                };
    
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    [self GET:kVKAPIBaseURLString parameters:parametrs success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation, error);
        }
    }];
    
}

- (void)setImageWithStringURL:(NSString *)imageStringURL success:(void (^)(AFHTTPRequestOperation *operation, UIImage *image))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    UIImage *image = [UIImage imageNamed:cachePathForImageURL(imageStringURL)];
    if (image != nil) {
        
        success(nil, image);
        
    } else {
        
        self.responseSerializer = [AFImageResponseSerializer serializer];
        [self GET:imageStringURL parameters:nil success:^(AFHTTPRequestOperation *operation, UIImage *image) {
            if (success) {
                success(operation, image);
                saveImageInCachesDirectory(image, imageStringURL);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (failure) {
                failure(operation, error);
            }
        }];
    }
}

- (void)saveImageWithStringURL:(NSString *)imageStringURL
{
    self.responseSerializer = [AFImageResponseSerializer serializer];
    [self GET:imageStringURL parameters:nil success:^(AFHTTPRequestOperation *operation, UIImage *image) {
        
            saveImageInCachesDirectory(image, imageStringURL);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

    }];
}

@end
