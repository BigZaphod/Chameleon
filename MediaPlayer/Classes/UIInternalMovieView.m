//
//  UIInternalMovieView.m
//  MediaPlayer
//
//  Created by Michael Dales on 08/07/2011.
//  Copyright 2011 Digital Flapjack Ltd. All rights reserved.
//

#import "UIInternalMovieView.h"


@implementation UIInternalMovieView

@synthesize movie=_movie;

///////////////////////////////////////////////////////////////////////////////
//
- (id)initWithMovie:(QTMovie *)movie
{
    if ((self = [super init]) != nil)
    {
        self.movie = movie;
        
        movieLayer = [[QTMovieLayer alloc] initWithMovie: movie];
        
        [self.layer addSublayer: movieLayer];
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////
//
- (void)dealloc
{
    [_movie release];
    [super dealloc];
}



///////////////////////////////////////////////////////////////////////////////
//
- (void)setFrame:(CGRect)frame
{
    [super setFrame: frame];
    [movieLayer setFrame: frame];
}

@end
