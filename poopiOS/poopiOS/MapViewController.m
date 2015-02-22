//
//  ViewController.m
//  poopiOS
//
//  Created by Jacob Young on 2/21/15.
//  Copyright (c) 2015 Table21. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "UpdateBathroomViewController.h"
#import "SettingsViewController.h"
#import "CommentsViewController.h"
#import "BathroomAnnotation.h"
#import "MapViewController.h"
#import "Bathroom.h"

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKUserLocation *initialLocation;

@property (strong, nonatomic) NSMutableArray *bathrooms;
@property NSInteger index;
@property (strong, nonatomic) NSNumber *mode;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;

@property (weak, nonatomic) IBOutlet UIView *bathroomView;
@property (weak, nonatomic) IBOutlet UIView *pizzaView;
@property (weak, nonatomic) IBOutlet UIView *parkingView;
@property (weak, nonatomic) IBOutlet UIView *hotelView;

@end

@implementation MapViewController

#pragma mark - UIViewController hooks

- (void)viewDidLoad {
	[super viewDidLoad];
    
    self.disabled = @NO;
    self.unisex = @NO;
    
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
}

- (IBAction)search:(id)sender {
    [self.parkingView setHidden:NO];
    [UIView animateWithDuration:0.2 animations:^{
        self.parkingView.frame = CGRectMake(0, 0, self.view.frame.size.width / 2, self.view.frame.size.height / 2);
        [self.parkingView setAlpha:1];
    } completion:^(BOOL finished) {
        [self.pizzaView setHidden:NO];
        [UIView animateWithDuration:0.2 animations:^{
            self.pizzaView.frame = CGRectMake(self.view.frame.size.width / 2, 0, self.view.frame.size.width / 2, self.view.frame.size.height / 2);
            [self.pizzaView setAlpha:1];
        } completion:^(BOOL finished) {
            [self.bathroomView setHidden:NO];
            [UIView animateWithDuration:0.2 animations:^{
                self.bathroomView.frame = CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2, self.view.frame.size.width / 2, self.view.frame.size.height / 2);
                [self.bathroomView setAlpha:1];
            } completion:^(BOOL finished) {
                [self.hotelView setHidden:NO];
                [UIView animateWithDuration:0.2 animations:^{
                    self.hotelView.frame = CGRectMake(0, self.view.frame.size.height / 2, self.view.frame.size.width / 2, self.view.frame.size.height / 2);
                    [self.hotelView setAlpha:1];
                } completion:nil];
            }];
        }];
    }];
}

- (IBAction)parking:(id)sender {
    NSLog(@"loading parking");
    self.mode = @0;
    [self loadParkings:[NSMutableDictionary new]];
    [self removeViews];
}

- (IBAction)pizza:(id)sender {
    NSLog(@"loading pizza");
    self.mode = @1;
    [self loadPizzas:[NSMutableDictionary new]];
    [self removeViews];
}

- (IBAction)bathroom:(id)sender {
    NSLog(@"loading bathroom");
    self.mode = @2;
    [self loadBathrooms:[NSMutableDictionary new]];
    [self removeViews];
}

- (IBAction)hotel:(id)sender {
    NSLog(@"hotel");
    self.mode = @3;
    [self loadHotels:[NSMutableDictionary new]];
    [self removeViews];
}

- (void)removeViews {
    CGPoint topRight = CGPointMake(self.view.frame.size.width, 0);
    CGPoint bottomRight = CGPointMake(self.view.frame.size.width, self.view.frame.size.height);
    CGPoint bottomLeft = CGPointMake(0, self.view.frame.size.height);
    [UIView animateWithDuration:0.2 animations:^{
        self.parkingView.frame = CGRectMake(0, 0, 0, 0);
        [self.parkingView setAlpha:0];
    } completion:^(BOOL finished) {
        [self.parkingView setHidden:YES];
        [UIView animateWithDuration:0.2 animations:^{
            self.pizzaView.frame = CGRectMake(topRight.x, topRight.y, 0, 0);
            [self.pizzaView setAlpha:0];
        } completion:^(BOOL finished) {
            [self.pizzaView setHidden:YES];
            [UIView animateWithDuration:0.2 animations:^{
                self.bathroomView.frame = CGRectMake(bottomRight.x, bottomRight.y, 0, 0);
                [self.bathroomView setAlpha:0];
            } completion:^(BOOL finished) {
                [self.bathroomView setHidden:YES];
                [UIView animateWithDuration:0.2 animations:^{
                    self.hotelView.frame = CGRectMake(bottomLeft.x, bottomLeft.y, 0, 0);
                    [self.hotelView setAlpha:0];
                } completion:^(BOOL finished) {
                    [self.hotelView setHidden:YES];
                }];
            }];
        }];
    }];
    
}

