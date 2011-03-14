//
//  StoryViewController.m
//  PageLayout
//
//  Created by Andrew Pouliot on 3/4/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import "StoryViewController.h"
#import "DNTextLayoutManager.h"
#import "DNTextFrameView.h"

#import "UIFont+CoreTextExtensions.h"

@implementation StoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		storyDictionary = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Story" ofType:@"plist"]] retain];
    }	
    return self;
}

- (void)dealloc
{
	[pageScrollView release];
	pageScrollView = nil;
	[textLayoutManager release];
	textLayoutManager = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
		
	NSUInteger nPages = 10;

	textLayoutManager = [[DNTextLayoutManager alloc] init];
	
	//TODO: replace with robust layout system...
	CGRect viewBounds = self.view.bounds;
	pageScrollView = [[UIScrollView alloc] initWithFrame:viewBounds];
	pageScrollView.contentSize = (CGSize) {
		.width = nPages * viewBounds.size.width,
		.height = 0,
	};
	pageScrollView.pagingEnabled = YES;
	[self.view addSubview:pageScrollView];
	
	NSMutableArray *pagesMutable = [NSMutableArray array];
	for (int i=0; i<nPages; i++) {
		UIView *page = [[[UIView alloc] initWithFrame:(CGRect) {
			.origin.x = i * viewBounds.size.width,
			.size.width = viewBounds.size.width,
			.size.height = viewBounds.size.height,
		}] autorelease];
		page.backgroundColor = [UIColor whiteColor];
		
		CGRect pageBounds = page.bounds;
				
		//Add two column for now...
		//TODO: use rects loaded from the configuration file
		DNTextFrameView *column1 = [[[DNTextFrameView alloc] initWithFrame:(CGRect) {
			.origin.x = 0,
			.size.width = pageBounds.size.width / 2.0f,
			.size.height = pageBounds.size.height,
		}] autorelease];
		column1.opaque = NO;

		DNTextFrameView *column2 = [[[DNTextFrameView alloc] initWithFrame:(CGRect) {
			.origin.x = pageBounds.size.width / 2.0f,
			.size.width = pageBounds.size.width / 2.0f,
			.size.height = pageBounds.size.height,
		}] autorelease];
		column2.opaque = NO;
		
		[textLayoutManager addTextFrameView:column1];
//		[column1 setBackgroundColor:[UIColor greenColor]];
		[page addSubview:column1];

		[textLayoutManager addTextFrameView:column2];
//		[column2 setBackgroundColor:[UIColor redColor]];
		[page addSubview:column2];
		
		[pagesMutable addObject:page];
		[pageScrollView addSubview:page];
	}
	
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
	
	NSAttributedString *attributedSting = [[[NSAttributedString alloc] initWithString:[storyDictionary objectForKey:@"text"] attributes:attributes] autorelease];
	textLayoutManager.attributedText = attributedSting;
	
	[textLayoutManager layoutTextInViews];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	[textLayoutManager release];
	textLayoutManager = nil;
	[pageScrollView release];
	pageScrollView = nil;

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);
{
	//TODO: set layout to appropriate layout for this orientation...
	//[textLayoutManager layoutTextInViews]
}

@end
