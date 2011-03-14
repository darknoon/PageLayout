//
//  DNTextFrameView.m
//  PageLayout
//
//  Created by Andrew Pouliot on 3/4/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import "DNTextFrameView.h"
#import "DNLayoutManager.h"

@implementation DNTextFrameView
@synthesize layoutManager = _layoutManager;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	NSLog(@"drawing frame view: %@", self);
	[_layoutManager drawTextForFrameView:self];
}

- (void)dealloc
{
    [super dealloc];
}

@end
