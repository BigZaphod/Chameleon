//CustomCellBackgroundView.h
#import <UIKit/UIKit.h>

typedef enum  {
    CustomCellBackgroundViewPositionTop, 
    CustomCellBackgroundViewPositionMiddle, 
    CustomCellBackgroundViewPositionBottom,
    CustomCellBackgroundViewPositionSingle,
    CustomCellBackgroundViewPositionAvataorSingle
} CustomCellBackgroundViewPosition;

@interface CustomCellBackgroundView : UIView {
    UIColor *borderColor;
    UIColor *fillColor;
    CustomCellBackgroundViewPosition position;
    
    UIColor *gradientStartColor;
    UIColor *gradientEndColor;
    
    BOOL useBlueSelectionGradient;
    CGGradientRef gradient;
    CGGradientRef selectGradient;
}

@property(nonatomic, strong) UIColor *borderColor, *fillColor;

@property(nonatomic, strong) UIColor *gradientStartColor, *gradientEndColor;
@property(nonatomic, assign) BOOL useBlueSelectionGradient;
@property(nonatomic) CustomCellBackgroundViewPosition position;


-(void)useBlackGradient;
-(void)useWhiteGradient;

@end