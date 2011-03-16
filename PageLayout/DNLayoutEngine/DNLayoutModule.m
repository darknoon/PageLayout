//
//  DNStoryModule.m
//  PageLayout
//
//  Created by Andrew Pouliot on 3/13/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import "DNLayoutModule.h"

#import "DNLayoutPage.h"

#import "DNCSS.h"
#import "CXML_libcss.h"
#import "TouchXML.h"

#import "UIFont+CoreTextExtensions.h"

@interface DNLayoutModule ()
- (void)createPagesForOrientation:(UIInterfaceOrientation)inOrientation;
@end

@implementation DNLayoutModule
@synthesize cssContext = _cssContext;

- (id)initWithData:(NSData *)inData baseURL:(NSURL *)inBaseURL error:(NSError **)outError;
{
	self = [super init];
		
	_baseURL = [inBaseURL retain];
	
	NSError *err = nil;
	_module = [[CXMLDocument alloc] initWithData:inData options:0 error:&err];
	if (err) {
		if (outError)
			*outError = err;
		NSLog(@"Error reading XML: err");
		[self release];
		return nil;
	}
		
	NSArray *stylesheetLinks = [_module nodesForXPath:@"//link[@rel='stylesheet']" error:&err];
	if (!stylesheetLinks) {
		if (outError)
			*outError = err;
		NSLog(@"Error finding stylesheets: %@", err);
		[self release];
		return nil;
	}

	_cssContext = [[DNCSSContext alloc] init];
	
	for (CXMLElement *linkElement in stylesheetLinks) {
		NSString *relativePath = [[linkElement attributeForName:@"href"] stringValue];
		NSURL *stylesheetURL = [[[NSURL alloc] initWithString:relativePath relativeToURL:_baseURL] autorelease];
		NSData *stylesheetData = [NSData dataWithContentsOfURL:stylesheetURL];

		DNCSSStylesheet *stylesheet = [[[DNCSSStylesheet alloc] initWithData:stylesheetData
																	 baseURL:nil
																	   error:&err] autorelease];
		if (!stylesheet) {
			if (outError)
				*outError = err;
			NSLog(@"Error loading stylesheet %@: %@", relativePath, err);
			[self release];
			return nil;
		}
		
		[_cssContext addStylesheet:stylesheet];
	}
	
	return self;
}

- (void)dealloc {
	[_baseURL release];
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
	//TODO: do this in a better way!
	if (!_pagesPortrait) {
		[self createPagesForOrientation:UIInterfaceOrientationPortrait];
	}
	return _pagesPortrait.count;
}

- (DNLayoutPage *)pageAtIndex:(NSUInteger)inIndex forOrientation:(UIInterfaceOrientation)inInterfaceOrientation;
{
	if (UIInterfaceOrientationIsPortrait(inInterfaceOrientation) && !_pagesPortrait) {
		[self createPagesForOrientation:inInterfaceOrientation];
	} else if (UIInterfaceOrientationIsLandscape(inInterfaceOrientation) && !_pagesLandscape) {
		[self createPagesForOrientation:inInterfaceOrientation];
	}
	
	return UIInterfaceOrientationIsPortrait(inInterfaceOrientation) ? [_pagesPortrait objectAtIndex:inIndex]: [_pagesLandscape objectAtIndex:inIndex];
}

- (DNCSSStyle *)computedStyleForElement:(CXMLElement *)inElement withInlineStylesheet:(DNCSSStylesheet *)inStylesheet;
{
	return [_cssContext computedStyleForNode:inElement inlineStylesheet:inStylesheet withSelectHandlers:(css_select_handler *)&CSSSelectHandler_CXML];
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

- (NSDictionary *)textAttributesForStyle:(DNCSSStyle *)inStyle;
{
	NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionary];
	
	//color
	if ([inStyle color]) {
		[mutableAttributes setObject:(id)[[inStyle color] CGColor] forKey:(id)kCTForegroundColorAttributeName];
	}
	
	[mutableAttributes setObject:[NSNumber numberWithFloat:[inStyle fontSize]] forKey:(id)kCTFontSizeAttribute];
	
	CTFontRef font = [inStyle font];
	if (font) {
		[mutableAttributes setObject:(id)font forKey:(id)kCTFontAttributeName];
	}
	
	return mutableAttributes;
}

