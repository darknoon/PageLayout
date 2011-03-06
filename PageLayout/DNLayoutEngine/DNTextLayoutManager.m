//
//  DNTextLayoutManager.m
//  PageLayout
//
//  Created by Andrew Pouliot on 3/4/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import "DNTextLayoutManager.h"
#import "DNTextFrameView.h"

@implementation DNTextLayoutManager
@synthesize attributedText = _attributedText;

- (id)init;
{
    self = [super init];
    if (!self) return nil;
	
	_textFrameViews = [[NSMutableArray alloc] init];
    _frames = [[NSMutableArray alloc] init];
	
    return self;
}

- (void)dealloc {
    [_textFrameViews release];
    [super dealloc];
}

- (void)addTextFrameView:(DNTextFrameView *)inTextFrameView;
{
	[_textFrameViews addObject:inTextFrameView];
	inTextFrameView.layoutManager = self;
}
- (void)removeAllTextFrameViews;
{
	for (DNTextFrameView *frameView in [[_textFrameViews mutableCopy] autorelease]) {
		[_textFrameViews removeObject:frameView];
		frameView.layoutManager = nil;
	}
}

- (void)drawTextForFrameView:(DNTextFrameView *)inTextFrameView;
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextTranslateCTM(context, 0.0, -inTextFrameView.bounds.size.height);
	
	
	NSUInteger index = [_textFrameViews indexOfObject:inTextFrameView];
	if (index != NSNotFound) {
		CTFrameRef frame = (CTFrameRef)[_frames objectAtIndex:index];
		CTFrameDraw(frame, UIGraphicsGetCurrentContext());
	} else {
		NSLog(@"Attemp to draw text for a unknown frame view");
	}
}

- (void)layoutTextInViews;
{
	if (framesetter) {
		CFRelease(framesetter);
	}
	[_frames removeAllObjects];
	
	framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attributedText);
	
	NSUInteger currentIndex = 0;
	
	//Create frames from frame views, distributing text as appropriate
    for (int frameViewIndex = 0; frameViewIndex < _textFrameViews.count; frameViewIndex++) 
    {
		DNTextFrameView *frameView = [_textFrameViews objectAtIndex:frameViewIndex];
		
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, frameView.bounds);

		CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(currentIndex, 0), path, NULL);
		
		NSAssert(frame != NULL, @"Could not create CTFrame...");
		
        CFRelease(path);
		
		[_frames addObject: (id)frame];

		CFRange frameRange = CTFrameGetVisibleStringRange(frame);
		currentIndex += frameRange.length;
		
		CFRelease(frame);
		
		[frameView setNeedsDisplay];
    }
	
}


@end
