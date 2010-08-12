//  Created by Sean Heber on 8/12/10.
#import <Foundation/Foundation.h>

@protocol SKRequestDelegate <NSObject>
@end

@interface SKRequest : NSObject {
@private
	id<SKRequestDelegate> _delegate;
}

@property(nonatomic, assign) id<SKRequestDelegate> delegate;

@end
