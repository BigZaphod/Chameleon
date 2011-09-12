/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
    [(NSSound *)_player stop];	// I swear the docs say that NSSound should stop itself when released, but I don't think it's doing that. Or else something else bad is going on. This helps for now.
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
    BOOL r = NO;
    @synchronized (self) {
        r = _isPaused? [_player resume] : [_player play];
        _isPaused = NO;
    }
    return r;
}

- (void)pause
{
    @synchronized (self) {
        if (!_isPaused) {
            _isPaused = YES;
            [(NSSound *)_player pause];
        }
    }
}

- (void)stop
{
    @synchronized (self) {
        [(NSSound *)_player stop];
        _currentLoop = 0;
        _isPaused = NO;
    }
}

- (BOOL)isPlaying
{
    BOOL is = NO;
    @synchronized (self) {
        is = [_player isPlaying];
    }
    return is;
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
            
            _isPaused = NO;
            
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
