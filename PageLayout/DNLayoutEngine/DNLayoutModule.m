//
//  DNStoryModule.m
//  PageLayout
//
//  Created by Andrew Pouliot on 3/13/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import "DNLayoutModule.h"

#import "DNLayoutPage.h"

#import "CXMLDocument.h"

#import "DNCSSContext.h"
#import "DNCSSStyle.h"
#import "DNCSSStylesheet.h"
#import "CXML_libcss.h"

#import "UIFont+CoreTextExtensions.h"

@interface DNLayoutModule ()
- (void)createPagesForOrientation:(UIInterfaceOrientation)inOrientation;
@end

@implementation DNLayoutModule
@synthesize cssContext = _cssContext;

- (id)initWithData:(NSData *)inData error:(NSError **)outError;
{
	self = [super init];
		
	NSError *err = nil;
	_module = [[CXMLDocument alloc] initWithData:inData options:0 error:&err];
	if (err) {
		if (outError)
			*outError = err;
		NSLog(@"Error reading XML: err");
		[self release];
		return nil;
	}
	
	[self createPagesForOrientation:UIInterfaceOrientationPortrait];
	[self createPagesForOrientation:UIInterfaceOrientationLandscapeLeft];
	
	NSString *stylesheetText = @" \
	rep[type=\"ipad-vertical\"] text-box { \
		color:#ff0000; \
		font: bold 18px sans-serif; \
		width: 384px; \
	} ";
	
	DNCSSStylesheet *stylesheet = [[[DNCSSStylesheet alloc] initWithData:[stylesheetText dataUsingEncoding:NSUTF8StringEncoding]
																 baseURL:nil
																   error:&err] autorelease];
	_cssContext = [[DNCSSContext alloc] initWithStylesheet:stylesheet];

	
	return self;
}

- (void)dealloc {
    [_module release];
	[_stories release];
    [super dealloc];
}

+ (NSString *)repNameForIdiom:(UIUserInterfaceIdiom)inIdiom orientation:(UIInterfaceOrientation)inOrientation;
{
	if (inIdiom == UIUserInterfaceIdiomPhone) {
		if (UIInterfaceOrientationIsPortrait(inOrientation)) {
			return @"phone-portrait";
		} else {
			return @"phone-landscape";
		}
	} else if (inIdiom == UIUserInterfaceIdiomPad) {
		if (UIInterfaceOrientationIsPortrait(inOrientation)) {
			return @"pad-portrait";
		} else {
			return @"pad-landscape";
		}
	} else {
		return nil;
	}
}

- (void)createPagesForOrientation:(UIInterfaceOrientation)inOrientation;
{
	NSMutableArray *pagesMutable = [NSMutableArray array];
	
	NSString *repName = [DNLayoutModule repNameForIdiom:[[UIDevice currentDevice] userInterfaceIdiom] orientation:inOrientation];
	
	NSString *pagesXPath = [NSString stringWithFormat:@"//rep[@type='%@']//page", repName];
	
	NSError *error = nil;
	NSArray *pageNodes = [_module nodesForXPath:pagesXPath error:&error];
	
	for (CXMLElement *pageElement in pageNodes) {
		
		DNLayoutPage *page = [[[DNLayoutPage alloc] initWithXMLElement:pageElement module:self] autorelease];
		
		[pagesMutable addObject: page];
	}	
	
	if (UIInterfaceOrientationIsPortrait(inOrientation)) {
		[_pagesPortrait release];
		_pagesPortrait = [pagesMutable copy];		
	} else {
		[_pagesLandscape release];
		_pagesLandscape = [pagesMutable copy];		
	}
	NSAssert(!_pagesPortrait || !_pagesLandscape || _pagesPortrait.count == _pagesLandscape.count, @"Should have the same number of pages for portrait and landscape!");
}

- (NSUInteger)pageCount;
{
	return _pagesPortrait.count;
}

- (DNLayoutPage *)pageAtIndex:(NSUInteger)inIndex forOrientation:(UIInterfaceOrientation)inInterfaceOrientation;
{
	return UIInterfaceOrientationIsPortrait(inInterfaceOrientation) ? [_pagesPortrait objectAtIndex:inIndex]: [_pagesLandscape objectAtIndex:inIndex];
}

- (DNCSSStyle *)computedStyleForElement:(CXMLElement *)inElement withInlineStylesheet:(DNCSSStylesheet *)inStylesheet;
{
	return [_cssContext computedStyleForNode:inElement inlineStylesheet:inStylesheet withSelectHandlers:&CSSSelectHandler_CXML];
}

#pragma mark -

- (NSArray *)stories;
{
	if (!_stories) {
		NSError *error = nil;
		_stories = [[_module nodesForXPath:@"//story" error:&error] retain];
		if (!_stories) {
			NSLog(@"Error getting stories: %@", error);
		};
	}
	return _stories;
}

- (NSUInteger)numberOfStories;
{
	return self.stories.count;
}

- (NSAttributedString *)attributedStringForStoryAtIndex:(NSUInteger)inIndex;
{
	CFIndex theNumberOfSettings = 6;
	CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
	CTTextAlignment textAlignment = kCTLeftTextAlignment;
	CGFloat indent = 10.0;
	CGFloat spacing = 15.0;
	CGFloat topSpacing = 5.0;
	CGFloat lineSpacing = 1.0;
	CTParagraphStyleSetting theSettings[6] =
	{
		{ kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &textAlignment },
		{ kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakMode },
		{ kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(CGFloat), &indent },
		{ kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &spacing },
		{ kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &topSpacing },
		{ kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &lineSpacing }
	};
	
	CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(theSettings, theNumberOfSettings);
	
	
	UIFont *font = [UIFont fontWithName:@"Baskerville" size:18];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys: (id)[font CTFont], kCTFontAttributeName,
								paragraphStyle, kCTParagraphStyleAttributeName, nil];
	CFRelease(paragraphStyle);
	
	//Get the story
	
	CXMLElement *story = [self.stories objectAtIndex:inIndex];
	
	NSAttributedString *attributedSting = [[[NSAttributedString alloc] initWithString:[story stringValue]
																		   attributes:attributes] autorelease];
	
	return attributedSting;
}

@end
