//
//  SSMessageAddressee.h
//  SSMessage
//
//  Created by Dante Sabatier on 9/29/09.
//  Copyright 2009 Dante Sabatier. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 @protocol SSMessageAddressee
 @brief Represents an email address.
 */

@protocol SSMessageAddressee <NSObject, NSCopying, NSCoding>

@optional

/*!
 @brief The name. Can be nil.
 @textblock
 E.g. with "John Doe <jdoe@domain.com>" as the full email address, the name would be "John Doe".
 @/textblock
 */

@property (nullable, readonly, copy) NSString *name;

/*!
 @brief The user.
 @textblock
 E.g with "John Doe <jdoe@domain.com>" as the full email address, user most of the times would be "jdoe".
 @/textblock
 */

@property (nullable, readonly, copy) NSString *user;

/*!
 @brief The domain of the address.
 @textblock
 E.g with "John Doe <jdoe@domain.com>" as the full email address, domain most of the times would be "example.com".
 @/textblock
 
 */

@property (nullable, readonly, copy) NSString *domain;

/*!
 @brief The host of the address.
 @textblock
 E.g with "John Doe <jdoe@domain.com>" as the full email address, host most of the times would be "smtp.example.com".
 @/textblock
 */

@property (nullable, readonly, copy) NSString *host;

@required

/*!
 @brief The email address. Cannot be nil.
 @textblock
 E.g jdoe@domain.com
 @/textblock
 */

@property (nullable, readonly, copy) NSString *address;

/*!
 @brief The full email address.
 @textblock
 E.g "John Doe <jdoe@domain.com>"
 @/textblock
 */

@property (nullable, readonly, copy) NSString *fullMessageAddress;

/*!
 @brief From the NSObject protocol, should return @link fullMessageAddress fullMessageAddress.
 */

@property (readonly, copy) NSString *description;

@end

@protocol SSMessageAddresseeValidator <NSObject>

+ (BOOL)isValidMessageAddressee:(id<SSMessageAddressee>)messageAddressee;

@end

@protocol SSMessageAddresseeValidation <SSMessageAddressee>

/*!
 @brief YES if address is a valid email address.
 */

@property (readonly, assign) BOOL isValidMessageAddressee;

@end

/*!
 @brief Represents an email address.
 @discussion <tt>address</tt> is required.
 */

@interface SSMessageAddressee : NSObject <SSMessageAddressee, SSMessageAddresseeValidation, SSMessageAddresseeValidator> {
@private
    NSString *_name;
    NSString *_address;
    NSString *_host;
    NSString *_user;
    NSString *_domain;
}

- (instancetype)init __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));

/*!
 @discussion address cannot be nil or an empty string.
 @param name
 The name used for display.
 @param address
 The email address.
 */

- (instancetype)initWithName:(nullable NSString *)name address:(NSString *)address __attribute__((objc_designated_initializer));

/*!
 @param messageAddressee
 An instance of an object conforming the SSMessageAddressee protocol
 */

- (instancetype)initWithMessageAddressee:(id <SSMessageAddressee>)messageAddressee;

@end

NS_ASSUME_NONNULL_END

