
@interface UIBarButtonItem () {
@package
    CGFloat _width;
    UIView *_customView;
    id _target;
    SEL _action;
    BOOL _isSystemItem;
    UIBarButtonSystemItem _systemItem;
    UIBarButtonItemStyle _style;
}
@end