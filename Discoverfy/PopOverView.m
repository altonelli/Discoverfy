//
//  PopOverView.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 10/5/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "PopOverView.h"

@interface PopOverView ()



@end

@implementation PopOverView



-(id)init{
    
    self = [super init];
    
    UIView *gradientView = [self createGradientView];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    self.frame = CGRectMake(screenWidth/2 - 110, screenHeight/2 - 81, 220.0, 128.0);
    [self addSubview:gradientView];
    
    self.clipsToBounds = NO;
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0, 3);
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 8.0f;
    self.layer.shadowOpacity = 0.3;
    
    return self;
    
}

-(UIView *)createGradientView {

        
    UIView *view = [[UIView alloc]init];

    view.frame = CGRectMake(0, 0, 220.0, 128.0);

    
    view.layer.borderWidth = 1;
    
    view.layer.borderColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    
    view.layer.cornerRadius = 2;
    view.layer.masksToBounds = YES;
    view.clipsToBounds = YES;
    
    
    view.backgroundColor = [UIColor colorWithRed:66/255.0 green:175/255.0 blue:229/255.0 alpha:1.0];
    
    UIColor* skyBlue = [UIColor colorWithRed:71.0/255.0 green:181.0/255.0 blue:255.0/255.0 alpha:1.0];
    UIColor* teal = [UIColor colorWithRed:54.0/255.0 green:236.0/255.0 blue:244.0/255.0 alpha:1.0];
    
    
    UIColor* purpleColor = [UIColor colorWithRed:148.0/255.0 green:44.0/255.0 blue:203/255.0 alpha:1.0];
    UIColor* blueColor = [UIColor colorWithRed:63.0/255.0 green:98.0/255.0 blue:240.0/255.0 alpha:1.0];
    UIColor* midBlueColor = [UIColor colorWithRed:65.0/255.0 green:184.0/255.0 blue:240.0/255.0 alpha:1.0];
    
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)midBlueColor.CGColor,
                       (id)teal.CGColor,
                       nil];
    
    
    gradient.locations = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:0.2],
                          [NSNumber numberWithFloat:1.0],
                          nil];
    
    [view.layer insertSublayer:gradient atIndex:0];
    
    return view;
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
