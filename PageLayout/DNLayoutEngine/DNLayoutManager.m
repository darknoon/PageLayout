//
//  DNTextLayoutManager.m
//  PageLayout
//
//  Created by Andrew Pouliot on 3/4/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import "DNLayoutManager.h"
#import "DNTextFrameView.h"

#import <libcss/libcss.h>
#import "DNCSS.h"

#import "CXML_libcss.h"
#import "DNLayoutModule.h"
#import "DNLayoutPage.h"
#import "DNLayoutTextBox.h"

#import "CXMLDocument.h"
#import "CXMLElement.h"

@interface DNLayoutManager ()
//1
- (void)addTextFrameView:(DNTextFrameView *)inTextFrameView;
- (void)removeAllTextFrameViews;

//2
- (void)layoutTextInViews;

@end

@implementation DNLayoutManager
@synthesize attributedText = _attributedText;


- (id)init;
{
    self = [super init];
    if (!self) return nil;
	
	_textFrameViews = [[NSMutableArray alloc] init];
    _frames = [[NSMutableArray alloc] init];

	NSError *error = nil;

	NSString *modulePath = [[NSBundle mainBundle] pathForResource:@"Module" ofType:@"dml"];
	NSData *moduleData = [[[NSData alloc] initWithContentsOfFile:modulePath] autorelease];
	
	if (!moduleData) {
		[self release];
		NSLog(@"Could not create text layout manager: no data");
		return nil;
	}
	
	_module = [[DNLayoutModule alloc] initWithData:moduleData error:&error];

	if (!_module) {
		[self release];
		NSLog(@"Could not create text layout manager: module error %@", error);
		return nil;
	}
	
	_attributedText = [[_module attributedStringForStoryAtIndex:0] retain];
	
    return self;
}

- (void)dealloc {
    [_textFrameViews release];
	[_attributedText release];
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

- (NSUInteger)numberOfPages;
{
	return [_module pageCount];
}

- (CGRect)pageBoundsForInterfaceIdiom:(UIUserInterfaceIdiom)inIdiom orientation:(UIInterfaceOrientation)inInterfaceOrientation;
{
	if (inIdiom == UIUserInterfaceIdiomPad) {
		if (UIInterfaceOrientationIsPortrait(inInterfaceOrientation)) {
			return (CGRect) {.size.width = 768.f, .size.height = 1024.f - 20.f}; // page.bounds;;
		} else {
			return (CGRect) {.size.width = 1024.f, .size.height = 768.f - 20.f}; // page.bounds;;
		}
	} else {
		return (CGRect) {.size.width = 320.f, .size.height = 480.f - 20.f};
	}
}

- (UIView *)pageViewForIndex:(NSUInteger)inIndex orientation:(UIInterfaceOrientation)inInterfaceOrientation;
{
	DNLayoutPage *page = [_module pageAtIndex:inIndex forOrientation:inInterfaceOrientation];
	
	CGRect pageBounds = [self pageBoundsForInterfaceIdiom:[UIDevice currentDevice].userInterfaceIdiom orientation:inInterfaceOrientation];
	
	UIView *pageView = [[[UIView alloc] initWithFrame:pageBounds] autorelease];
	
	for (DNLayoutTextBox *box in [page textBoxes]) {
		DNTextFrameView *textFrameView = [[[DNTextFrameView alloc] initWithFrame:[box frame]] autorelease];
		textFrameView.backgroundColor = [UIColor clearColor];
		
		[self addTextFrameView:textFrameView];
		[pageView addSubview:textFrameView];
	}
	
	return pageView;
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
	[_frames removeAllObjects];
	if (framesetter) {
		CFRelease(framesetter);
	}
	
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