#pragma mark - Bathroom loading

- (IBAction)refresh:(id)sender {
    NSMutableDictionary *options = [NSMutableDictionary new];
    options[@"location"] = self.locationManager.location;
    options[@"unisex"] = self.unisex;
    options[@"disabled"] = self.disabled;
    switch ([self.mode intValue]) {
        case 0:
            [self loadParkings:options];
            break;
        case 1:
            [self loadPizzas:options];
            break;
        case 2:
            [self loadBathrooms:options];
            break;
        case 3:
            [self loadHotels:options];
            break;
        default:
            break;
    }
}

- (void)loadPizzas:(NSMutableDictionary *)options {
    [self.activityIndicatorView startAnimating];
    CLLocation *location;
    if (self.locationManager.location == nil) {
        location = [[CLLocation alloc] initWithLatitude:37.4300198 longitude:-122.1736329];
    } else {
        location = self.locationManager.location;
    }
    
    options[@"location"] = location;
    
    options[@"type"] = @"pizza";
    
    [Bathroom getBathrooms:options completion:^(NSMutableArray *bathrooms) {
        self.bathrooms = bathrooms;
        self.index = 0;
        [self.indexLabel setText:[NSString stringWithFormat:@"%@ / 5", [[NSNumber numberWithInteger:self.index + 1] stringValue]]];
        [self loadDirections];
    }];
}

- (void)loadParkings:(NSMutableDictionary *)options {
    [self.activityIndicatorView startAnimating];
    CLLocation *location;
    if (self.locationManager.location == nil) {
        location = [[CLLocation alloc] initWithLatitude:37.4300198 longitude:-122.1736329];
    } else {
        location = self.locationManager.location;
    }
    
    options[@"location"] = location;
    
    options[@"type"] = @"parking";
    
    [Bathroom getBathrooms:options completion:^(NSMutableArray *bathrooms) {
        self.bathrooms = bathrooms;
        self.index = 0;
        [self.indexLabel setText:[NSString stringWithFormat:@"%@ / 5", [[NSNumber numberWithInteger:self.index + 1] stringValue]]];
        [self loadDirections];
    }];
}

- (void)loadHotels:(NSMutableDictionary *)options {
    [self.activityIndicatorView startAnimating];
    CLLocation *location;
    if (self.locationManager.location == nil) {
        location = [[CLLocation alloc] initWithLatitude:37.4300198 longitude:-122.1736329];
    } else {
        location = self.locationManager.location;
    }
    
    options[@"location"] = location;
    
    options[@"type"] = @"hotel";
    
    [Bathroom getBathrooms:options completion:^(NSMutableArray *bathrooms) {
        self.bathrooms = bathrooms;
        self.index = 0;
        [self.indexLabel setText:[NSString stringWithFormat:@"%@ / 5", [[NSNumber numberWithInteger:self.index + 1] stringValue]]];
        [self loadDirections];
    }];
}

