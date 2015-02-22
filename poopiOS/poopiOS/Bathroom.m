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
    
    bathroom.id = dictionary[@"id"];
    bathroom.name = dictionary[@"name"];
    bathroom.disabled = [NSNumber numberWithBool:[dictionary[@"features"][@"disabled"] boolValue]];
    bathroom.unisex = [NSNumber numberWithBool:[dictionary[@"features"][@"unisex"] boolValue]];
    bathroom.latitude = [NSNumber numberWithDouble:[dictionary[@"latitude"] doubleValue]];
    bathroom.longitude = [NSNumber numberWithDouble:[dictionary[@"longitude"] doubleValue]];
    bathroom.one = [NSNumber numberWithDouble:[dictionary[@"reviews"][@"one"] doubleValue]];
    bathroom.two = [NSNumber numberWithDouble:[dictionary[@"reviews"][@"two"] doubleValue]];
    bathroom.clean = [NSNumber numberWithDouble:[dictionary[@"reviews"][@"clean"] doubleValue]];
    bathroom.smell = [NSNumber numberWithDouble:[dictionary[@"reviews"][@"smell"] doubleValue]];
    
    bathroom.comments = [NSMutableArray new];
    for (NSDictionary *comment in dictionary[@"comments"]) {
        [bathroom.comments addObject:comment[@"text"]];
    }
    
    return bathroom;
}

+ (void)getBathrooms:(NSDictionary *)options completion:(void (^)(NSMutableArray *bathrooms))completion {
    NSParameterAssert(completion);
    
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:@"https"];
    [components setHost:@"desolate-fortress-4361.herokuapp.com"];
    [components setPath:@"/search_bathrooms"];
    
    CLLocation *location = options[@"location"];
    
    NSURLQueryItem *latitude = [NSURLQueryItem queryItemWithName:@"latitude" value:[NSString stringWithFormat:@"%f", location.coordinate.latitude]];
    NSURLQueryItem *longitude = [NSURLQueryItem queryItemWithName:@"longitude" value:[NSString stringWithFormat:@"%f", location.coordinate.longitude]];
    
    if([options[@"disabled"] boolValue] && [options[@"unisex"] boolValue]) {
        NSURLQueryItem *disabled = [NSURLQueryItem queryItemWithName:@"disabled" value:@"true"];
        NSURLQueryItem *unisex = [NSURLQueryItem queryItemWithName:@"unisex" value:@"true"];
        [components setQueryItems:@[disabled, unisex, latitude, longitude]];
    } else if([options[@"disabled"] boolValue]) {
        NSURLQueryItem *disabled = [NSURLQueryItem queryItemWithName:@"disabled" value:@"true"];
        [components setQueryItems:@[disabled, latitude, longitude]];
    } else if([options[@"unisex"] boolValue]){
        NSURLQueryItem *unisex = [NSURLQueryItem queryItemWithName:@"unisex" value:@"true"];
        [components setQueryItems:@[unisex, latitude, longitude]];
    } else {
        [components setQueryItems:@[latitude, longitude]];
    }
    
    NSLog(@"%@", [components URL]);
    
    NSURLSessionDataTask *task = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]] dataTaskWithURL:[components URL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", [error description]);
        } else {
            NSArray *bathroomData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSMutableArray *bathrooms = [NSMutableArray new];
            for(NSDictionary *data in bathroomData) {
                [bathrooms addObject:[Bathroom bathroomWithDictionary:data]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(bathrooms);
            });
        }
    }];
    [task resume];
}

@end
