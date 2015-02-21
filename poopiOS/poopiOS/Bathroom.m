//
//  Bathroom.m
//  poopiOS
//
//  Created by Alan Wei on 2/21/15.
//  Copyright (c) 2015 Table21. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "Bathroom.h"

@interface Bathroom()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation Bathroom

+ (Bathroom *)bathroomWithDictionary:(NSDictionary *)dictionary {
    Bathroom *bathroom = [Bathroom new];
    
    bathroom.name = dictionary[@"name"];
    bathroom.directions = [[dictionary[@"directions"] class] isKindOfClass:[NSNull class]] ? dictionary[@"directions"] : @"";
    bathroom.latitude = [NSNumber numberWithDouble:[dictionary[@"latitude"] doubleValue]];
    bathroom.longitude = [NSNumber numberWithDouble:[dictionary[@"longitude"] doubleValue]];
    
    return bathroom;
}

+ (void)getBathrooms:(NSDictionary *)options completion:(void (^)(NSMutableArray *bathrooms))completion {
    NSParameterAssert(completion);
    
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:@"http"];
    [components setHost:@"www.refugerestrooms.org"];
    [components setPath:@"/api/v1/restrooms/by_location.json"];
    
    CLLocation *location = options[@"location"];
    
    NSURLQueryItem *count = [NSURLQueryItem queryItemWithName:@"per_page" value:@"5"];
    NSURLQueryItem *latitude = [NSURLQueryItem queryItemWithName:@"lat" value:[NSString stringWithFormat:@"%f", location.coordinate.latitude]];
    NSURLQueryItem *longitude = [NSURLQueryItem queryItemWithName:@"lng" value:[NSString stringWithFormat:@"%f", location.coordinate.longitude]];
    [components setQueryItems:@[count, latitude, longitude]];
    
    NSLog(@"%@", [components URL]);
    
    NSURLSessionDataTask *task = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]] dataTaskWithURL:[components URL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSArray *bathroomData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSMutableArray *bathrooms = [NSMutableArray new];
        for(NSDictionary *data in bathroomData) {
            [bathrooms addObject:[Bathroom bathroomWithDictionary:data]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(bathrooms);
        });
        
    }];
    [task resume];
}

@end
