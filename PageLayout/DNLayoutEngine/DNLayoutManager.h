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
@class DNCSSContext;
@class CXMLDocument;
@class DNLayoutModule;
@interface DNLayoutManager : NSObject {
@private
	CTFramesetterRef framesetter;
    NSMutableArray *_textFrameViews;
	NSMutableArray *_frames;
	NSAttributedString *_attributedText;
	DNLayoutModule *_module;
	NSString *_modulePath;
}

- (id)initWithModulePath:(NSString *)inModulePath;

@property (nonatomic, copy) NSAttributedString *attributedText;

//1
- (NSUInteger)numberOfPages;
- (UIView *)pageViewForIndex:(NSUInteger)inIndex orientation:(UIInterfaceOrientation)inInterfaceOrientation;

//2
- (void)layoutTextInViews;

//3
//Draws on main thread in UIGraphicsGetCurrentContext
- (void)drawTextForFrameView:(DNTextFrameView *)inTextFrameView;

//Cleanup....
//TODO: don't require this!!
- (void)removeAllTextFrameViews;


@end
