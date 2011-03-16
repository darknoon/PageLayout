//
//  StoryViewController.h
//  PageLayout
//
//  Created by Andrew Pouliot on 3/4/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DNLayoutManager;
@interface StoryViewController : UIViewController {
    NSDictionary *storyDictionary;
	
	DNLayoutManager *textLayoutManager;
	
	UIScrollView *pageScrollView;
	
	NSString *_modulePath;
	
	//A page in an UIView with text frame subviews
	NSArray *_pages;
}

- (id)initWithModulePath:(NSString *)inModulePath;

@end
