//
//  ImageButton.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 10/2/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "ImageButton.h"

@implementation ImageButton

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    NSLog(@"touches began in image button");
    
    

}



-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{

//    NSLog(@"event: %@",event);

    UIView *hitView = [super hitTest:point withEvent:event];

//    NSLog(@"self view: %@, superview: %@",self,self.superview);
//
//    NSLog(@"user interaction enabled?: %hhd",self.userInteractionEnabled);
//    NSLog(@"*** super view of button %@",self.superview);

    return hitView;

}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
