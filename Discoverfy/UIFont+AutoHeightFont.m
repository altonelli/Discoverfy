//
//  UIFont+AutoHeightFont.m
//  Discoverfy
//
//  Created by Arthur Tonelli on 10/12/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import "UIFont+AutoHeightFont.h"

@implementation UIFont (AutoHeightFont)

+(UIFont*)autoHeightFontWithName:(NSString *)fontName forUILabelSize:(CGSize)labelSize withMinSize:(NSInteger)minSize{
    
    UIFont *font = nil;
    NSString *testString = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    
    NSInteger tempMin = minSize;
    NSInteger tempMax = 256;
    NSInteger mid = 0;
    NSInteger diff = 0;
    
    while (tempMin <= tempMax){
        mid = tempMin + (tempMax - tempMin) / 2;
        
        font = [UIFont fontWithName:fontName size:mid];
        
        diff = labelSize.height - [testString sizeWithAttributes:@{NSFontAttributeName: font}].height;
        
        if(mid == tempMin || mid == tempMax){
            
            if(diff < 0){
                return [UIFont fontWithName:fontName size:(mid - 1)];
            }
            
            return [UIFont fontWithName:fontName size:mid];
            
        }
        
        if (diff < 0) {
            tempMax = mid - 1;
        } else if (diff > 0){
            tempMin = mid + 1;
        } else {
            return [UIFont fontWithName:fontName size:mid];
        }
        
    }
    
    return [UIFont fontWithName:fontName size:mid];
    
}

@end
