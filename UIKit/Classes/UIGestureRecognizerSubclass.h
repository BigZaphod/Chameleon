//  Created by Sean Heber on 1/24/11.
#import "UIGestureRecognizer.h"

@interface UIGestureRecognizer ()

@property (nonatomic,readwrite) UIGestureRecognizerState state;

- (void)ignoreTouch:(UITouch*)touch forEvent:(UIEvent*)event;		// don't override

// override, but be sure to call super
- (void)reset;
- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer;
- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end
