//
//  StoryViewController.m
//  PageLayout
//
//  Created by Andrew Pouliot on 3/4/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import "StoryViewController.h"
#import "DNLayoutManager.h"
#import "DNTextFrameView.h"

#import "UIFont+CoreTextExtensions.h"

#import <QuartzCore/QuartzCore.h>

@interface StoryViewController ()
@property (nonatomic, retain) NSArray *pages;
@end

@implementation StoryViewController
@synthesize pages = _pages;

- (id)initWithModulePath:(NSString *)inModulePath;
{
    self = [super initWithNibName:nil bundle:nil];
	
	_modulePath = [inModulePath retain];
	self.wantsFullScreenLayout = YES;
	
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

#pragma mark -


- (void)singleTap;
{
	[self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated;
{
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)setupPagesForOrientation:(UIInterfaceOrientation)inInterfaceOrientation;
{
	for (UIView *oldView in self.pages) {
		[oldView removeFromSuperview];
	}
	self.pages = nil;
	[textLayoutManager removeAllTextFrameViews];

	
	NSUInteger nPages = [textLayoutManager numberOfPages];
	NSMutableArray *pagesMutable = [NSMutableArray array];
	for (int i=0; i<nPages; i++) {
		UIView *page = [textLayoutManager pageViewForIndex:i orientation:inInterfaceOrientation];
		page.backgroundColor = [UIColor whiteColor];
		
		page.frame = (CGRect) {
			.origin.x = i * pageScrollView.frame.size.width,
			.size = page.bounds.size,
		};
		
		[pagesMutable addObject:page];
		[pageScrollView addSubview:page];
	}
	self.pages = pagesMutable;

	CGRect viewBounds = self.view.bounds;
	pageScrollView.contentSize = (CGSize) {
		.width = nPages * viewBounds.size.width,
		.height = 0,
	};
	[textLayoutManager layoutTextInViews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
		
	textLayoutManager = [[DNLayoutManager alloc] initWithModulePath:_modulePath];
	
	//TODO: replace with robust layout system...
	pageScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
	pageScrollView.pagingEnabled = YES;
	pageScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:pageScrollView];
	
	UITapGestureRecognizer *tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)] autorelease];
	[pageScrollView addGestureRecognizer:tapRecognizer];

	[self setupPagesForOrientation:self.interfaceOrientation];
		
	
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
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		return YES;
	} else {
		return interfaceOrientation == UIInterfaceOrientationPortrait;
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);
{
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		CATransition *transition = [CATransition animation];
		transition.type = kCATransitionFade;
		[pageScrollView.layer addAnimation:transition forKey:kCATransition];
		[self setupPagesForOrientation:toInterfaceOrientation];
		
		//TODO: Scroll to even page
	}
}

@end
