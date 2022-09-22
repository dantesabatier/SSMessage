/*
 NSDictionary+SSAdditions.h
 SSMessage
 
 Created by Dante Sabatier on 26/08/09.
 Copyright 2009 Dante Sabatier. All rights reserved.
 */

#import "SSDeliveryAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary<KeyType, ObjectType>(SSMessageAdditions)

/*!
 @discussion same as objectForKey: but case insensitive.
 @param aKey
 the key for the object.
 @return the value for key aKey
 */

- (nullable ObjectType)objectForCaseInsensitiveKey:(KeyType)aKey;

@end

@interface NSDictionary(SSMessageHeaderAdditions)

#if NS_BLOCKS_AVAILABLE
/*!
 @param key
 the name of the message header.
 @param predicate
 message addressee validation.
 @return an array of <i>SSMessageAddressee</i> for <i>SSMessageHeaderKey</i> passing the test
 */

- (NSArray <id <SSMessageAddressee>>*)messageAddresseesForKey:(SSMessageHeaderKey)key passingTest:(BOOL(^ __nullable)(id <SSMessageAddressee>messageAddressee))predicate NS_SWIFT_NAME(messageAddressees(for:where:)) NS_AVAILABLE(10_6, 4_0);
#endif

/*!
 @discussion same as above but passing nil as predicate.
 @param key
 the name of the message header.
 @return an array of <i>SSMessageAddressee</i> for <i>SSMessageHeaderKey</i>
 */

- (NSArray <id <SSMessageAddressee>>*)messageAddresseesForKey:(SSMessageHeaderKey)key NS_AVAILABLE(10_6, 4_0);

@end

@interface NSDictionary<KeyType, ObjectType>(SSDeliveryAccountAdditions) <SSDeliveryAccount>

/*!
 @brief Returns the value for SSDeliveryAccountKeyName.
 */

@property (nullable, readonly, copy) NSString *name;

/*!
 @brief the value for SSDeliveryAccountKeySenders.
 */

@property (nullable, readonly, copy) NSArray <id <SSMessageAddressee>>*senders;

/*!
 @brief the value for SSDeliveryAccountKeyDesignatedSender or the first message addressee of <tt>messageAddressees</tt> if any.
 */

@property (nullable, readonly, copy) id <SSMessageAddressee>designatedSender;

/*!
 @brief the value for SSDeliveryAccountKeyHostName.
 */

@property (nullable, readonly, copy) NSString *host;

/*!
 @brief the value for SSDeliveryAccounKeytUserName.
 */

@property (nullable, readonly, copy) NSString *user;

/*!
 @brief the value for SSDeliveryAccountKeyFullUserName.
 */

@property (nullable, readonly, copy) NSString *fullUserName;

/*!
 @brief the value for SSDeliveryAccountKeyPassword.
 */

@property (nullable, readonly, copy) NSString *password;

/*!
 @brief the value for SSDeliveryAccountKeyAuthenticationScheme.
 @discussion If not specified, this methods returns SSConnectionAuthenticationSchemePlain.
 */

@property (readonly) SSConnectionAuthenticationScheme authenticationScheme;

/*!
 @brief the identifier of the account.
 @discussion E.g. smtp.domain.com:janedoe.
 */

@property (nullable, readonly, copy) NSString *identifier;

/*!
 @brief the value for the key SSDeliveryAccountKeyPortNumber.
 @discussion If not specified, this methods returns port 587.
 */

@property (readonly) NSInteger port;

/*!
 @brief the value for the key SSDeliveryAccountKeyUsesDefaultPorts.
 @discussion If not specified, this methods returns YES.
 */

@property (readonly) BOOL usesDefaultPorts;

/*!
 @brief the value for the key SSDeliveryAccountKeySSLEnabled.
 @discussion If not specified, this methods returns YES.
 */

@property (readonly) BOOL usesSSL;

/*!
 @brief  Returns the value for the key SSDeliveryAccountKeySecurityLevel.
 @discussion If not specified and <tt>usesSSL</tt>, this methods returns <tt>SSConnectionSecurityLevelTLSv1</tt>.
 */

@property (readonly) SSConnectionSecurityLevel securityLevel;

/*!
 @brief the icon of the account.
 */

#if TARGET_OS_IPHONE
@property (nullable, readonly, copy) UIImage *icon;
#else
@property (nullable, readonly, copy) NSImage *icon;
#endif

@end

NS_ASSUME_NONNULL_END
