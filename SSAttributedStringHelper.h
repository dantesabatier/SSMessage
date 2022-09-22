//
//  SSAttributedStringHelper.h
//  SSMessage
//
//  Created by Dante Sabatier on 03/09/09.
//  Copyright 2009 Dante Sabatier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <UIKit/NSAttributedString.h>
#import <UIKit/NSTextAttachment.h>
#else
#import <AppKit/NSAttributedString.h>
#import <AppKit/NSTextAttachment.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface SSAttributedStringHelper : NSObject {
@private
	NSAttributedString *_attributedString;
	NSString *_plainText;
	NSString *_HTMLString;
	NSArray <NSTextAttachment *> *_attachments;
}
- (instancetype)initWithAttributedString:(NSAttributedString *)attributedString;
@property (readonly, copy) NSAttributedString *attributedString;
@property (readonly, copy) NSString *plainText;
@property (readonly, copy) NSString *HTMLString;
@property (readonly, copy) NSArray <NSTextAttachment *> *attachments;

@end

NS_ASSUME_NONNULL_END