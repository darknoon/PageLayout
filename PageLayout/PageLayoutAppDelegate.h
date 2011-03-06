//
//  PageLayoutAppDelegate.h
//  PageLayout
//
//  Created by Andrew Pouliot on 3/4/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StoryViewController;
@interface PageLayoutAppDelegate : NSObject <UIApplicationDelegate> {
	StoryViewController *storyViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
