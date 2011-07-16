#import "UIButtonContent.h"

static NSString* const kUIBackgroundImageKey = @"UIBackgroundImage";
static NSString* const kUIImageKey = @"UIImage";
static NSString* const kUIShadowColorKey = @"UIShadowColor";
static NSString* const kUITitleKey = @"UITitle";
static NSString* const kUITitleColorKey = @"UITitleColor";

@implementation UIButtonContent
@synthesize shadowColor = _shadowColor;
@synthesize titleColor = _titleColor;
@synthesize backgroundImage = _backgroundImage;
@synthesize image = _image;
@synthesize title = _title;

- (void) dealloc
{
    [_shadowColor release];
    [_titleColor release];
    [_backgroundImage release];
    [_image release];
    [_title release];
    [super dealloc];
}

- (id) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super init])) {
        self.backgroundImage = [coder decodeObjectForKey:kUIBackgroundImageKey];
        self.image = [coder decodeObjectForKey:kUIImageKey];
        self.shadowColor = [coder decodeObjectForKey:kUIShadowColorKey];
        self.title = [coder decodeObjectForKey:kUITitleKey];
        self.titleColor = [coder decodeObjectForKey:kUITitleColorKey];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)coder
{
    [self doesNotRecognizeSelector:_cmd];
}

- (id) copyWithZone:(NSZone*)zone
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
