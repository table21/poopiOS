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

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKUserLocation *initialLocation;

@property (strong, nonatomic) NSMutableArray *bathrooms;
@property NSInteger index;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

#pragma mark - UIViewController hooks

- (void)viewDidLoad {
	[super viewDidLoad];
    
    self.bathrooms = [NSMutableArray new];
    
    [self.mapView setDelegate:self];
    
    if (self.locationManager == nil) {
        self.locationManager = [CLLocationManager new];
        [self.locationManager setDelegate:self];
    }
    
    // iOS 8
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self loadBathrooms];
}

#pragma mark - Bathroom loading

- (void)loadBathrooms{
    [Bathroom getBathrooms:@{@"location":self.locationManager.location} completion:^(NSMutableArray *bathrooms) {
        self.bathrooms = bathrooms;
        self.index = 0;
        [self loadDirections];
    }];
}

- (void)loadDirections {
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    [request setSource:[[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:self.locationManager.location.coordinate addressDictionary:nil]]];
    
    NSLog(@"%f %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude);
    
    Bathroom *bathroom = self.bathrooms[self.index];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([bathroom.latitude doubleValue], [bathroom.longitude doubleValue]);
    
    NSLog(@"%f %f", [bathroom.latitude doubleValue], [bathroom.longitude doubleValue]);
    
    [request setDestination:[[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil]]];
    
    [request setTransportType:MKDirectionsTransportTypeWalking];
    
    [[[MKDirections alloc] initWithRequest:request] calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", [error description]);
        } else {
            MKRoute *route = response.routes[0];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mapView removeOverlays:self.mapView.overlays];
                [self.mapView removeAnnotations:self.mapView.annotations];
                [self.mapView addOverlay:route.polyline];
                MKPointAnnotation *annotation = [MKPointAnnotation new];
                [annotation setCoordinate:coordinate];
                [annotation setTitle:bathroom.name];
                [annotation setSubtitle:bathroom.directions];
                [self.mapView addAnnotation:annotation];
            });
        }
    }];
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

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    // Only center map on user location on initial load
    if (self.initialLocation == nil) {
        self.initialLocation = userLocation;
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude), 500, 500) animated:YES];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
        routeRenderer.strokeColor = [UIColor blueColor];
        routeRenderer.lineWidth = 5;
        return routeRenderer;
    }
    else return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"annotation"];
        
        if (annotationView) {
            annotationView.annotation = annotation;
        } else {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation"];
        }
        
        // Animate pin drop
        [annotationView setAnimatesDrop:YES];
        // Callout is the miniview that popups when tapped
        [annotationView setCanShowCallout:YES];
        
        return annotationView;
    }
    
    return nil;
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
