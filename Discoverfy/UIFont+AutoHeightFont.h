//
//  UIFont+AutoHeightFont.h
//  Discoverfy
//
//  Created by Arthur Tonelli on 10/12/16.
//  Copyright © 2016 Arthur Tonelli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (AutoHeightFont)

+(UIFont*)autoHeightFontWithName:(NSString *)fontName forUILabelSize:(CGSize)labelSize withMinSize:(NSInteger)minSize;

@end
