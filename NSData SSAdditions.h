/*
 NSData+SSAdditions.h
 SSMessage
 
 Created by Dante Sabatier on 26/08/09.
 Copyright 2009 Dante Sabatier. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <Security/Security.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData(SSMessageBase64Additions)

/*!
 @brief As in @link encodeBase64WithNewlines: encodeBase64WithNewlines: @/link, passing NO as option. Most of the times we do not need new lines.
 */

@property (readonly, copy) NSString *encodeBase64;

/*!
 @brief The framework use this method to encode attachments only because the message source is a litle more readable, but the resulting string still needs to end with CRLF line breaks. Most of the SMTP servers ignore things like this, but some others are very strict about it.
 @param encodeWithNewlines
 ...
 */

- (NSString *)encodeBase64WithNewlines:(BOOL)encodeWithNewlines;

@end

NS_ASSUME_NONNULL_END
