@class UIColor;

@interface UITableViewCellUnhighlightedState : NSObject{
@private
    UIColor *_backgroundColor;
    BOOL _highlighted;
    BOOL _opaque;
}

@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, assign) BOOL highlighted;
@property (nonatomic, assign) BOOL opaque;
@end
