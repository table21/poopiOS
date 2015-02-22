//
//  ViewController.h
//  poopiOS
//
//  Created by Jacob Young on 2/21/15.
//  Copyright (c) 2015 Table21. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController

@property (strong, nonatomic) NSNumber *unisex;
@property (strong, nonatomic) NSNumber *disabled;

- (void)loadBathrooms:(NSMutableDictionary *)options;

@end