//
//  StoryViewController.h
//  PageLayout
//
//  Created by Andrew Pouliot on 3/4/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DNTextLayoutManager;
@interface StoryViewController : UIViewController {
    NSDictionary *storyDictionary;
	
	DNTextLayoutManager *textLayoutManager;
	
	UIScrollView *pageScrollView;
	
	//A page in an UIView with text frame subviews
	NSArray *pages;
}

@end
