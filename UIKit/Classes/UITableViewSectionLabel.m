//  Created by Sean Heber on 8/19/10.
#import "UITableViewSectionLabel.h"
#import "UIGraphics.h"
#import "AppKitIntegration.h"
#import <AppKit/NSGradient.h>

@implementation UITableViewSectionLabel
+ (UITableViewSectionLabel *)sectionLabelWithTitle:(NSString *)title
{
	UITableViewSectionLabel *label = [[self alloc] init];
	label.text = [NSString stringWithFormat:@"  %@", title];
	label.font = [UIFont boldSystemFontOfSize:17];
	label.textColor = [UIColor whiteColor];
	label.shadowColor = [UIColor colorWithRed:100/255.f green:105/255.f blue:110/255.f alpha:1];
	label.shadowOffset = CGSizeMake(0,1);
	return [label autorelease];
}

- (void)drawRect:(CGRect)rect
{
	const CGSize size = self.bounds.size;
	
	[[UIColor colorWithRed:166/255.f green:177/255.f blue:187/255.f alpha:1] setFill];
	UIRectFill(CGRectMake(0,0,size.width,1));
	
	UIColor *startColor = [UIColor colorWithRed:145/255.f green:158/255.f blue:171/255.f alpha:1];
	UIColor *endColor = [UIColor colorWithRed:185/255.f green:193/255.f blue:201/255.f alpha:1];
	
	NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[startColor NSColor] endingColor:[endColor NSColor]];
	[gradient drawFromPoint:NSMakePoint(0,1) toPoint:NSMakePoint(0,size.height-1) options:0];
	[gradient release];
	
	[[UIColor colorWithRed:153/255.f green:158/255.f blue:165/255.f alpha:1] setFill];
	UIRectFill(CGRectMake(0,size.height-1,size.width,1));
	
	[super drawRect:rect];
}

@end
