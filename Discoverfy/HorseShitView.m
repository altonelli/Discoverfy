//
//  HorseShitView.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 10/4/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "HorseShitView.h"

@implementation HorseShitView

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
    NSLog(@"hittest called on HorseShitView");
    
    if ( !self.userInteractionEnabled || self.hidden || self.alpha == 0) {
        return nil;
    }
    
    
    if ([self pointInside:point withEvent:event]){
        
        UIView *hitView = self;
        
        UIView *hitSubview;
        
        for (UIView *subview in self.subviews){
            
            NSLog(@"subview: %@",subview);
            
            CGPoint insideSubview = [self convertPoint:point toView:subview];
            hitSubview = [subview hitTest:insideSubview withEvent:event];
            
            if (hitSubview){
                NSLog(@"***** Here is the hitSubView: %@",hitSubview);
                hitView = hitSubview;
            }
        }
        
        
        NSLog(@"HorseShitView: %@, hits?: %@ ",self.class, hitView);
        
        return hitView;
        
    }
    
    
    return nil;
    
}


-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    
    NSLog(@"point inside HorseShitView called");
    
    if (CGRectContainsPoint(self.bounds, point)) {
        
        return YES;
        
    }
    
    return NO;
    
    
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