- (void)appendNode:(CXMLNode *)inNode toString:(NSMutableAttributedString *)inString withParentStyle:(DNCSSStyle *)inParentStyle;
{
	//TODO: Where do we merge style from the story with style from the text box
	
	if ([inNode kind] == CXMLElementKind) {
		CXMLElement *element = (CXMLElement *)inNode;
		
		NSString *inlineStyle = [[element attributeForName:@"style"] stringValue];
		DNCSSStylesheet *inlineStylesheet = nil;
		if (inlineStyle) {
			NSError *error = nil;
			inlineStylesheet = [[DNCSSStylesheet alloc] initWithData:[inlineStyle dataUsingEncoding:NSUTF8StringEncoding] baseURL:nil isInline:YES error:&error];
			if (!inlineStylesheet) {
				NSLog(@"Error reading story inline stylesheet (\"%@\"): %@", inlineStyle, error);
			}
		}
		DNCSSStyle *elementStyle = [self computedStyleForElement:element withInlineStylesheet:inlineStylesheet];
		NSError *error = nil;
		//merge with parent style if provided
		if (inParentStyle) {
			elementStyle = [inParentStyle styleByMergingWithStyle:elementStyle withSelectHandlers:(css_select_handler *)&CSSSelectHandler_CXML error:&error];
			if (!elementStyle) {
				NSLog(@"Error merging style with parent for element: %@", element);
			}
		}
		
		//Recur to children
		for (CXMLNode *node in [element children]) {
			[self appendNode:node toString:inString withParentStyle:elementStyle];
		}
		
	} else if ([inNode kind] == CXMLTextKind) {
		//Append to string with parent
		NSAttributedString *styledText = [[NSAttributedString alloc] initWithString:[inNode stringValue] attributes:[self textAttributesForStyle:inParentStyle]];
		
		[inString appendAttributedString:styledText];
		[styledText release];
	} else {
		NSLog(@"How do we handle this kind??: %@", inNode);
	}
}

- (NSAttributedString *)attributedStringForStoryAtIndex:(NSUInteger)inIndex;
{
//	CFIndex theNumberOfSettings = 6;
//	CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
//	CTTextAlignment textAlignment = kCTLeftTextAlignment;
//	CGFloat indent = 10.0;
//	CGFloat spacing = 15.0;
//	CGFloat topSpacing = 5.0;
//	CGFloat lineSpacing = 1.0;
//	CTParagraphStyleSetting theSettings[6] =
//	{
//		{ kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &textAlignment },
//		{ kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakMode },
//		{ kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(CGFloat), &indent },
//		{ kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &spacing },
//		{ kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &topSpacing },
//		{ kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &lineSpacing }
//	};
//	
//	CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(theSettings, theNumberOfSettings);
//	
//	
//	UIFont *font = [UIFont fontWithName:@"Baskerville" size:18];
//	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys: (id)[font CTFont], kCTFontAttributeName,
//								paragraphStyle, kCTParagraphStyleAttributeName, nil];
//	CFRelease(paragraphStyle);
//	
	//Get the story
	
	CXMLElement *story = [self.stories objectAtIndex:inIndex];
	
	NSMutableAttributedString *mutableAttributedSting = [[NSMutableAttributedString alloc] init];
	[self appendNode:story toString:mutableAttributedSting withParentStyle:nil];
	
	NSAttributedString *immutableString = [[mutableAttributedSting copy] autorelease];
	[mutableAttributedSting release];
	return immutableString;
}

@end
