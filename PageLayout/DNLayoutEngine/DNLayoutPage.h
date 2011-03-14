//
//  DNStoryPage.h
//  PageLayout
//
//  Created by Andrew Pouliot on 3/13/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CXMLElement;
@class DNLayoutModule;
@interface DNLayoutPage : NSObject {
	DNLayoutModule *_module; //weak
    NSMutableArray *_textBoxes;
	CXMLElement *_pageElement;
}

- (id)initWithXMLElement:(CXMLElement *)inElement module:(DNLayoutModule *)inModule;

- (NSArray *)textBoxes;

@end
