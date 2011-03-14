//
//  CXML_libcss.m
//  PageLayout
//
//  Created by Andrew Pouliot on 3/13/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#include "CXML_libcss.h"

#import "NSString-wapcaplet.h"

#import "css-cf-realloc.h"

#import <libcss/types.h>

#import "CXMLElement.h"
#import "CXMLDocument.h"

/* This macro is used to silence compiler warnings about unused function
 * arguments. */
#define UNUSED(x) ((x) = (x))


static css_error node_name(void *pw, void *node, css_qname *qname) {
	qname->name = [[(CXMLElement *)node name] LWCString];	
	return CSS_OK;
}

static css_error node_classes(void *pw, void *node,
							  lwc_string ***classes,
							  uint32_t *n_classes) {
	UNUSED(pw);
	//TODO: make this more efficient!
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *classString = [[(CXMLElement *)node attributeForName:@"class"] stringValue];
	NSArray *stringComponents = [classString componentsSeparatedByString:@""];
	
	if (stringComponents.count > 0) {
		lwc_string **classesPtr = NULL;
		//Make an array of strings with the proper allocator
		css_cf_realloc(classesPtr, stringComponents.count + sizeof(lwc_string *), pw);
		int i = 0;
		for (NSString *className in stringComponents) {
			classesPtr[i] = [className LWCString];
			i++;
		}
		*classes = classesPtr;
		*n_classes = stringComponents.count;
	} else {
		*classes = NULL;
		*n_classes = 0;
	}
	
	[pool drain];
	return CSS_OK;
}

static css_error node_id(void *pw, void *node, lwc_string **outId) {
	NSString *idString = [[(CXMLElement *)node attributeForName:@"id"] stringValue];
	*outId = [idString LWCString];
	return CSS_OK;
}

static css_error named_ancestor_node(void *pw, void *node,
									 const css_qname *qname, void **outAncestor) {
	UNUSED(pw);
	CXMLNode *parent = [(CXMLElement *)node parent];
	lwc_string *name = qname->name;
	NSString *nameString = [[NSString alloc] initWithBytesNoCopy:lwc_string_data(name) length:lwc_string_length(name) encoding:NSUTF8StringEncoding freeWhenDone:NO];

	BOOL found = NO;
	while (parent) {
		if ([nameString isEqualToString:[parent name]]) {
			*outAncestor = parent;
			found = YES;
			break;
		}
		parent = [parent parent];
	}
	if (!found) {
		*outAncestor = NULL;
	}
	
	[nameString release];
	return CSS_OK;
}

//Does the parent have name *name
static css_error named_parent_node(void *pw, void *node,
								   const css_qname *qname, void **outParent) {
	UNUSED(pw);
	CXMLNode *parent = [(CXMLElement *)node parent];
	
	if (parent) {
		lwc_string *name = qname->name;
		NSString *nameString = [[NSString alloc] initWithBytesNoCopy:lwc_string_data(name) length:lwc_string_length(name) encoding:NSUTF8StringEncoding freeWhenDone:NO];
		if ([nameString isEqualToString:[parent name]]) {
			*outParent = parent;
		} else {
			*outParent = NULL;
		}
		[nameString release];
	} else {
		*outParent = NULL;
	}
	return CSS_OK;
}

static css_error named_sibling_node(void *pw, void *node,
									const css_qname *qname, void **sibling) {
	*sibling = NULL;
	return CSS_OK;
}

static css_error named_generic_sibling_node(void *pw, void *node,
											const css_qname *qname, void **sibling) {
	*sibling = NULL;
	return CSS_OK;
}

static css_error parent_node(void *pw, void *node, void **parent) {
	*parent = [(CXMLNode *)node parent];
	return CSS_OK;
}

static css_error sibling_node(void *pw, void *node, void **sibling) {
	UNUSED(pw); UNUSED(node);
	*sibling = NULL;
	return CSS_OK;
}

static css_error node_has_name(void *pw, void *node,
							   const css_qname *qname, bool *outMatch) {
	UNUSED(pw);
	lwc_string *name = qname->name;
	NSString *nameString = [[NSString alloc] initWithBytesNoCopy:lwc_string_data(name) length:lwc_string_length(name) encoding:NSUTF8StringEncoding freeWhenDone:NO];
	
	*outMatch = [[(CXMLElement *)node name] isEqualToString:nameString];
	[nameString release];
	return CSS_OK;
}

static css_error node_has_class(void *pw, void *n, lwc_string *name,
                                bool *match) {
	UNUSED(pw); UNUSED(n); UNUSED(name);
	*match = false;
	return CSS_OK;
}

static css_error node_has_id(void *pw, void *n, lwc_string *name, bool *match) {
	UNUSED(pw); UNUSED(n); UNUSED(name);
	*match = false;
	return CSS_OK;
}

static css_error node_has_attribute(void *pw, void *node,
									const css_qname *qname, bool *match) {
	lwc_string *name = qname->name;
	NSString *attributeNameString = [[NSString alloc] initWithLWCString:name];
	CXMLNode *attribute = [(CXMLElement *)node attributeForName:attributeNameString];
	*match = attribute != nil;
	[attributeNameString release];
	return CSS_OK;
}

