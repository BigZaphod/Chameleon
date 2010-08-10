//  Created by Sean Heber on 8/10/10.
#import <Foundation/Foundation.h>

enum {
	MPMusicPlaybackStateStopped,
	MPMusicPlaybackStatePlaying,
	MPMusicPlaybackStatePaused,
	MPMusicPlaybackStateInterrupted,
	MPMusicPlaybackStateSeekingForward,
	MPMusicPlaybackStateSeekingBackward
};
typedef NSInteger MPMusicPlaybackState;

extern NSString *const MPMusicPlayerControllerPlaybackStateDidChangeNotification;

@interface MPMusicPlayerController : NSObject {
}

+ (MPMusicPlayerController *)iPodMusicPlayer;

- (void)beginGeneratingPlaybackNotifications;
- (void)endGeneratingPlaybackNotifications;

@property (nonatomic, readonly) MPMusicPlaybackState playbackState;

@end
