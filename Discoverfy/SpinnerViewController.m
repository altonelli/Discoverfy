//
//  SpinnerViewController.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 9/28/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "SpinnerViewController.h"
#import "PopOverView.h"

@interface SpinnerViewController ()

@property (nonatomic,weak) IBOutlet UILabel *topText;
@property (nonatomic,weak) IBOutlet UILabel *bottomText;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *spinner;


@end

@implementation SpinnerViewController


-(void)loadView{
    [super loadView];
    
    PopOverView *view = [[PopOverView alloc]init];
    
    self.view = view;
    
    [self placeSubviews];
    
    [self.view needsUpdateConstraints];
    
}

-(void)startSpinner{
    
//    self.view.hidden = NO;
    [self.spinner startAnimating];
    
}

-(void)stopSpinner{
    
//    self.view.hidden = YES;
    [self.spinner stopAnimating];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    
    
    // Do any additional setup after loading the view.
    

    
    
    
}

-(void)placeSubviews{
    
    UILabel *top = [[UILabel alloc]init];
    top.text = @"Hold On";
    top.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    top.font = [UIFont fontWithName:@"Futura" size:20.0];
    top.frame = CGRectMake(20.0, 5.0, 200.0, 35.0);
    top.textAlignment = NSTextAlignmentCenter;
    self.topText = top;
    
    UILabel *bottom = [[UILabel alloc]init];
    bottom.text = @"Currating Songs";
    bottom.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    bottom.font = [UIFont fontWithName:@"Futura" size:20.0];
    bottom.frame = CGRectMake(20.0, 88.0, 200.0, 35.0);
    bottom.textAlignment = NSTextAlignmentCenter;
    self.bottomText = bottom;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.frame = CGRectMake((240/2.0 - 37/2.0), (128/2.0 - 37/2.0), 37.0, 37.0);
    spinner.alpha = 1.0;
    self.spinner = spinner;
    
    [self.view addSubview:self.topText];
    [self.view addSubview:self.bottomText];
    [self.view addSubview:self.spinner];
    
}

-(void)updateViewConstraints{
    
    NSLayoutConstraint *yTop = [NSLayoutConstraint constraintWithItem:self.view
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.topText
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0
                                                             constant:0];
    NSLayoutConstraint *ySpinner = [NSLayoutConstraint constraintWithItem:self.view
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.spinner
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.0
                                                                 constant:0];
    NSLayoutConstraint *yBottom = [NSLayoutConstraint constraintWithItem:self.view
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.bottomText
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1.0
                                                                constant:0];
    
    
    NSArray *constraints = [[NSArray alloc]initWithObjects:yTop,ySpinner,yBottom, nil];
    
    [self.view addConstraints:constraints];
    
    NSDictionary *elementsDict = NSDictionaryOfVariableBindings(_topText,_spinner,_bottomText);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(==5)-[_topText(==35)]-(==5)-[_spinner(==37)]-(==5)-[_bottomText(==35)]-(==7)-|"]
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:elementsDict]];
    
    [super updateViewConstraints];
    
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
