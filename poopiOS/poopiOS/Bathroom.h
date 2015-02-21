//
//  Bathroom.h
//  poopiOS
//
//  Created by Alan Wei on 2/21/15.
//  Copyright (c) 2015 Table21. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bathroom : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *directions;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;

+ (void)getBathrooms:(NSDictionary *)options completion:(void (^)(NSMutableArray *bathrooms))completion;

@end
