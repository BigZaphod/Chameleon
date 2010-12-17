//  Created by Sean Heber on 6/3/10.
#import <ApplicationServices/ApplicationServices.h>

@class UIImage;

void UIGraphicsPushContext(CGContextRef ctx);
void UIGraphicsPopContext();
CGContextRef UIGraphicsGetCurrentContext();

void UIGraphicsBeginImageContextWithOptions(CGSize size, BOOL opaque, CGFloat scale);
void UIGraphicsBeginImageContext(CGSize size);
UIImage *UIGraphicsGetImageFromCurrentImageContext();
void UIGraphicsEndImageContext();

void UIRectFill(CGRect rect);
void UIRectFillUsingBlendMode(CGRect rect, CGBlendMode blendMode);

void UIRectFrame(CGRect rect);
void UIRectFrameUsingBlendMode(CGRect rect, CGBlendMode blendMode);
