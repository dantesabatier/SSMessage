/*
 NSArray+SSAdditions.h
 SSMessage
 
 Created by Dante Sabatier on 30/08/09.
 Copyright 2009 Dante Sabatier. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "SSMessageAddressee.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<ObjectType>(SSMessageAdditions)

#if (!TARGET_OS_IPHONE && !defined(__MAC_10_7)) || (TARGET_OS_IPHONE && !defined(__IPHONE_4_0))
@property (nullable, nonatomic, readonly) ObjectType firstObject;
#endif
#if NS_BLOCKS_AVAILABLE
- (nullable ObjectType)firstObjectPassingTest:(BOOL (NS_NOESCAPE ^)(ObjectType obj))predicate NS_SWIFT_NAME(firstObject(where:)) NS_AVAILABLE(10_6, 4_0);
- (NSArray<ObjectType> *)objectsPassingTest:(BOOL (NS_NOESCAPE ^)(ObjectType obj, NSInteger idx, BOOL *stop))predicate NS_SWIFT_NAME(objects(where:)) NS_AVAILABLE(10_6, 4_0);
- (NSArray *)mapObjectsUsingBlock:(id __nullable (NS_NOESCAPE^)(ObjectType obj))block NS_SWIFT_NAME(map(transform:)) NS_AVAILABLE(10_6, 4_0);
- (NSArray <id <SSMessageAddressee>>*)filteredArrayOfMessageAddressesPassingTest:(BOOL(NS_NOESCAPE^__nullable)(id <SSMessageAddressee>messageAddressee))predicate NS_SWIFT_NAME(messageAddresses(where:)) NS_AVAILABLE(10_6, 4_0);
#endif

/*!
 @brief returns a CRLF separated list of recipients using the format @textblock \@"RCPT TO:<email>. E.g \@"RCPT TO:<janedoe@example.com>\r\nRCPT TO:<jdoe@example.com>\r\n.@/textblock.
 */

@property (readonly, copy) NSString *componentsJoinedAsRecipients;

@end

NS_ASSUME_NONNULL_END
