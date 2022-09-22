/*
 NSAttributedString+SSAdditions.h
 SSMessage
 
 Created by Dante Sabatier on 03/09/09.
 Copyright 2009 Dante Sabatier. All rights reserved.
 */

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

@interface NSAttributedString(SSMessageAdditions)

/*!
  @brief HTML string.
 */

@property (readonly, copy) NSString *HTMLString NS_SWIFT_NAME(htmlString) NS_AVAILABLE(10_5, 7_0);

/*!
  @brief plain text, diferent from <tt>string</tt>, specially if the instance contains attachments.
 */

@property (readonly, copy) NSString *plainText;

/*!
 @brief an array of <tt>NSTextAttachment</tt> instances. The attachments of the receiver.
 */

@property (readonly, copy) NSArray <NSTextAttachment *> *attachments NS_AVAILABLE(10_5, 7_0);

@end

NS_ASSUME_NONNULL_END
