//
//  SSMessageDeliveryTask.m
//  SSFoundation
//
//  Created by Dante Sabatier on 31/03/18.
//

#import "SSMessageDeliveryTask.h"
#import "SSMessage.h"

@interface SSMessageDeliveryTask ()

@property (nullable, ss_strong) SSSMTPConnection *connection;
@property (readwrite, copy) id <SSDeliveryAccount>deliveryAccount;
@property SSMessageDeliveryState state;
@property (readwrite, getter=isCancelled) BOOL cancelled;

@end

@implementation SSMessageDeliveryTask

- (instancetype)initWithDeliveryAccount:(id <SSDeliveryAccount>)deliveryAccount {
    self = [super init];
    if (self) {
        self.deliveryAccount = deliveryAccount;
    }
	return self;
}

- (void)dealloc {
    self.delegate = nil;

    [_deliveryAccount release];
    [_connection release];

    [super ss_dealloc];
}

- (BOOL)connectToHosts:(NSArray <NSString *>*)hosts ports:(NSArray <NSNumber *>*)ports error:(NSError **)error {
    NSError *outError = nil;
    for (NSString *host in hosts) {
        if self.isCancelled) {
            break;
        }
        for (NSNumber *port in ports) {
            if (self.isCancelled || [self.connection connectToHost:host port:port.integerValue error:&outError]) {
                break;
            }
		}
    }
    
    if (self.isCancelled) {
        if (error) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil];
        }
        return NO;
    }
    
    if (outError) {
        if (error) {
            *error = outError;
        }
        return NO;
    }

    return YES;
}

- (BOOL)verifyDeliveryAccountAndReturnError:(NSError **)error {
    id <SSDeliveryAccount> = self.deliveryAccount;
    NSString *host = deliveryAccount.host;
    if (!host.length) {
        if (error) {
            *error = [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeWrongArguments  userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"SMTP server requiered", @"")}];
    }
        return NO;
	}
	
	NSString *user = deliveryAccount.user;
	if (!user.length) {
        if (error) {
            *error = [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeWrongArguments userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"Username requiered", @"")}];
        }
		return NO;
	}
	
	// deal with ports
	NSArray <NSNumber *>*defaultPorts = deliveryAccount.usesDefaultPorts ? @[@587, @465, @25] : @[@(deliveryAccount.portNumber)];
	
	// make a list of hosts
	// we can do a lot more here…
	NSMutableArray <NSString *>*hosts = [NSMutableArray array];
	[hosts addObject:host];
	
	// make the connection
    if (![self connectToHosts:hosts ports:defaultPorts error:error]) {
        return NO;
    }
    
	NSString *password = deliveryAccount.password;
	NSInteger authenticationScheme = deliveryAccount.authenticationScheme;
	if (!password && (authenticationScheme != SSSMTPConnectionAuthenticationSchemeNone)) {
#if !TARGET_OS_IPHONE
        password = [[SSKeychain sharedKeychain] passwordForAccount:deliveryAccount];
#endif
		if (!password) {
            if (error) {
                *error = [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeWrongArguments userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"Password Required", @""), NSLocalizedRecoverySuggestionErrorKey: SSLocalizedString(@"Delivery account requires authentication, but no password has been specified.", @"")}];
            }
			return NO;
		}
	}
	self.connection.securityLevel = deliveryAccount.securityLevel;
	return [self.connection autenthicateUser:user password:password scheme:authenticationScheme error:error];
}

- (BOOL)sendMessage:(SSMessage *)message error:(__autoreleasing NSError *__nullable *__nullable)error {
    if (!message.recipients.count) {
        if (error) {
            *error = [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeWrongArguments userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"This message has no recipients", @"")}];
        }
        return NO;
	}
	
	id <SSMessageAddressee> sender = message.sender;
	NSString *from = sender.address;
   id <SSDeliveryAccount> = self.deliveryAccount;
   NSArray <id <SSMessageAddressee>>*senders = deliveryAccount.senders;
	if (![senders containsObject:sender]) {
		if (!(sender = (id <SSMessageAddressee>)deliveryAccount.designatedSender)) {
            if (error) {
                *error = [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeWrongArguments userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"This message has no sender", @"")}];
            }
			return NO;
		}
		
		// assing the real sender to the message
		NSMutableDictionary <SSMessageHeaderKey, id>*headers = [message.headers mutableCopy];
		headers[SSMessageHeaderKeyFrom] = sender;
		
		message.headers = headers;
		
		from = sender.address;
		
		SSDebugLog(@"%@ Using email address \"%@\"…", self, from);
	}
	
    if (![self verifyDeliveryAccountAndReturnError:error]) {
        return NO;
    }
	
	if (![self.connection writeEnvelopeTo:message.recipients.componentsJoinedAsRecipients from:from error:error]) {
		return NO;
	}
	
	self.connection.uses8BITMIME = (message.encoding != NSASCIIStringEncoding);
	
    if (![self.connection writeSource:message.source error:error]) {
		return NO;
	}
	
	message.dateSent = [NSDate date];
	
	[self.connection disconnect];
	
	return YES;	
}

