//
//  NSDictionary+SSAdditions.m
//  SSMessage
//
//  Created by Dante Sabatier on 26/08/09.
//  Copyright 2009 Dante Sabatier. All rights reserved.
//

#import "NSDictionary+SSAdditions.h"
#import "SSSMTPConnection.h"
#import "SSMessageDelivery.h"
#import "NSData+SSAdditions.h"
#import "NSArray+SSAdditions.h"
#import "NSString+SSAdditions.h"
#import "SSMessageUtilities.h"
#if !TARGET_OS_IPHONE
#import <AppKit/NSImage.h>
#endif

@implementation NSDictionary(SSMessageAdditions)

- (id)objectForCaseInsensitiveKey:(NSString *)aKey {
    if (self[aKey]) {
        return self[aKey];
    }
    
	for (NSString *key in self.allKeys) {
        if ([key caseInsensitiveCompare:aKey] == NSOrderedSame) {
             return self[key];
        }
	}
	
	return nil;
}

@end

@implementation NSDictionary(SSMessageHeaderAdditions)

- (NSArray <id <SSMessageAddressee>>*)messageAddresseesForKey:(SSMessageHeaderKey)key passingTest:(BOOL(^ __nullable)(id <SSMessageAddressee>messageAddressee))predicate {
    NSMutableArray <id <SSMessageAddressee>>*messageAddressees = [NSMutableArray array];
    id obj = [self objectForCaseInsensitiveKey:key];
    if ([obj isKindOfClass:[NSArray class]]) {
        [messageAddressees setArray:[(NSArray *)obj filteredArrayOfMessageAddressesPassingTest:predicate]];
    } else if ([obj isKindOfClass:[NSString class]]) {
        NSString *string = (NSString *)obj;
        if ((string != nil) && string.length) {
            if (([string rangeOfString:@";"].location != NSNotFound) || ([string rangeOfString:@","].location != NSNotFound)) {
                [messageAddressees setArray:[[[string stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";,"]] filteredArrayOfMessageAddressesPassingTest:predicate]];
            } else {
                NSString *address = string.address;
                if (address) {
                    if (predicate) {
                        if (predicate(address)) {
                            [messageAddressees addObject:address];
                        }
                    } else {
                        [messageAddressees addObject:address];
                    }
                }
            }
        }
    }
    return messageAddressees;
}

- (NSArray <id <SSMessageAddressee>>*)messageAddresseesForKey:(SSMessageHeaderKey)key {
	return [self messageAddresseesForKey:key passingTest:nil];
}

@end

@implementation NSDictionary (SSDeliveryAccountAdditions)

- (nullable NSString *)name {
    NSString *name = self[SSDeliveryAccountKeyName];
    if (name) {
        return name;
    }
	return [self.messageAddressees componentsJoinedByString:@", "];
}

- (nullable NSArray <id <SSMessageAddressee>>*)senders {
	return self[SSDeliveryAccountKeySenders];
}

- (nullable id <SSMessageAddressee>)designatedSender {
    if (self[SSDeliveryAccountKeyDesignatedSender]) {
        return self[SSDeliveryAccountKeyDesignatedSender];
    }
    
    id <SSMessageAddressee>sender = self.senders.firstObject;
    if (!sender) {
        return nil;
    }
    
    if ([sender isKindOfClass:[SSMessageAddressee class]]) {
        return sender;
    }
    
    return [[[SSMessageAddressee alloc] initWithMessageAddressee:sender] autorelease];
}


- (nullable NSString *)fullUserName {
	return self[SSDeliveryAccountKeyFullUserName];
}

- (nullable NSString *)host {
	return self[SSDeliveryAccountKeyHostName];
}

- (nullable NSString *)user {
    return self[SSDeliveryAccounKeytUserName] ? self[SSDeliveryAccounKeytUserName] : self.designatedSender.user;
}

- (nullable NSString *)password {
	return self[SSDeliveryAccountKeyPassword];
}

- (SSConnectionAuthenticationScheme)authenticationScheme {
    return self[SSDeliveryAccountKeyAuthenticationScheme] ? ((NSNumber *)self[SSDeliveryAccountKeyAuthenticationScheme]).integerValue : SSConnectionAuthenticationSchemePlain;
}

- (NSString *)identifier {
	return [NSString stringWithFormat:@"%@:%@", self.host, self.user];
}

- (NSInteger)port {
    return self[SSDeliveryAccountKeyPortNumber] ? ((NSNumber *)self[SSDeliveryAccountKeyPortNumber]).integerValue : 587;
}

- (BOOL)usesDefaultPorts {
    return self[SSDeliveryAccountKeyUsesDefaultPorts] ? ((NSNumber *)self[SSDeliveryAccountKeyUsesDefaultPorts]).boolValue : YES;
}

- (BOOL)usesSSL {
    return self[SSDeliveryAccountKeySSLEnabled] ? ((NSNumber *)self[SSDeliveryAccountKeySSLEnabled]).boolValue : YES;
}

- (SSConnectionSecurityLevel)securityLevel {
    return self[SSDeliveryAccountKeySecurityLevel] ? ((NSNumber *)self[SSDeliveryAccountKeySecurityLevel]).integerValue : (self.usesSSL ? SSConnectionSecurityLevelTLSv1 : SSConnectionSecurityLevelNone);
}

- (id)icon {
    return nil;
}

@end
