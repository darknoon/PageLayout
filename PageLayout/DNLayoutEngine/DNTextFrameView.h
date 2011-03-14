//
//  DNTextFrameView.h
//  PageLayout
//
//  Created by Andrew Pouliot on 3/4/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DNLayoutManager;
@interface DNTextFrameView : UIView {
	DNLayoutManager *_layoutManager;
}

@property (nonatomic, assign) DNLayoutManager *layoutManager;

@end
