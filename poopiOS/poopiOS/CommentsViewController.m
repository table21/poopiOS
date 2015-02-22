//
//  CommentsViewController.m
//  poopiOS
//
//  Created by Alan Wei on 2/21/15.
//  Copyright (c) 2015 Table21. All rights reserved.
//

#import "CommentsViewController.h"

@interface CommentsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.bathroom.comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
    
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:14]];
    [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
    [cell.textLabel setMinimumScaleFactor:.75];
    [cell.textLabel setNumberOfLines:2];
    
    [cell.textLabel setText:self.bathroom.comments[indexPath.row]];
    
    return cell;
}

- (IBAction)done:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
