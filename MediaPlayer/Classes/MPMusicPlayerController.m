//  Created by Sean Heber on 8/10/10.
#import "MPMusicPlayerController.h"

NSString *const MPMusicPlayerControllerPlaybackStateDidChangeNotification = @"MPMusicPlayerControllerPlaybackStateDidChangeNotification";

@implementation MPMusicPlayerController

+ (MPMusicPlayerController *)iPodMusicPlayer
{
	return nil;
}

- (MPMusicPlaybackState)playbackState
{
	return MPMusicPlaybackStateStopped;
}

- (void)beginGeneratingPlaybackNotifications
{
}

- (void)endGeneratingPlaybackNotifications
{
}

@end
