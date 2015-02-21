//
//  ViewController.m
//  poopiOS
//
//  Created by Jacob Young on 2/21/15.
//  Copyright (c) 2015 Table21. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "MapViewController.h"
#import "Bathroom.h"

@interface MapViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) NSMutableArray *bathrooms;
@property NSInteger index;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

#pragma mark - UIViewController hooks

- (void)viewDidLoad {
	[super viewDidLoad];
    
    self.bathrooms = [NSMutableArray new];
    
    if (self.locationManager == nil) {
        self.locationManager = [CLLocationManager new];
        [self.locationManager setDelegate:self];
    }
    
    // iOS 8
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

#pragma mark - Bathroom loading

- (void)loadBathrooms{
    [Bathroom getBathrooms:nil completion:^(NSMutableArray *bathrooms) {
        NSLog(@"%@", [self.bathrooms[0] name]);
        self.index = 0;
    }];
}

- (void)loadDirections {
    
}

#pragma mark - Browsing

- (IBAction)next:(id)sender {
    if (self.index != [self.bathrooms count] - 1) {
        self.index = self.index + 1;
    }
    [self loadDirections];
}

- (IBAction)prior:(id)sender {
    if (self.index != 0) {
        self.index = self.index - 1;
    }
    [self loadDirections];
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    //NSLog(@"STATUS: %d", status);
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [_mapView setShowsUserLocation:YES];
    }
    
    //We may want to remove this next bit; not sure if it will get annoying
    if (status == kCLAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Enable location monitoring for this app in your device privacy settings to see youself on the map." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

@end
