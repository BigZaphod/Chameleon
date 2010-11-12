//  Created by Sean Heber on 11/12/10.
#import "UIView.h"

typedef enum {
	UITransitionNone = 0,		// no animation is done
	UITransitionFromLeft,		// the new view slides in from the left over top of the old view
	UITransitionFromRight,		// the new view slides in from the right over top of the old view
	UITransitionFromTop,		// the new view slides in from the top over top of the old view
	UITransitionFromBottom,		// the new view slides in from the bottom over top of the old view
	UITransitionPushLeft,		// the new view slides in from the right and pushes the old view off the left
	UITransitionPushRight,		// the new view slides in from the left and pushes the old view off the right
	UITransitionPushUp,			// the new view slides in from the bottom and pushes the old view off the top
	UITransitionPushDown,		// the new view slides in from the top and pushes the old view off the bottom
	UITransitionCrossFade,		// new view fades in as old view fades out
	UITransitionFadeIn,			// new view fades in over old view
	UITransitionFadeOut			// old view fades out to reveal the new view behind it
} UITransition;

@class UITransitionView;

@protocol UITransitionViewDelegate <NSObject>
- (void)transitionView:(UITransitionView *)transitionView didTransitionFromView:(UIView *)fromView toView:(UIView *)toView withTransition:(UITransition)transition;
@end

@interface UITransitionView : UIView {
	UITransition _transition;
	UIView *_view;
	id<UITransitionViewDelegate> _delegate;
}

- (id)initWithFrame:(CGRect)frame view:(UIView *)aView;

@property (nonatomic, retain) UIView *view;
@property (nonatomic, assign) UITransition transition;
@property (nonatomic, assign) id<UITransitionViewDelegate> delegate;

@end
