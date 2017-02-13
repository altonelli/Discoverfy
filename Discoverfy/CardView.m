//
//  CardView.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 9/23/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "CardView.h"

@implementation CardView

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
//    NSLog(@"hittest called on CardView");
    
    
    if ( !self.userInteractionEnabled || self.hidden || self.alpha == 0) {
        return nil;
    }
    
    
    if ([self pointInside:point withEvent:event]){
        
        UIView *hitView = self;
        
        UIView *hitSubview;
        
        for (UIView *subview in self.subviews){
            
            CGPoint insideSubview = [self convertPoint:point toView:subview];
            hitSubview = [subview hitTest:insideSubview withEvent:event];
            
            if (hitSubview){
                
                hitView = hitSubview;
            }
        }
        
        
//        NSLog(@"CardView: %@, hits?: %@ ",self.class, hitView);
        
        return hitView;
        
    }
    
    
    return nil;
    
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    
//    NSLog(@"point inside CardView called");
    
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
