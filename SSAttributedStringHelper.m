//
//  SSAttributedStringHelper.m
//  SSMessage
//
//  Created by Dante Sabatier on 03/09/09.
//  Copyright 2009 Dante Sabatier. All rights reserved.
//

#import "SSAttributedStringHelper.h"
#import "NSString+SSAdditions.h"
#import "NSTextAttachment+SSAdditions.h"
#import "SSMessageDefines.h"
#import <objc/objc-sync.h>

@implementation SSAttributedStringHelper

- (instancetype)initWithAttributedString:(NSAttributedString *)attributedString {
    self = [super init];
    if (self) {
        self.attributedString = attributedString;
    }
    return self;
}

- (void)dealloc  {
	[_attributedString release];
	[_plainText release];
	[_HTMLString release];
	[_attachments release];

	[super ss_dealloc];
}

- (NSAttributedString *)attributedString  {
	return SSAtomicAutoreleasedGet(_attributedString);
}

- (void)setAttributedString:(NSAttributedString *)attributedString  {
	 SSAtomicCopiedSet(_attributedString, attributedString);
}

- (NSString *)plainText  {
    objc_sync_enter(self);
    if (!_plainText) {
        NSAttributedString *attributedString = self.attributedString;
#if TARGET_OS_IPHONE
        _plainText = [attributedString.string copy];
#else
        NSData *rtfData = [attributedString RTFFromRange:NSMakeRange(0, attributedString.length) documentAttributes:@{}];
        NSAttributedString *rtf = [[NSAttributedString alloc] initWithRTF:rtfData documentAttributes:NULL];
        if (rtf) {
            NSError *error = nil;
            NSString *defaultValue = rtf.string;
            NSStringEncoding encoding = defaultValue.proposedStringEncoding;
            NSDictionary *attributes = @{NSDocumentTypeDocumentAttribute: NSPlainTextDocumentType, NSCharacterEncodingDocumentOption: @(encoding)};
            NSData *data = [rtf dataFromRange:NSMakeRange(0, rtf.length) documentAttributes:attributes error:&error];
            [rtf release];
            
            @try {
                if (!error) {
                    _plainText = [[NSString alloc] initWithData:data encoding:encoding];
                } else {
                    SSDebugLog(@"Warning!, Unable to covert to Plain Text…\r\nError:%@", error.localizedDescription);
                    _plainText = [defaultValue copy];
                }
            }
            @catch (NSException * e) {
                SSDebugLog(@"Warning!, Exception raised…\r\n%@:%@", e.name, e.reason);
                _plainText = [attributedString.string copy];
            }
            
        } else {
            SSDebugLog(@"Warning!, Unable to covert to Plain Text…");
            _plainText = [attributedString.string copy];
        }
#endif
    }
    objc_sync_exit(self);
	return SSAtomicAutoreleasedGet(_plainText);
}

- (NSString *)HTMLString {
    objc_sync_enter(self);
    if (!_HTMLString) {
#if defined(__MAC_10_5) || ((TARGET_OS_EMBEDDED || TARGET_OS_IPHONE) && defined(__IPHONE_7_0))
        NSAttributedString *attributedString = self.attributedString;
        NSString *defaultValue = attributedString.string;
        NSStringEncoding encoding = defaultValue.proposedStringEncoding;
        NSDictionary *attributes = nil;
#if TARGET_OS_IPHONE
        attributes = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(encoding)};
#else
        attributes = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentOption: @(encoding), NSExcludedElementsDocumentAttribute: @[@"html", @"head", @"body", @"xml"]};
#endif
        NSError *error = nil;
        NSData *data = [attributedString dataFromRange:NSMakeRange(0, attributedString.length) documentAttributes:attributes error:&error];
        if (!error) {
            _HTMLString = [[NSString alloc] initWithData:data encoding:encoding];
        } else {
            SSDebugLog(@"Unable to covert to HTML, Error:%@", error.localizedDescription);
            _HTMLString = [defaultValue copy];
        }
#endif
    }
    objc_sync_exit(self);
	return SSAtomicAutoreleasedGet(_HTMLString);
}

- (NSArray <NSTextAttachment *> *)attachments {
	objc_sync_enter(self);
    if (!_attachments) {
        NSAttributedString *attributedString = self.attributedString;
        NSMutableArray <NSTextAttachment *> *attachments = [NSMutableArray array];
        if (attributedString.length) {
            NSRange range = NSMakeRange(0, attributedString.length);
            NSUInteger index = 0;
            while (index < range.length) {
                NSRange effectiveRange;
                NSDictionary *attributes = [attributedString attributesAtIndex:index longestEffectiveRange:&effectiveRange inRange:range];
                NSTextAttachment *attachment = attributes[NSAttachmentAttributeName];
                if (attachment) {
                    NSFileWrapper *fileWrapper = attachment.fileWrapper;
                    if (!fileWrapper) {
                        NSError *error = nil;
                        NSDictionary *documentAttributes = @{NSDocumentTypeDocumentAttribute: NSRTFDTextDocumentType};
                        NSFileWrapper *selializedFileWrapper = [attributedString fileWrapperFromRange:effectiveRange documentAttributes:documentAttributes error:&error];
                        NSData *serializedDataRepresentation = selializedFileWrapper.serializedRepresentation;
                        if (serializedDataRepresentation) {
                            fileWrapper = [[NSFileWrapper alloc] initWithSerializedRepresentation:serializedDataRepresentation];
                            NSString *filename = fileWrapper.filename;
                            if (!filename && !(filename = fileWrapper.preferredFilename)) {
                                if ((filename = attachment.filename)) {
                                    fileWrapper.preferredFilename = filename;
                                    fileWrapper.filename = filename;
                                    attachment.fileWrapper = fileWrapper;
                                    [attachments addObject:attachment];
                                }
                            }
                            [fileWrapper release];
                        }
                    } else {
                        [attachments addObject:attachment];
                    }
                }
                index = effectiveRange.location + effectiveRange.length;
            }
        }
         _attachments = [attachments copy];
    }
    objc_sync_exit(self);
	return SSAtomicAutoreleasedGet(_attachments);
}

@end