static css_error node_has_attribute_equal(void *pw, void *node,
										  const css_qname *qname, lwc_string *value,
										  bool *outMatch) {
	lwc_string *name = qname->name;
	NSString *attributeNameString = [[NSString alloc] initWithLWCString:name];
	CXMLNode *attribute = [(CXMLElement *)node attributeForName:attributeNameString];
	if (attribute) {
		NSString *attributeValueString = [[NSString alloc] initWithLWCString:value];
		*outMatch = [attributeValueString isEqualToString:attributeValueString];
		[attributeValueString release];
	} else {
		*outMatch = NO;
	}
	[attributeNameString release];
	return CSS_OK;
}

static css_error node_has_attribute_dashmatch(void *pw, void *node,
											  const css_qname *qname, lwc_string *value,
											  bool *match) {
	UNUSED(pw); UNUSED(node); UNUSED(qname); UNUSED(value);
	*match = false;
	return CSS_OK;
}

static css_error node_has_attribute_includes(void *pw, void *node,
											 const css_qname *qname, lwc_string *value,
											 bool *match) {
	UNUSED(pw); UNUSED(node); UNUSED(qname); UNUSED(value);
	*match = false;
	return CSS_OK;
}

static css_error node_has_attribute_prefix(void *pw, void *node,
										   const css_qname *qname, lwc_string *value,
										   bool *match) {
	UNUSED(pw); UNUSED(node); UNUSED(qname); UNUSED(value);
	*match = false;
	return CSS_OK;
}

static css_error node_has_attribute_suffix(void *pw, void *node,
										   const css_qname *qname, lwc_string *value,
										   bool *match) {
	UNUSED(pw); UNUSED(node); UNUSED(qname); UNUSED(value);
	*match = false;
	return CSS_OK;
}

static css_error node_has_attribute_substring(void *pw, void *node,
											  const css_qname *qname, lwc_string *value,
											  bool *match) {
	UNUSED(pw); UNUSED(node); UNUSED(qname); UNUSED(value);
	*match = false;
	return CSS_OK;
}

static css_error node_is_root(void *pw, void *n, bool *match) {
	UNUSED(pw); UNUSED(n);
	*match = false;
	return CSS_OK;
}

static css_error node_count_siblings(void *pw, void *n,
									 bool same_name, bool after, int32_t *count) {
	UNUSED(pw); UNUSED(n); UNUSED(same_name); UNUSED(after);
	//TODO: should I return -1 or something instead here to say un-impl?
	*count = 0;
	return CSS_OK;
}

static css_error node_is_empty(void *pw, void *n, bool *match) {
	UNUSED(pw); UNUSED(n);
	*match = false;
	return CSS_OK;
}

static css_error node_is_link(void *pw, void *n, bool *match) {
	UNUSED(pw); UNUSED(n);
	*match = false;
	return CSS_OK;
}

static css_error node_is_visited(void *pw, void *n, bool *match) {
	UNUSED(pw); UNUSED(n);
	*match = false;
	return CSS_OK;
}

static css_error node_is_hover(void *pw, void *n, bool *match) {
	UNUSED(pw); UNUSED(n);
	*match = false;
	return CSS_OK;
}

static css_error node_is_active(void *pw, void *n, bool *match) {
	UNUSED(pw); UNUSED(n);
	*match = false;
	return CSS_OK;
}

static css_error node_is_focus(void *pw, void *n, bool *match) {
	UNUSED(pw); UNUSED(n);
	*match = false;
	return CSS_OK;
}

static css_error node_is_enabled(void *pw, void *n, bool *match) {
	UNUSED(pw); UNUSED(n);
	//TODO: is this the best for un-impl?
	*match = true;
	return CSS_OK;
}

static css_error node_is_disabled(void *pw, void *n, bool *match) {
	UNUSED(pw); UNUSED(n);
	*match = false;
	return CSS_OK;
}

static css_error node_is_checked(void *pw, void *n, bool *match) {
	UNUSED(pw); UNUSED(n);
	*match = false;
	return CSS_OK;
}

static css_error node_is_target(void *pw, void *n, bool *match) {
	UNUSED(pw); UNUSED(n);
	*match = false;
	return CSS_OK;
}

static css_error node_is_lang(void *pw, void *n, lwc_string *lang,
                              bool *match) {
	UNUSED(pw); UNUSED(n); UNUSED(lang);
	*match = false;
	return CSS_OK;
}

// "base" value for property (inherit for all properties)
static css_error node_presentational_hint(void *pw, void *node,
                                          uint32_t property, css_hint *hint) {
	UNUSED(pw); UNUSED(node); UNUSED(property); UNUSED(hint);
	// a bit nasty: all *_INHERIT flags are 0, so simply set this to 0
	hint->status = 0;
	/*switch (property) {
	 case CSS_PROP_COLOR:
	 case CSS_PROP_BACKGROUND_COLOR:
	 hint->status = CSS_COLOR_INHERIT; break;
	 case CSS_PROP_FONT_FAMILY:
	 hint->status = CSS_FONT_FAMILY_INHERIT; break;
	 default:
	 return CSS_PROPERTY_NOT_SET;
	 }*/
	return CSS_OK;
}

