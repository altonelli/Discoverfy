//
//  CardView.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 9/23/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "CardView.h"

@implementation CardView

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    
    NSLog(@"Hit Test called in card view");
    
    if (CGRectContainsPoint(self.bounds, point)) {
        
        NSLog(@"IN IF");

        
        return YES;
        
    }
    
    return [super pointInside:point withEvent:event];

    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
