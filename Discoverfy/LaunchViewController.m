//
//  LaunchViewController.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 11/7/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "LaunchViewController.h"

@interface LaunchViewController ()

@end

@implementation LaunchViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up background gradient colors
    
    UIColor* skyBlue = [UIColor colorWithRed:71.0/255.0 green:181.0/255.0 blue:255.0/255.0 alpha:1.0];
    UIColor* teal = [UIColor colorWithRed:54.0/255.0 green:236.0/255.0 blue:244.0/255.0 alpha:1.0];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)skyBlue.CGColor, (id)teal.CGColor, nil];
    
    gradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];
    
    
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    
    // Add image
    
    UIImage *logo = [[UIImage alloc]init];
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 200.0)];
    [logoView setImage:logo];
    [self.view addSubview:logoView];
    
    
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