static css_error ua_default_for_property(void *pw, uint32_t property,
                                         css_hint *hint) {
	UNUSED(pw);
	if (property == CSS_PROP_COLOR) {
		hint->data.color = 0xff000000;
		hint->status = CSS_COLOR_COLOR;
	} else if (property == CSS_PROP_BACKGROUND_COLOR) {
		hint->data.color = 0xffffffff;
		hint->status = CSS_COLOR_COLOR;
	} else if (property == CSS_PROP_FONT_FAMILY) {
		hint->data.strings = NULL;
		hint->status = CSS_FONT_FAMILY_SANS_SERIF;
	} else if (property == CSS_PROP_QUOTES) {
		hint->data.strings = NULL;
		hint->status = CSS_QUOTES_NONE;
	} else if (property == CSS_PROP_VOICE_FAMILY) {
		hint->data.strings = NULL;
		hint->status = 0;
	} else {
		return CSS_INVALID;
	}
	return CSS_OK;
}

static css_error compute_font_size(void *pw, const css_hint *parent,
                                   css_hint *size) {
	static css_hint_length sizes[] = {
		{ FLTTOFIX(6.75), CSS_UNIT_PT },
		{ FLTTOFIX(7.50), CSS_UNIT_PT },
		{ FLTTOFIX(9.75), CSS_UNIT_PT },
		{ FLTTOFIX(12.0), CSS_UNIT_PT },
		{ FLTTOFIX(13.5), CSS_UNIT_PT },
		{ FLTTOFIX(18.0), CSS_UNIT_PT },
		{ FLTTOFIX(24.0), CSS_UNIT_PT }
	};
	const css_hint_length *parent_size;
	
	UNUSED(pw);
	
	// Grab parent size, defaulting to medium if none
	if (parent == NULL) {
		parent_size = &sizes[CSS_FONT_SIZE_MEDIUM - 1];
	} else {
		assert(parent->status == CSS_FONT_SIZE_DIMENSION);
		assert(parent->data.length.unit != CSS_UNIT_EM);
		assert(parent->data.length.unit != CSS_UNIT_EX);
		parent_size = &parent->data.length;
	}
	
	assert(size->status != CSS_FONT_SIZE_INHERIT);
	
	if (size->status < CSS_FONT_SIZE_LARGER) {
		// Keyword -- simple
		size->data.length = sizes[size->status - 1];
	} else if (size->status == CSS_FONT_SIZE_LARGER) {
		// TODO: Step within table, if appropriate
		size->data.length.value = FMUL(parent_size->value, FLTTOFIX(1.2));
		size->data.length.unit = parent_size->unit;
	} else if (size->status == CSS_FONT_SIZE_SMALLER) {
		// TODO: Step within table, if appropriate
		size->data.length.value = FMUL(parent_size->value, FLTTOFIX(1.2));
		size->data.length.unit = parent_size->unit;
	} else if (size->data.length.unit == CSS_UNIT_EM ||
			   size->data.length.unit == CSS_UNIT_EX) {
		size->data.length.value = FMUL(size->data.length.value, parent_size->value);
		if (size->data.length.unit == CSS_UNIT_EX) {
			size->data.length.value = FMUL(size->data.length.value, FLTTOFIX(0.6));
		}
		size->data.length.unit = parent_size->unit;
	} else if (size->data.length.unit == CSS_UNIT_PCT) {
		size->data.length.value = FDIV(FMUL(size->data.length.value,
											parent_size->value), FLTTOFIX(100));
		size->data.length.unit = parent_size->unit;
	}
	
	size->status = CSS_FONT_SIZE_DIMENSION;
	
	return CSS_OK;
}


const css_select_handler CSSSelectHandler_CXML = {
	.handler_version = 1,
	
	node_name,
	node_classes,
	node_id,
	
	named_ancestor_node,
	named_parent_node,
	named_sibling_node,
	named_generic_sibling_node,
	
	parent_node,
	sibling_node,
	
	node_has_name,
	node_has_class,
	node_has_id,
	node_has_attribute,
	node_has_attribute_equal,
	node_has_attribute_dashmatch,
	node_has_attribute_includes,
	node_has_attribute_prefix,
	node_has_attribute_suffix,
	node_has_attribute_substring,
	
	node_is_root,
	node_count_siblings,
	node_is_empty,
	
	node_is_link,
	node_is_visited,
	node_is_hover,
	node_is_active,
	node_is_focus,
	
	node_is_enabled,
	node_is_disabled,
	node_is_checked,
	
	node_is_target,
	node_is_lang,
	
	node_presentational_hint,
	
	ua_default_for_property,
	
	compute_font_size,
};


