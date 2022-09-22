//
//  NSAttributedString+SSAdditions.m
//  SSMessage
//
//  Created by Dante Sabatier on 03/09/09.
//  Copyright 2009 Dante Sabatier. All rights reserved.
//

#import "NSAttributedString+SSAdditions.h"
#import "SSAttributedStringHelper.h"
#import "SSMessageDefines.h"

@implementation NSAttributedString(SSMessageAdditions)

- (SSAttributedStringHelper *)attributedStringHelper {
	SSAttributedStringHelper *attributedStringHelper = SSGetAssociatedValueForKey("attributedStringHelper");
	if (!attributedStringHelper) {
		attributedStringHelper = [[[SSAttributedStringHelper alloc] initWithAttributedString:self] autorelease];
	SSSetAssociatedValueForKey("attributedStringHelper", attributedStringHelper, OBJC_ASSOCIATION_RETAIN);
    }
    return attributedStringHelper;
}

- (NSString *)HTMLString {
	SSAttributedStringHelper *helper = self.attributedStringHelper;
    if (![[NSThread currentThread] isEqual:[NSThread mainThread]]) {
        [helper performSelectorOnMainThread:@selector(HTMLString) withObject:nil waitUntilDone:YES];
    }
	return helper.HTMLString;
}

- (NSString *)plainText {
	SSAttributedStringHelper *helper = self.attributedStringHelper;
    if (![[NSThread currentThread] isEqual:[NSThread mainThread]]) {
        [helper performSelectorOnMainThread:@selector(plainText) withObject:nil waitUntilDone:YES];
    }
	return helper.plainText;
}

- (NSArray <NSTextAttachment *> *)attachments {
	SSAttributedStringHelper *helper = self.attributedStringHelper;
    if (![[NSThread currentThread] isEqual:[NSThread mainThread]]) {
        [helper performSelectorOnMainThread:@selector(attachments) withObject:nil waitUntilDone:YES];
    }
	return helper.attachments;
}

@end
