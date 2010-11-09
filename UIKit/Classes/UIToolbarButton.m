//  Created by Sean Heber on 11/3/10.
#import "UIToolbarButton.h"
#import "UIBarButtonItem.h"
#import "UIColor.h"
#import "UIImage+UIPrivate.h"

@implementation UIToolbarButton

- (id)initWithBarButtonItem:(UIBarButtonItem *)item
{
	if ((self=[super initWithFrame:CGRectMake(0,0,item.width,24)])) {
		//self.backgroundColor = [UIColor redColor];
		UIImage *image = nil;
		NSString *title = nil;
		
		if (item->_isSystemItem) {
			switch (item->_systemItem) {
				case UIBarButtonSystemItemAdd:
					image = [UIImage _buttonBarSystemItemAdd];
					break;
					
				case UIBarButtonSystemItemReply:
					image = [UIImage _buttonBarSystemItemReply];
					break;
			}
		} else {
			image = item.image;
			title = item.title;
		}
		
		[self setImage:image forState:UIControlStateNormal];
		[self setTitle:title forState:UIControlStateNormal];
	}
	return self;
}

@end
