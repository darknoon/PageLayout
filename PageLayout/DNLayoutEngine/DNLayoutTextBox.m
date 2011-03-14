//
//  DNTextLayoutBox.m
//  PageLayout
//
//  Created by Andrew Pouliot on 3/13/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import "DNLayoutTextBox.h"

#import "CXMLElement.h"
#import "DNLayoutModule.h"
#import "DNCSS.h"

@implementation DNLayoutTextBox

- (id)initWithXMLRep:(CXMLElement *)inElement module:(DNLayoutModule *)inModule;
{
	self = [super init];
	if (!self) return  nil;
	
	_textBoxElement = [inElement retain];
	
	_module = inModule;
	
	return self;
}


- (void)dealloc {
    [_cachedStyle release];
    [super dealloc];
}
- (DNCSSStyle *)style;
{
	if (!_cachedStyle) {
		//- (DNCSSStyle *)computedStyleForNode:(void *)node inlineStylesheet:(DNCSSStylesheet *)inInlineStylesheet withSelectHandlers:(css_select_handler *)inHandlers;

		DNCSSStylesheet *inlineStylesheet = nil;
		NSString *inlineStyle = [[_textBoxElement attributeForName:@"style"] stringValue];
		if (inlineStyle) {
			NSError *error = nil;
			inlineStylesheet = [[[DNCSSStylesheet alloc] initWithData:[inlineStyle dataUsingEncoding:NSUTF8StringEncoding] baseURL:nil isInline:YES error:&error] autorelease];
			if (!inlineStylesheet) {
				NSLog(@"Error with inline stylesheet: %@", error);
			}
		}
		_cachedStyle = [[_module computedStyleForElement:_textBoxElement withInlineStylesheet:inlineStylesheet] retain];
	}
	return _cachedStyle;
}

- (CGRect)frame;
{
	DNCSSStyle *style = self.style;
	return (CGRect) {
		.origin.x = [style left],
		.origin.y = [style top],
		.size.width = [style width],
		.size.height = [style height],
	};
}

- (NSString *)description;
{
	return [[super description] stringByAppendingFormat:@"{frame = %@, style = %@}", NSStringFromCGRect([self frame]), self.style];
}

@end
