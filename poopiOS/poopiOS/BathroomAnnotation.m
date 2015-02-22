//
//  BathroomAnnotation.m
//  poopiOS
//
//  Created by Alan Wei on 2/21/15.
//  Copyright (c) 2015 Table21. All rights reserved.
//

#import "BathroomAnnotation.h"

@implementation BathroomAnnotation

- (void)setData {
    Bathroom *bathroom = self.bathroom;
    
    self.coordinate = CLLocationCoordinate2DMake([bathroom.latitude doubleValue], [bathroom.longitude doubleValue]);
    
    self.title = bathroom.name;
//    self.subtitle = bathroom.directions;
}

@end
