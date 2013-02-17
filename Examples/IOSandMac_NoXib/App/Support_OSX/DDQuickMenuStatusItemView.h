//
//  DDQuickMenuStatusItemView.h
//  IOSandMac_NoXib
//
//  Created by Dominik Pich on 16.02.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DDQuickMenuStatusItemView : NSView
@property (nonatomic, getter = isHighlighted) BOOL highlighted;
@property (nonatomic, strong) NSString *title;
@property(weak) NSStatusItem *item;

@property(assign) SEL action;
@property(weak) id target;
@end
