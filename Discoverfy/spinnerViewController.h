//
//  spinnerViewController.h
//  Discoverfy
//
//  Created by Arthur Tonelli on 9/28/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface spinnerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

-(void)startSpinner;
-(void)stopSpinner;


@end
