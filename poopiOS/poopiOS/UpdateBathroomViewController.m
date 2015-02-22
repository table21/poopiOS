//
//  UpdateBathroomViewController.m
//  poopiOS
//
//  Created by Alan Wei on 2/21/15.
//  Copyright (c) 2015 Table21. All rights reserved.
//

#import "UpdateBathroomViewController.h"
#import "EDStarRating.h"

@interface UpdateBathroomViewController () <EDStarRatingProtocol>

@property (weak, nonatomic) IBOutlet EDStarRating *oneStarRating;
@property (weak, nonatomic) IBOutlet EDStarRating *twoStarRating;
@property (weak, nonatomic) IBOutlet EDStarRating *smellStarRating;
@property (weak, nonatomic) IBOutlet EDStarRating *cleanlinessStarRating;
@property (weak, nonatomic) IBOutlet UITextView *commentsTextView;

@end

@implementation UpdateBathroomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *colors = @[ [UIColor colorWithRed:0.11f green:0.38f blue:0.94f alpha:1.0f], [UIColor colorWithRed:1.0f green:0.22f blue:0.22f alpha:1.0f], [UIColor colorWithRed:0.27f green:0.85f blue:0.46f alpha:1.0f], [UIColor colorWithRed:0.35f green:0.35f blue:0.81f alpha:1.0f]];
    // Setup control using iOS7 tint Color
    self.oneStarRating.backgroundColor  = [UIColor whiteColor];
    self.oneStarRating.starImage = [[UIImage imageNamed:@"star-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.oneStarRating.starHighlightedImage = [[UIImage imageNamed:@"star-highlighted-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.oneStarRating.maxRating = 5.0;
    self.oneStarRating.horizontalMargin = 0;
    self.oneStarRating.editable = YES;
    self.oneStarRating.rating = 2.5;
    self.oneStarRating.displayMode = EDStarRatingDisplayHalf;
    [self.oneStarRating setNeedsDisplay];
    self.oneStarRating.tintColor = colors[0];
    
    self.twoStarRating.backgroundColor  = [UIColor whiteColor];
    self.twoStarRating.starImage = [[UIImage imageNamed:@"star-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.twoStarRating.starHighlightedImage = [[UIImage imageNamed:@"star-highlighted-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.twoStarRating.maxRating = 5.0;
    self.twoStarRating.horizontalMargin = 0;
    self.twoStarRating.editable = YES;
    self.twoStarRating.rating = 2.5;
    self.twoStarRating.displayMode = EDStarRatingDisplayHalf;
    [self.twoStarRating setNeedsDisplay];
    self.twoStarRating.tintColor = colors[1];
    
    self.smellStarRating.backgroundColor  = [UIColor whiteColor];
    self.smellStarRating.starImage = [[UIImage imageNamed:@"star-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.smellStarRating.starHighlightedImage = [[UIImage imageNamed:@"star-highlighted-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.smellStarRating.maxRating = 5.0;
    self.smellStarRating.horizontalMargin = 0;
    self.smellStarRating.editable = YES;
    self.smellStarRating.rating = 2.5;
    self.smellStarRating.displayMode = EDStarRatingDisplayHalf;
    [self.smellStarRating setNeedsDisplay];
    self.smellStarRating.tintColor = colors[2];
    
    self.cleanlinessStarRating.backgroundColor  = [UIColor whiteColor];
    self.cleanlinessStarRating.starImage = [[UIImage imageNamed:@"star-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.cleanlinessStarRating.starHighlightedImage = [[UIImage imageNamed:@"star-highlighted-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.cleanlinessStarRating.maxRating = 5.0;
    self.cleanlinessStarRating.horizontalMargin = 0;
    self.cleanlinessStarRating.editable = YES;
    self.cleanlinessStarRating.rating = 2.5;
    self.cleanlinessStarRating.displayMode = EDStarRatingDisplayHalf;
    [self.cleanlinessStarRating setNeedsDisplay];
    self.cleanlinessStarRating.tintColor = colors[3];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
}

- (void)dismissKeyboard {
    [self.commentsTextView resignFirstResponder];
}

- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    NSDictionary *ratings = @{
        @"id":self.bathroom.id,
        @"one":[NSNumber numberWithFloat:self.oneStarRating.rating],
        @"two":[NSNumber numberWithFloat:self.twoStarRating.rating],
        @"smell":[NSNumber numberWithFloat:self.smellStarRating.rating],
        @"clean":[NSNumber numberWithFloat:self.cleanlinessStarRating.rating],
        @"text":[self.commentsTextView.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
    };
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://desolate-fortress-4361.herokuapp.com/reviews?bathroom_id=%@&one=%@&two=%@&smell=%@&clean=%@&text=%@", ratings[@"id"], ratings[@"one"], ratings[@"two"], ratings[@"smell"], ratings[@"clean"], ratings[@"text"]]]];
    
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"Thanks!" message:@"Thanks for leaving a review!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        });
    }];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
