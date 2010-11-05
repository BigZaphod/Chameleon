//  Created by Sean Heber on 11/3/10.
#import "UIToolbarButton.h"
#import "UIBarButtonItem.h"
#import "UIColor.h"

@implementation UIToolbarButton

- (id)initWithBarButtonItem:(UIBarButtonItem *)item
{
	if ((self=[super initWithFrame:CGRectMake(0,0,item.width,24)])) {
		self.backgroundColor = [UIColor redColor];
		
		if (item->_isSystemItem) {

		} else {
			if (item.image) {
				[self setImage:item.image forState:UIControlStateNormal];
			} else {
				[self setTitle:item.title forState:UIControlStateNormal];
			}
		}
		
		[self sizeToFit];
	}
	return self;
}

@end
