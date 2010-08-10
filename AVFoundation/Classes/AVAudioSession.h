//  Created by Sean Heber on 8/10/10.
#import <Foundation/Foundation.h>

extern NSString *const AVAudioSessionCategoryAmbient;
extern NSString *const AVAudioSessionCategorySoloAmbient;
extern NSString *const AVAudioSessionCategoryPlayback;
extern NSString *const AVAudioSessionCategoryRecord;
extern NSString *const AVAudioSessionCategoryPlayAndRecord;
extern NSString *const AVAudioSessionCategoryAudioProcessing;

@interface AVAudioSession : NSObject {
}

+ (id)sharedInstance;

- (BOOL)setActive:(BOOL)beActive error:(NSError**)outError;
- (BOOL)setCategory:(NSString*)theCategory error:(NSError**)outError;

@end
