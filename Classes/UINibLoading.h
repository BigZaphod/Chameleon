//  Created by Sean Heber on 6/29/10.
#import <Foundation/Foundation.h>

@interface NSBundle (UINibLoading)
- (NSArray *)loadNibNamed:(NSString *)name owner:(id)owner options:(NSDictionary *)options;		// not implemented, but here to avoid some warnings
@end

@interface NSObject (UINibLoading)
- (void)awakeFromNib;
@end
