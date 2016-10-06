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
    
    [self designLayout];

    
    return self;
    
}

-(void)designLayout {
    
    self.bounds = CGRectMake(0.0, 0.0, 128.0, 240.0);
    
    self.layer.borderWidth = 1;
    
    self.layer.borderColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    
    self.layer.cornerRadius = 2;
    self.layer.masksToBounds = YES;
    
    
    self.backgroundColor = [UIColor colorWithRed:66/255.0 green:175/255.0 blue:229/255.0 alpha:1.0];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
