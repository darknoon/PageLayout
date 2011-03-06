//
//  DNTextLayoutManager.h
//  PageLayout
//
//  Created by Andrew Pouliot on 3/4/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreText/CoreText.h>

@class DNTextFrameView;
@interface DNTextLayoutManager : NSObject {
@private
	CTFramesetterRef framesetter;
    NSMutableArray *_textFrameViews;
	NSMutableArray *_frames;
	NSAttributedString *_attributedText;
}

@property (nonatomic, copy) NSAttributedString *attributedText;

//1
- (void)addTextFrameView:(DNTextFrameView *)inTextFrameView;
- (void)removeAllTextFrameViews;

//2
- (void)layoutTextInViews;

//3
//Draws on main thread in UIGraphicsGetCurrentContext
- (void)drawTextForFrameView:(DNTextFrameView *)inTextFrameView;


@end
