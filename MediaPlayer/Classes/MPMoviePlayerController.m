//
//  MPMoviewPlayerController.m
//  MediaPlayer
//
//  Created by Michael Dales on 08/07/2011.
//  Copyright 2011 Digital Flapjack Ltd. All rights reserved.
//

#import "MPMoviePlayerController.h"
#import "UIInternalMovieView.h"

NSString *const MPMoviePlayerPlaybackDidFinishReasonUserInfoKey = @"MPMoviePlayerPlaybackDidFinishReasonUserInfoKey";

// notifications
NSString *const MPMoviePlayerPlaybackStateDidChangeNotification = @"MPMoviePlayerPlaybackStateDidChangeNotification";
NSString *const MPMoviePlayerPlaybackDidFinishNotification = @"MPMoviePlayerPlaybackDidFinishNotification";
NSString *const MPMoviePlayerLoadStateDidChangeNotification = @"MPMoviePlayerLoadStateDidChangeNotification";

@implementation MPMoviePlayerController

@synthesize view=_view;
@synthesize loadState=_loadState;
@synthesize contentURL=_contentURL;
@synthesize controlStyle=_controlStyle;
@synthesize movieSourceType=_movieSourceType;
@synthesize playbackState=_playbackState;
@synthesize repeatMode=_repeatMode;



///////////////////////////////////////////////////////////////////////////////
//
- (UIView*)view
{
    return movieView;
}



///////////////////////////////////////////////////////////////////////////////
//
- (MPMovieLoadState)loadState
{    
    NSNumber* loadState = [movie attributeForKey: QTMovieLoadStateAttribute];        
    
    switch ([loadState intValue]) {
        case QTMovieLoadStateError:            
        case QTMovieLoadStateLoading:              
        case QTMovieLoadStateLoaded:            
            _loadState = MPMovieLoadStateUnknown;            
            break;
            
        case QTMovieLoadStatePlayable:
            _loadState = MPMovieLoadStatePlayable;
            break;
            
        case QTMovieLoadStatePlaythroughOK:
            _loadState = MPMovieLoadStatePlaythroughOK;            
            break;
            
        case QTMovieLoadStateComplete:
            _loadState = MPMovieLoadStatePlaythroughOK;
            
            break;                                
    }
    
    return _loadState;
}


#pragma mark - notifications



///////////////////////////////////////////////////////////////////////////////
//
- (void)didEndOccurred: (NSNotification*)notification
{
    if (notification.object != movie)
        return;
    
    [[NSNotificationCenter defaultCenter] postNotificationName: MPMoviePlayerPlaybackDidFinishNotification
                                                        object: self];
}


///////////////////////////////////////////////////////////////////////////////
//
- (void)loadStateChangeOccurred: (NSNotification*)notification
{
    if (notification.object != movie)
        return;
        
    [[NSNotificationCenter defaultCenter] postNotificationName: MPMoviePlayerLoadStateDidChangeNotification
                                                        object: self];
}

#pragma mark - constructor/destructor

///////////////////////////////////////////////////////////////////////////////
//
- (id)initWithContentURL:(NSURL *)url
{
    self = [super init];
    if (self) 
    {
        _contentURL = [url retain];
        _loadState = MPMovieLoadStateUnknown;
        _controlStyle = MPMovieControlStyleDefault;
        _movieSourceType = MPMovieSourceTypeUnknown;
        _playbackState = MPMoviePlaybackStateStopped;
        _repeatMode = MPMovieRepeatModeNone;
        
        NSError *error = nil;
        movie = [[QTMovie alloc] initWithURL: url
                                       error: &error];
        
        movieView = [[UIInternalMovieView alloc] initWithMovie: movie];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(loadStateChangeOccurred:)
                                                     name: QTMovieLoadStateDidChangeNotification
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(didEndOccurred:)
                                                     name: QTMovieDidEndNotification 
                                                   object: nil];
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////
//
- (void)dealloc
{
    [_view release];
    [super dealloc];
}


#pragma mark - MPMediaPlayback


///////////////////////////////////////////////////////////////////////////////
//
- (void)play
{
    [movie play];
}


///////////////////////////////////////////////////////////////////////////////
//
- (void)pause
{
    //[movie pause];
}


///////////////////////////////////////////////////////////////////////////////
//
- (void)stop
{
    [movie stop];
}

@end
