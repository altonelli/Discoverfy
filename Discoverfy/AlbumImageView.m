//
//  AlbumImageView.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 9/22/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "AlbumImageView.h"

@implementation AlbumImageView



-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
//    NSLog(@"hittest called on AlbumImageView");
    
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
        
        
//        NSLog(@"AlumImageView: %@, hits?: %@ ",self.class, hitView);
        
        return hitView;
        
    }
    
    
    return nil;
    
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    
//    NSLog(@"point inside AlbumImageView called");
    
    CGRect bounds = self.bounds;
    
    if (CGRectContainsPoint(bounds, point)) {
        
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
