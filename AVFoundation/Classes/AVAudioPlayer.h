//  Created by Sean Heber on 8/10/10.
#import <Foundation/Foundation.h>

@class AVAudioPlayer;

@protocol AVAudioPlayerDelegate <NSObject>
@optional
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error;
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player;
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player;
@end

@interface AVAudioPlayer : NSObject {
@private
	id _player;
	id <AVAudioPlayerDelegate> _delegate;
	NSInteger _numberOfLoops;
	NSInteger _currentLoop;
	NSURL *_url;
	NSData *_data;
	BOOL _isPaused;
}

- (id)initWithContentsOfURL:(NSURL *)url error:(NSError **)outError;
- (id)initWithData:(NSData *)data error:(NSError **)outError;

- (BOOL)prepareToPlay;		// always returns YES (lies!)
- (BOOL)play;
- (void)pause;
- (void)stop;

@property (readonly, getter=isPlaying) BOOL playing;
@property float volume;
@property NSInteger numberOfLoops;
@property (assign) id <AVAudioPlayerDelegate> delegate;
@property (readonly) NSTimeInterval duration;
@property NSTimeInterval currentTime;
@property (readonly) NSURL *url;
@property (readonly) NSData *data;

@end