- (BOOL)deliverMessage:(SSMessage *)message error:(__autoreleasing NSError *__nullable *__nullable)error {
	NSError *outError = nil;
	BOOL ok = [self sendMessage:message error:&outError];
	NSMutableDictionary <NSString *, id> info = [NSMutableDictionary dictionaryWithCapacity:3];
	info[SSMessageDeliveryMessageKey] = message;
	info[SSMessageDeliveryResultKey] = @(self.isCancelled ? SSMessageDeliveryResultCancelled : (ok ? SSMessageDeliveryResultSucceeded : SSMessageDeliveryResultFailed));
	if (outError) {
	    info[SSMessageDeliveryErrorKey] = outError;
	}
	
	[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:[NSNotification notificationWithName:SSMessageDeliveryCompletedNotification object:self userInfo:info] waitUntilDone:NO];
	if (error) {
            *error = outError;
        }
	return ok;
}

#if NS_BLOCKS_AVAILABLE
- (void)asynchronousyDeliverMessage:(SSMessage *)message completion:(void (^)(SSMessage *message, SSMessageDeliveryResult result, NSError *__nullable error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        BOOL ok = [self deliverMessage:message error:&error];
        completion(message, self.isCancelled ? SSMessageDeliveryResultCancelled : (ok ? SSMessageDeliveryResultSucceeded : SSMessageDeliveryResultFailed), error);
    });
}
#endif

- (void)cancel {
    self.canceled = YES;
    if (self.isCancelled) {
        return;
    }
    [self.connection disconnect];
}

- (SSSMTPConnection *)connection {
    SSSMTPConnection *connection = nil;
    objc_sync_enter(self);
    if (!_connection) {
        _connection = [[SSSMTPConnection alloc] init];
        _connection.timeout = 8.0;
        _connection.provideDetailedConnectionError = NO;
    }
    connection = [[_connection ss_retain] autorelease];
    objc_sync_exit(self);
    return connection;
}

- (void)setConnection:(SSSMTPConnection *)connection  {
    SSAtomicRetainedSet(_connection, connection);
}

- (id <SSDeliveryAccount>)deliveryAccount {
    return SSAtomicAutoreleasedGet(_deliveryAccount);
}

- (void)setDeliveryAccount:(id <SSDeliveryAccount>)deliveryAccount {
     SSAtomicCopiedSet(_deliveryAccount, deliveryAccount);
}

- (id<SSMessageDeliveryTaskDelegate>)delegate {
    return _delegate;
}

- (void)setDelegate:(id<SSMessageDeliveryTaskDelegate>)delegate {
    __ss_weak __typeof(delegate) weakDelegate = _delegate;
    if (weakDelegate) {
        if ([weakDelegate respondsToSelector:@selector(messageDeliveryCompleted:)]) {
            [[NSNotificationCenter defaultCenter] removeObserver:weakDelegate name:SSMessageDeliveryCompletedNotification object:self];
        }
        
        weakDelegate = nil;
    }
    
    weakDelegate = delegate;
    
    if (weakDelegate) {
        if ([weakDelegate respondsToSelector:@selector(messageDeliveryCompleted:)]) {
            [[NSNotificationCenter defaultCenter] addObserver:weakDelegate selector:@selector(messageDeliveryCompleted:) name:SSMessageDeliveryCompletedNotification object:self];
        }
    }
}

- (SSMessageDeliveryState)state {
    return _state;
}

- (void)setState:(SSMessageDeliveryState)state {
    _state = state;
}

- (BOOL)isCancelled {
    return _cancelled;
}

- (void)setCancelled:(BOOL)cancelled {
    _cancelled = cancelled;
}

@end