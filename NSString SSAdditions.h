/*
 NSString+SSAdditions.h
 SSMessage
 
 Created by Dante Sabatier on 26/08/09.
 Copyright 2009 Dante Sabatier. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "SSMessageAddressee.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSString(SSMessageAddresseeAdditions) <SSMessageAddressee>

@end

@interface NSString(SSMessageEncodingAdditions)

/*!
 @return MIME name of given encoding
 */

+ (instancetype)mimeNameOfStringEncoding:(NSStringEncoding)encoding;

@property (readonly) NSStringEncoding proposedStringEncoding;

@end

@interface NSString(SSMessageAdditions)

@property (readonly, strong) NSString *stringByRemovingHTML NS_AVAILABLE(10_5, 7_0);
@property (readonly, strong) NSString *stringWithCRLFLineBreaks;

@end

NS_ASSUME_NONNULL_END
