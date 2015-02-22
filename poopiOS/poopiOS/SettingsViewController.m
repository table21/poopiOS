//
//  SettingsViewController.m
//  poopiOS
//
//  Created by Alan Wei on 2/21/15.
//  Copyright (c) 2015 Table21. All rights reserved.
//

#import "SettingsViewController.h"
#import "MapViewController.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *disabledSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *unisexSwitch;
@property (weak, nonatomic) IBOutlet UISlider *distanceSlider;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.unisexSwitch setOn:[self.unisex boolValue]];
    [self.disabledSwitch setOn:[self.disabled boolValue]];
    // Do any additional setup after loading the view.
}

- (IBAction)done:(id)sender {
    MapViewController *mapViewController = (MapViewController *)self.presentingViewController;
    NSMutableDictionary *options = [NSMutableDictionary new];
    options[@"disabled"] = [NSNumber numberWithBool:self.disabledSwitch.on];
    options[@"unisex"] = [NSNumber numberWithBool:self.unisexSwitch.on];
    [mapViewController loadBathrooms:options];
    mapViewController.unisex = [NSNumber numberWithBool:self.unisexSwitch.on];
    mapViewController.disabled = [NSNumber numberWithBool:self.disabledSwitch.on];
    [mapViewController dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
