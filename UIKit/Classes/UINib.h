//
//  UINib.h
//  UIKit
//
//  Created by Home on 19/10/12.
//
//

#import <Foundation/Foundation.h>

// dummy class
@interface UINib : NSObject

// not implemented
+ (UINib *)nibWithNibName:(NSString *)name bundle:(NSBundle *)bundleOrNil;

// not implemented
+ (UINib *)nibWithData:(NSData *)data bundle:(NSBundle *)bundleOrNil;

// not implemented
- (NSArray *)instantiateWithOwner:(id)ownerOrNil options:(NSDictionary *)optionsOrNil;

@end
