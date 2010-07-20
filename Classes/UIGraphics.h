//  Created by Sean Heber on 6/3/10.
#import <ApplicationServices/ApplicationServices.h>

@class UIImage;

void UIGraphicsPushContext(CGContextRef ctx);
void UIGraphicsPopContext();
CGContextRef UIGraphicsGetCurrentContext();

void UIGraphicsBeginImageContext(CGSize size);
UIImage *UIGraphicsGetImageFromCurrentImageContext();
void UIGraphicsEndImageContext();

void UIRectFill(CGRect rect);
void UIRectFillUsingBlendMode(CGRect rect, CGBlendMode blendMode);
