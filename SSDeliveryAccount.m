//
//  SSDeliveryAccount.m
//  SSMessage
//
//  Created by Dante Sabatier on 23/05/19.
//

#import "SSDeliveryAccount.h"
#import "SSMessageDefines.h"

@interface SSDeliveryAccount ()

@end

@implementation SSDeliveryAccount

- (instancetype)init {
    self = [super init];
    if (self) {
        self.usesDefaultPorts = YES;
        self.port = 587;
        self.usesSSL = YES;
        self.authenticationScheme = SSConnectionAuthenticationSchemePlain;
        self.securityLevel = SSConnectionSecurityLevelTLSv1;
    }
    return self;
}

- (instancetype)initWithDeliveryAccount:(id <SSDeliveryAccount>)deliveryAccount {
    self = [super init];
    if (self) {
        self.name = deliveryAccount.name;
        self.senders = deliveryAccount.senders;
        self.designatedSender = deliveryAccount.designatedSender;
        self.host = deliveryAccount.host;
        self.user = deliveryAccount.user;
        self.password = deliveryAccount.password;
        self.authenticationScheme = deliveryAccount.authenticationScheme;
        self.identifier = deliveryAccount.identifier;
        self.icon = deliveryAccount.icon;
        self.port = deliveryAccount.port;
        self.usesDefaultPorts = deliveryAccount.usesDefaultPorts;
        self.usesSSL = deliveryAccount.usesSSL;
        self.securityLevel = deliveryAccount.securityLevel;
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    SSDeliveryAccount *account = [[self.class allocWithZone:zone] init];
    account.name = self.name;
    account.senders = self.senders;
    account.designatedSender = self.designatedSender;
    account.host = self.host;
    account.user = self.user;
    account.password = self.password;
    account.authenticationScheme = self.authenticationScheme;
    account.identifier = self.identifier;
    account.icon = self.icon;
    account.port = self.port;
    account.usesDefaultPorts = self.usesDefaultPorts;
    account.usesSSL = self.usesSSL;
    account.securityLevel = self.securityLevel;
    return account;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.senders forKey:@"senders"];
    [coder encodeObject:self.designatedSender forKey:@"designatedSender"];
    [coder encodeObject:self.host forKey:@"host"];
    [coder encodeObject:self.user forKey:@"user"];
    [coder encodeObject:self.password forKey:@"password"];
    [coder encodeInteger:self.authenticationScheme forKey:@"authenticationScheme"];
    [coder encodeObject:self.identifier forKey:@"identifier"];
    [coder encodeObject:self.icon forKey:@"icon"];
    [coder encodeInteger:self.port forKey:@"port"];
    [coder encodeBool:self.usesDefaultPorts forKey:@"usesDefaultPorts"];
    [coder encodeBool:self.usesSSL forKey:@"usesSSL"];
    [coder encodeInteger:self.securityLevel forKey:@"securityLevel"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.name = [decoder decodeObjectForKey:@"name"];
        self.senders = [decoder decodeObjectForKey:@"senders"];
        self.designatedSender = [decoder decodeObjectForKey:@"designatedSender"];
        self.host = [decoder decodeObjectForKey:@"host"];
        self.user = [decoder decodeObjectForKey:@"user"];
        self.password = [decoder decodeObjectForKey:@"password"];
        self.authenticationScheme = [decoder decodeIntegerForKey:@"authenticationScheme"];
        self.identifier = [decoder decodeObjectForKey:@"identifier"];
        self.icon = [decoder decodeObjectForKey:@"icon"];
        self.port = [decoder decodeIntegerForKey:@"port"];
        self.usesDefaultPorts = [decoder decodeBoolForKey:@"usesDefaultPorts"];
        self.usesSSL = [decoder decodeBoolForKey:@"usesSSL"];
        self.securityLevel = [decoder decodeIntegerForKey:@"authenticationScheme"];
    }
    return self;
}

- (void)dealloc {
    [_identifier release];
    [_name release];
    [_host release];
    [_user release];
    [_password release];
    [_senders release];
    [_designatedSender release];
    [super ss_dealloc];
}

- (NSString *)identifier {
    return SSAtomicAutoreleasedGet(_identifier);
}

- (void)setIdentifier:(NSString *)identifier {
    SSAtomicCopiedSet(_identifier, identifier);
}

- (NSString *)name {
    return SSAtomicAutoreleasedGet(_name);
}

- (void)setName:(NSString *)name {
    SSAtomicCopiedSet(_name, name);
}

- (NSArray<id<SSMessageAddressee>> *)senders {
    return SSAtomicAutoreleasedGet(_senders);
}

- (void)setSenders:(NSArray<id<SSMessageAddressee>> *)senders {
    SSAtomicCopiedSet(_senders, senders);
}

- (id<SSMessageAddressee> _Nullable)designatedSender {
    return SSAtomicAutoreleasedGet(_designatedSender);
}

- (void)setDesignatedSender:(id<SSMessageAddressee> _Nullable)designatedSender {
    SSAtomicCopiedSet(_designatedSender, designatedSender);
}

- (NSString *)host {
    return SSAtomicAutoreleasedGet(_host);
}

- (void)sethost:(NSString *)host {
    SSAtomicCopiedSet(_host, host);
}

- (NSString *)user {
    return SSAtomicAutoreleasedGet(_user);
}

- (void)setuser:(NSString *)user {
    SSAtomicCopiedSet(_user, user);
}

- (NSString *)password {
    return SSAtomicAutoreleasedGet(_password);
}

- (void)setPassword:(NSString *)password {
    SSAtomicCopiedSet(_password, password);
}

- (SSConnectionAuthenticationScheme)authenticationScheme {
    return _authenticationScheme;
}

- (void)setAuthenticationScheme:(SSConnectionAuthenticationScheme)authenticationScheme {
    _authenticationScheme = authenticationScheme;
}

- (NSInteger)port {
    return _port;
}

- (void)setport:(NSInteger)port {
    _port = port;
}

- (BOOL)usesDefaultPorts {
    return _usesDefaultPorts;
}

- (void)setUsesDefaultPorts:(BOOL)usesDefaultPorts {
    _usesDefaultPorts = usesDefaultPorts;
}

- (BOOL)usesSSL {
    return _usesSSL;
}

- (void)setUsesSSL:(BOOL)usesSSL {
    _usesSSL = usesSSL;
}

- (SSConnectionSecurityLevel)securityLevel {
    return _securityLevel;
}

- (void)setSecurityLevel:(SSConnectionSecurityLevel)securityLevel {
    _securityLevel = securityLevel;
}

- (id)icon {
    return _icon;
}

- (void)setIcon:(id)icon {
    SSAtomicCopiedSet(_icon, icon);
}

@end
