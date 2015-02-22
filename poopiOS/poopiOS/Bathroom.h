//
//  Bathroom.h
//  poopiOS
//
//  Created by Alan Wei on 2/21/15.
//  Copyright (c) 2015 Table21. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bathroom : NSObject

@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *disabled;
@property (strong, nonatomic) NSNumber *unisex;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;

@property (strong, nonatomic) NSNumber *one;
@property (strong, nonatomic) NSNumber *two;
@property (strong, nonatomic) NSNumber *clean;
@property (strong, nonatomic) NSNumber *smell;

@property (strong, nonatomic) NSMutableArray *comments;

+ (void)getBathrooms:(NSDictionary *)options completion:(void (^)(NSMutableArray *bathrooms))completion;

@end
