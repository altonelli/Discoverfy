//
//  spinnerViewController.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 9/28/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "spinnerViewController.h"

@interface spinnerViewController ()

@end

@implementation spinnerViewController

-(void)startSpinner{
    
    self.view.hidden = NO;
    [self.spinner startAnimating];
    
}

-(void)stopSpinner{
    
    self.view.hidden = YES;
    [self.spinner stopAnimating];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
