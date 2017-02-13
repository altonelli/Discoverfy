//
//  SpinnerViewController.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 9/28/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "SpinnerViewController.h"

@interface SpinnerViewController ()

@end

@implementation SpinnerViewController

-(void)startSpinner{
    
    self.view.hidden = NO;
    
}

-(void)stopSpinner{
    
    self.view.hidden = YES;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.layer.borderWidth = 1;
    
    self.view.layer.borderColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    
    //    self.view.layer.borderColor = [UIColor colorWithRed:18/255.0 green:122/255.0 blue:216/255.0 alpha:1.0].CGColor;
    self.view.layer.cornerRadius = 2;
    self.view.layer.masksToBounds = YES;
    
    
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