- (void)loadBathrooms:(NSMutableDictionary *)options{
    [self.activityIndicatorView startAnimating];
    CLLocation *location;
    if (self.locationManager.location == nil) {
        location = [[CLLocation alloc] initWithLatitude:37.4300198 longitude:-122.1736329];
    } else {
        location = self.locationManager.location;
    }
    
    options[@"location"] = location;
    
    options[@"type"] = @"bathroom";
    
    [Bathroom getBathrooms:options completion:^(NSMutableArray *bathrooms) {
        self.bathrooms = bathrooms;
        self.index = 0;
        [self.indexLabel setText:[NSString stringWithFormat:@"%@ / 5", [[NSNumber numberWithInteger:self.index + 1] stringValue]]];
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
    
    if ([self.mode intValue] == 2) {
        [request setTransportType:MKDirectionsTransportTypeWalking];
    }
    
    [[[MKDirections alloc] initWithRequest:request] calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", [error description]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Failure!" message:@"Bathroom too far away!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                [self.activityIndicatorView stopAnimating];
            });
        } else {
            MKRoute *route = response.routes[0];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mapView removeOverlays:self.mapView.overlays];
                [self.mapView removeAnnotations:self.mapView.annotations];
                [self.mapView addOverlay:route.polyline];
                BathroomAnnotation *annotation = [BathroomAnnotation new];
                
                [annotation setBathroom:bathroom];
                [annotation setData];
                
                [self.mapView addAnnotation:annotation];
                
                [self.activityIndicatorView stopAnimating];
                
                [self setZoom];
                
                
            });
        }
    }];
}

- (void)setZoom {
    MKMapRect zoomRect = MKMapRectNull;
    NSArray *annotations = [self.mapView annotations];
    for (MKPointAnnotation *annotation in annotations) {
        
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(zoomRect)) {
            zoomRect = pointRect;
        } else {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
        
    }
    
    [self.mapView setVisibleMapRect:[self.mapView mapRectThatFits:zoomRect edgePadding:UIEdgeInsetsMake(50, 50, 50, 50)] animated:YES];
}

#pragma mark - Browsing

- (IBAction)next:(id)sender {
    if (self.index != [self.bathrooms count] - 1) {
        [self.activityIndicatorView startAnimating];
        self.index = self.index + 1;
        [self.indexLabel setText:[NSString stringWithFormat:@"%@ / 5", [[NSNumber numberWithInteger:self.index + 1] stringValue]]];
        [self loadDirections];
    }
}

- (IBAction)prior:(id)sender {
    if (self.index != 0) {
        [self.activityIndicatorView startAnimating];
        self.index = self.index - 1;
        [self.indexLabel setText:[NSString stringWithFormat:@"%@ / 5", [[NSNumber numberWithInteger:self.index + 1] stringValue]]];
        [self loadDirections];
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    // Only center map on user location on initial load
    if (self.initialLocation == nil) {
        self.initialLocation = userLocation;
        [self setZoom];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
        routeRenderer.strokeColor = [UIColor colorWithRed:52/256.0 green:152/256.0 blue:216/256.0 alpha:0.75];
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
        
        UIButton *showComments = [UIButton buttonWithType:UIButtonTypeContactAdd];
        UIButton *updateBathroom = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        showComments.frame = CGRectMake(0.f, 0.f, 32.f, 45.f);
        updateBathroom.frame = CGRectMake(0.f, 0.f, 32.f, 45.f);
        annotationView.leftCalloutAccessoryView = showComments;
        annotationView.rightCalloutAccessoryView = updateBathroom;
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    Bathroom *bathroom = ((BathroomAnnotation *)view.annotation).bathroom;
    if (control == view.leftCalloutAccessoryView) {
        [self performSegueWithIdentifier:@"showComments" sender:bathroom];
    } else {
        [self performSegueWithIdentifier:@"updateBathroom" sender:bathroom];
    }
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[UpdateBathroomViewController class]]) {
        UpdateBathroomViewController *viewController = segue.destinationViewController;
        
        [viewController setBathroom:sender];
    } else if ([segue.destinationViewController isKindOfClass:[CommentsViewController class]]) {
        CommentsViewController *viewController = segue.destinationViewController;

        [viewController setBathroom:sender];
    } else {
        SettingsViewController *viewController = segue.destinationViewController;
        viewController.unisex = self.unisex;
        viewController.disabled = self.disabled;
    }
}

@end
