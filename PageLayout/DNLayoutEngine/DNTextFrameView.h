//
//  DNTextFrameView.h
//  PageLayout
//
//  Created by Andrew Pouliot on 3/4/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DNTextLayoutManager;
@interface DNTextFrameView : UIView {
	DNTextLayoutManager *_layoutManager;
}

@property (nonatomic, assign) DNTextLayoutManager *layoutManager;

@end
