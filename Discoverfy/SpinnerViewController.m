//
//  SpinnerViewController.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 9/28/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "SpinnerViewController.h"
#import "PopOverView.h"
#import "UIImage+animatedGIF.h"

@interface SpinnerViewController ()

@property (nonatomic,weak) IBOutlet UILabel *topText;
@property (nonatomic,weak) IBOutlet UILabel *bottomText;
@property (nonatomic,weak) IBOutlet UIImageView *gif;


@end

@implementation SpinnerViewController


-(void)loadView{
    [super loadView];
    
    PopOverView *view = [[PopOverView alloc]init];
    
    self.view = view;
    
    [self placeSubviews];
    
    [self.view needsUpdateConstraints];
    
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

    
    NSURL *imgPath = [[NSBundle mainBundle]URLForResource:@"newLoading" withExtension:@"gif"];
    NSString *pathString = [imgPath absoluteString];
    NSData *imgData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:pathString]];
    NSLog(@"imgData: %@", imgData);
    UIImage *img = [UIImage animatedImageWithAnimatedGIFData:imgData];
    UIImageView *gif = [[UIImageView alloc]initWithImage:img];
    gif.frame = CGRectMake((240/2.0 - 60/2.0), (128/2.0 - 60/2.0), 60.0, 60.0);
    self.gif = gif;

    
    [self.view addSubview:self.topText];
    [self.view addSubview:self.bottomText];
    [self.view addSubview:self.gif];
}


-(void)updateViewConstraints{
    
    NSLayoutConstraint *yTop = [NSLayoutConstraint constraintWithItem:self.view
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.topText
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0
                                                             constant:0];
    NSLayoutConstraint *yGif = [NSLayoutConstraint constraintWithItem:self.view
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.gif
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
    
    
    NSArray *constraints = [[NSArray alloc]initWithObjects:yTop,yGif,yBottom, nil];
    
    [self.view addConstraints:constraints];
    
    NSDictionary *elementsDict = NSDictionaryOfVariableBindings(_topText,_gif,_bottomText);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(==5)-[_topText(==35)]-(==-4)-[_gif(==60)]-(==-4)-[_bottomText(==35)]-(==7)-|"]
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
