//  Created by Sean Heber on 8/10/10.
#import "AVAudioPlayer.h"
#import <AppKit/NSSound.h>

@implementation AVAudioPlayer
@synthesize delegate=_delegate, url=_url, data=_data, numberOfLoops=_numberOfLoops;

- (id)init
{
	if ((self=[super init])) {
		_numberOfLoops = 0;
	}
	return self;
}

- (id)initWithContentsOfURL:(NSURL *)url error:(NSError **)outError
{
	if ((self=[self init])) {
		_url = [url retain];
		_player = [[NSSound alloc] initWithContentsOfURL:_url byReference:YES];
		[_player setDelegate:self];
	}
	return self;
}

- (id)initWithData:(NSData *)data error:(NSError **)outError
{
	if ((self=[self init])) {
		_data = [data retain];
		_player = [[NSSound alloc] initWithData:_data];
		[_player setDelegate:self];
	}
	return self;
}

- (void)dealloc
{
	[_player release];
	[_data release];
	[_url release];
	[super dealloc];
}

- (BOOL)prepareToPlay
{
	return YES;
}

- (BOOL)play
{
	return [_player play];
}

- (void)pause
{
	[(NSSound *)_player pause];
}

- (void)stop
{
	[(NSSound *)_player stop];
	_currentLoop = 0;
}

- (BOOL)isPlaying
{
	return [_player isPlaying];
}

- (float)volume
{
	float v = 0;
	@synchronized (self) {
		v = [_player volume];
	}
	return v;
}

- (void)setVolume:(float)v
{
	@synchronized (self) {
		[_player setVolume:v];
	}
}

- (void)setNumberOfLoops:(NSInteger)loops
{
	@synchronized (self) {
		_numberOfLoops = loops;
		_currentLoop = 0;
	}
}

- (NSTimeInterval)duration
{
	NSTimeInterval d = 0;
	@synchronized (self) {
		d = [_player duration];
	}
	return d;
}

- (void)setCurrentTime:(NSTimeInterval)newTime
{
	@synchronized (self) {
		[_player setCurrentTime:newTime];
	}
}

- (NSTimeInterval)currentTime
{
	NSTimeInterval t = 0;
	@synchronized (self) {
		t = [_player currentTime];
	}
	return t;
}

- (void)sound:(NSSound *)sound didFinishPlaying:(BOOL)finishedPlaying
{
	@synchronized (self) {
		if (sound == _player) {
			const BOOL notifyDelegate = [_delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying:successfully:)];
			
			if (finishedPlaying) {
				_currentLoop++;
				if (_currentLoop <= _numberOfLoops || _numberOfLoops < 0) {
					[_player play];
				} else if (notifyDelegate) {
					[_delegate audioPlayerDidFinishPlaying:self successfully:YES];
				}
			} else {
				[_delegate audioPlayerDidFinishPlaying:self successfully:NO];
			}
		}
	}
}

@end
