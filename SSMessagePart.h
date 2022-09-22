//
//  SSMessagePart.h
//  SSMessage
//
//  Created by Dante Sabatier on 9/26/09.
//  Copyright 2009 Dante Sabatier. All rights reserved.
//

#import "SSMessageConstants.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SSMessagePart <NSObject, NSCoding>

@optional

/*!
 @brief the unique identifier of the part.
 */

@property (nullable, readonly, copy) NSString *identifier;

/*!
 @brief \@"name=", generally the name of a file.
 */

@property (nullable, readonly, copy) NSString *name;

/*!
 @brief \@"filename=", the filename of the part.
 */

@property (nullable, readonly, copy) NSString *filename;

/*!
 @brief The content of the part.
 */

@property (nullable, readonly, copy) id <NSCopying, NSCoding> content;

/*!
 @brief \@"Content-Type:", he content type of the part.
 */

@property (nullable, readonly, copy) NSString *contentType;

/*!
 @brief \@"Content-Disposition:", the content disposition of the part.
 */

@property (nullable, readonly, copy) NSString *contentDisposition;

/*!
 @brief \@"Content-Transfer-Encoding:", transfer encoding.
 */

@property (nullable, readonly, copy) NSString *contentTransferEncoding;

/*!
 @brief \@"Content-Id:", the content id of the part.
 */

@property (nullable, readonly, copy) NSString *contentID;

/*!
 @brief the format of the part, used depending of the context.
 */

@property (nullable, readonly, copy) NSString *format;

/*!
 @brief \@"boundary=", the boundary delimiter of the part.
 */

@property (nullable, readonly, copy) NSString *boundary;

/*!
 @brief the protocol of the part.
 */

@property (nullable, readonly, copy) NSString *protocol;

/*!
 @brief \@"charset=", the charset of the part.
 */

@property (nullable, readonly, copy) NSString *charset;

/*!
 @brief the headers of the part.
 */

@property (nullable, readonly, copy) NSDictionary <SSMessagePartHeaderKey, id>*headers;

/*!
 @brief creation date
 */

@property (nullable, readonly, copy) NSDate *creationDate;

@end

/*!
 @class SSMessagePart
  @brief This class defines what email messages are composed of.
 @discussion An email message is composed of various parts which can be text parts, attachments and so on. Even a message is a part.
 */

@interface SSMessagePart : NSObject <NSCopying, SSMessagePart> {
@package
    NSString *_identifier;
    id <NSCopying, NSCoding> _content;
    NSString *_contentType;
    NSString *_contentID;
    NSString *_contentDisposition;
    NSString *_contentTransferEncoding;
    NSString *_name;
    NSString *_filename;
    NSString *_format;
    NSString *_boundary;
    NSString *_protocol;
    NSString *_charset;
    NSDictionary <SSMessagePartHeaderKey, id>*_headers;
    NSDate *_creationDate;
}

- (instancetype)init __attribute__((objc_designated_initializer));
- (instancetype)initWithCoder:(NSCoder *)decoder __attribute__((objc_designated_initializer));
@property (nullable, copy) NSString *identifier;
@property (nullable, copy) NSString *name;
@property (nullable, copy) NSString *filename;
@property (nullable, copy) id <NSCopying, NSCoding> content;
@property (nullable, copy) NSString *contentType;
@property (nullable, copy) NSString *contentDisposition;
@property (nullable, copy) NSString *contentTransferEncoding;
@property (nullable, copy) NSString *contentID;
@property (nullable, copy) NSString *format;
@property (nullable, copy) NSString *boundary;
@property (nullable, copy) NSString *protocol;
@property (nullable, copy) NSString *charset;
@property (nullable, copy) NSDictionary <SSMessagePartHeaderKey, id>*headers;
@property (nullable, copy) NSDate *creationDate;

@end

NS_ASSUME_NONNULL_END
