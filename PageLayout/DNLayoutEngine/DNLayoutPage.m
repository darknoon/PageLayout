//
//  DNStoryPage.m
//  PageLayout
//
//  Created by Andrew Pouliot on 3/13/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import "DNLayoutPage.h"

#import "DNLayoutTextBox.h"
#import "CXMLElement.h"

@implementation DNLayoutPage

- (id)initWithXMLElement:(CXMLElement *)inElement module:(DNLayoutModule *)inModule;
{
	self = [super init];
	if (!self) return nil;
	
	_module = inModule;
	
	_pageElement = [inElement retain];
	
	NSMutableArray *textBoxesMutable = [NSMutableArray array];
	for (CXMLElement *child in inElement.children) {
		if ([[child name] isEqualToString:@"text-box"]) {
			DNLayoutTextBox *textBox = [[[DNLayoutTextBox alloc] initWithXMLRep:child module:inModule] autorelease];
			[textBoxesMutable addObject:textBox];
		}
	}
	_textBoxes = [textBoxesMutable copy];

	return self;
}

- (NSArray *)textBoxes;
{
	return _textBoxes;
}

@end
