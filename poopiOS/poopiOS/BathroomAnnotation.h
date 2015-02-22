//
//  BathroomAnnotation.h
//  poopiOS
//
//  Created by Alan Wei on 2/21/15.
//  Copyright (c) 2015 Table21. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "Bathroom.h"

@interface BathroomAnnotation : MKPointAnnotation

@property (strong, nonatomic) Bathroom *bathroom;

- (void)setData;

@end
