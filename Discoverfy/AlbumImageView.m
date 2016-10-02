//
//  AlbumImageView.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 9/22/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "AlbumImageView.h"

@implementation AlbumImageView



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"touches began in album view");
}

//-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
//    
////    NSLog(@"event: %@",event);
//    
//    UIView *hitView = [super hitTest:point withEvent:event];
//
////    NSLog(@"self view: %@, superview: %@",self,self.superview);
////
////    NSLog(@"user interaction enabled?: %hhd",self.userInteractionEnabled);
//    
//    if(hitView == self) return nil;
//    return hitView;
//    
//}

//-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
//    
//    return [super pointInside:point withEvent:event];
//}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
