//
//  UIInternalMovieView.h
//  MediaPlayer
//
//  Created by Michael Dales on 08/07/2011.
//  Copyright 2011 Digital Flapjack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QTKit/QTKit.h>

@interface UIInternalMovieView : UIView {
@private
    QTMovieLayer *movieLayer;
}
@property (nonatomic, retain) QTMovie* movie;

- (id)initWithMovie: (QTMovie*)movie;

@end
