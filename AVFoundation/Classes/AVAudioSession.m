//  Created by Sean Heber on 8/10/10.
#import "AVAudioSession.h"

NSString *const AVAudioSessionCategoryAmbient = @"AVAudioSessionCategoryAmbient";
NSString *const AVAudioSessionCategorySoloAmbient = @"AVAudioSessionCategorySoloAmbient";
NSString *const AVAudioSessionCategoryPlayback = @"AVAudioSessionCategoryPlayback";
NSString *const AVAudioSessionCategoryRecord = @"AVAudioSessionCategoryRecord";
NSString *const AVAudioSessionCategoryPlayAndRecord = @"AVAudioSessionCategoryPlayAndRecord";
NSString *const AVAudioSessionCategoryAudioProcessing = @"AVAudioSessionCategoryAudioProcessing";

@implementation AVAudioSession

+ (id)sharedInstance
{
	return nil;
}

- (BOOL)setActive:(BOOL)beActive error:(NSError**)outError
{
	return NO;
}

- (BOOL)setCategory:(NSString*)theCategory error:(NSError**)outError
{
	return NO;
}

@end
