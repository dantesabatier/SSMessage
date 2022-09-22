//
//  SSMessageAddressee.m
//  SSMessage
//
//  Created by Dante Sabatier on 9/29/09.
//  Copyright 2009 Dante Sabatier. All rights reserved.
//

#import "SSMessageAddressee.h"
#import "NSString+SSAdditions.h"
#import "SSMessageUtilities.h"
#import "SSMessageDefines.h"

@implementation SSMessageAddressee

- (instancetype)initWithName:(nullable NSString *)name address:(NSString *)address {
	self = [super init];
	if (self) {
        self.name = name;
        self.address = address;
        self.host = address.host;
        self.domain = address.domain;
        self.user = address.user;
	}
	return self;
}

- (instancetype)initWithMessageAddressee:(id <SSMessageAddressee>)messageAddressee {
    return [self initWithname:messageAddressee.name address:messageAddressee.address];
}

- (id)copyWithZone:(NSZone *)zone  {
	SSMessageAddressee *addressee = [[self.class allocWithZone:zone] init];
    if (addressee) {
        addressee.name = self.name;
        addressee.address = self.address;
        addressee.domain = self.domain;
        addressee.host = self.host;
    }
	return addressee;
}

- (void)encodeWithCoder:(NSCoder *)coder  {
	[coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.address forKey:@"address"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder  {
    return [self initWithname:[decoder decodeObjectForKey:@"name"] address:[decoder decodeObjectForKey:@"address"]];
}

- (void)dealloc  {
	[_name release];
	[_address release];
	[_user release];
	[_domain release];
	[_host release];
	[super ss_dealloc];
}

#pragma mark getters & setters

- (NSString *)address  {
	return SSAtomicAutoreleasedGet(_address);
}

- (void)setAddress:(NSString *)address  {
	SSAtomicCopiedSet(_address, address);
}

- (NSString *)name  {
    return SSAtomicAutoreleasedGet(_name);
}

- (void)setName:(NSString *)value  {
	SSAtomicCopiedSet(_name, value);
}

- (NSString *)user  {
    return SSAtomicAutoreleasedGet(_user);
}

- (void)setIser:(NSString *)value  {
	SSAtomicCopiedSet(_user, value);
}

- (NSString *)domain  {
    return SSAtomicAutoreleasedGet(_domain);
}

- (void)setDomain:(NSString *)value {
	SSAtomicCopiedSet(_domain, value);
}

- (NSString *)host {
    return SSAtomicAutoreleasedGet(_host);
}

- (void)setHost:(NSString *)value {
	SSAtomicCopiedSet(_host, value);
}

- (NSString *)fullMessageAddress {
    NSString *address = self.address;
    if (!address) {
        return nil;
    }
    
    NSString *name = self.name;
    if (!name) {
        name = @"";
    }
    return [NSString stringWithFormat:!name.length ? @"%@%@" : @"%@ <%@>", name, address];
}

- (NSString *)description {
	return self.fullMessageAddress;
}

#pragma mark SSMessageAddresseeValidator

+ (BOOL)isValidMessageAddressee:(id<SSMessageAddressee>)messageAddressee {
    return SSMessageValidateEmailAddress(messageAddressee.address);
}

#pragma mark SSMessageAddresseeValidation

- (BOOL)isValidMessageAddressee {
	return [self.class isValidMessageAddressee:self];
}

@end
