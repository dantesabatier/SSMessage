//
//  NSArray+SSAdditions.m
//  SSMessage
//
//  Created by Dante Sabatier on 30/08/09.
//  Copyright 2009 Dante Sabatier. All rights reserved.
//

#import "NSArray+SSAdditions.h"
#import "NSString+SSAdditions.h"
#import "SSMessageUtilities.h"

@implementation NSArray(SSMessageAdditions)

#if ((!TARGET_OS_IPHONE && defined(__MAC_OS_X_VERSION_MIN_REQUIRED)) && (__MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_7)) || (TARGET_OS_IPHONE && defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0))

- (id)firstObject {
    return self.count ? self[0] : nil;
}

#endif

#if NS_BLOCKS_AVAILABLE
- (id)firstObjectPassingTest:(BOOL (NS_NOESCAPE ^)(id obj))predicate {
    for (id obj in self) {
        if (predicate(obj)) {
            return obj;
        }
    }
    return nil;
}

- (instancetype)objectsPassingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSInteger idx, BOOL *stop))predicate {
    NSMutableArray *array = [NSMutableArray array];
    NSUInteger idx = 0;
    for (id obj in self) {
        BOOL stop = NO;
        if (predicate(obj, idx, &stop)) {
            [array addObject:obj];
        }
        if (stop) {
            break;
        }
        idx++;
    }
    return array;
}

- (NSArray *)mapObjectsUsingBlock:(id __nullable (NS_NOESCAPE^)(id obj))block {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in self) {
        id object = block(obj);
        if (object) {
            [array addObject:object];
        }
    }
    return array;
}

- (NSArray <id <SSMessageAddressee>>*)filteredArrayOfMessageAddressesPassingTest:(BOOL(NS_NOESCAPE^__nullable)(id <SSMessageAddressee>messageAddressee))predicate {
    return [self objectsPassingTest:^BOOL(id obj, NSInteger idx, BOOL *stop){
    if ([obj conformsToProtocol:@protocol(SSMessageAddressee)]) {
            id <SSMessageAddressee> messageAddressee = obj;
            if (predicate) {
                return predicate(messageAddressee);
            }
            if ([messageAddressee conformsToProtocol:@protocol(SSMessageAddresseeValidation)]) {
                return ((id <SSMessageAddresseeValidation>)messageAddressee).isValidMessageAddressee;
            }
            return [SSMessageAddressee isValidMessageAddressee:messageAddressee];
        }
        return NO;
    }];
}
#endif

- (NSString *)componentsJoinedAsRecipients {
	NSMutableString	*recipients = [NSMutableString string];
	for (id obj in self) {
	    if ([obj conformsToProtocol:@protocol(SSMessageAddressee)]) {
	        id <SSMessageAddressee> messageAddressee = obj;
	        if (([messageAddressee conformsToProtocol:@protocol(SSMessageAddresseeValidation)] && ((id <SSMessageAddresseeValidation>)messageAddressee).isValidMessageAddressee) || [SSMessageAddressee isValidMessageAddressee:messageAddressee]) {
	            [recipients appendFormat:@"RCPT TO:<%@>\r\n", messageAddressee.address];
	        }
	    }
	}
	return recipients;
}

@end
