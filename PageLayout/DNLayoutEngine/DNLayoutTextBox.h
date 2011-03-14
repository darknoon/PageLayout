//
//  DNTextLayoutBox.h
//  PageLayout
//
//  Created by Andrew Pouliot on 3/13/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CXMLElement;
@class DNLayoutModule;
@class DNCSSStyle;
@interface DNLayoutTextBox : NSObject {
	DNLayoutModule *_module; //weak
    CXMLElement *_textBoxElement;
	DNCSSStyle *_cachedStyle;
}

- (id)initWithXMLRep:(CXMLElement *)inElement module:(DNLayoutModule *)inModule;

@property (nonatomic, readonly) DNCSSStyle *style;

- (CGRect)frame;

@end
