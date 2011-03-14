//
//  DNStoryModule.h
//  PageLayout
//
//  Created by Andrew Pouliot on 3/13/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DNCSS.h"

@class CXMLDocument;
@class CXMLElement;
@class DNLayoutPage;
@interface DNLayoutModule : NSObject {
    CXMLDocument *_module;
	
	//Stories are just the XML nodes for now
	NSArray *_stories;
	
	NSArray *_pagesLandscape;
	NSArray *_pagesPortrait;
	DNCSSContext *_cssContext;
}

- (id)initWithData:(NSData *)inData error:(NSError **)outError;

@property (nonatomic, readonly) DNCSSContext *cssContext;

- (DNCSSStyle *)computedStyleForElement:(CXMLElement *)inElement withInlineStylesheet:(DNCSSStylesheet *)inStylesheet;

- (NSUInteger)numberOfStories;
- (NSAttributedString *)attributedStringForStoryAtIndex:(NSUInteger)inIndex;


- (NSUInteger)pageCount;
- (DNLayoutPage *)pageAtIndex:(NSUInteger)inIndex forOrientation:(UIInterfaceOrientation)inInterfaceOrientation;

@end
