//
//  SSSMTPConnection.m
//  SSMessage
//
//  Created by Dante Sabatier on 9/24/09.
//  Copyright 2009 Dante Sabatier. All rights reserved.
//

#import "SSSMTPConnection.h"
#import "NSData+SSAdditions.h"
#import "NSString+SSAdditions.h"
#import "SSMessageUtilities.h"
#import "SSMessageDefines.h"
#import <stdio.h>
#import <stdlib.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <net/if.h>
#import <arpa/inet.h>
#import <netdb.h>
#import <unistd.h>
#import <errno.h>
#import <ifaddrs.h>

#define BUFFER_SIZE 1024

@interface SSSMTPConnection () 

@property (readwrite, copy) NSString *host;
@property (readwrite) NSInteger port;

@end

@implementation SSSMTPConnection

#pragma mark life cycle

- (instancetype)init {
	self = [super init];
	if (self) {
		_sslContext = NULL;
		_supports8BITMIME = NO;
		_supportsLoginAuth = NO;
		_supportsPlainAuth = NO;
		_supportsSTARTTLS = NO;
		_uses8BITMIME = YES;
		_provideDetailedConnectionError = YES;
		_securityLevel = SSSMTPConnectionSecurityLevelTLSv1;
		_ssocket = -1;
		_timeout = 60.0;
	}
	return self;
}

- (nullable instancetype)initWithHost:(NSString *)host port:(NSInteger)port error:(NSError *__nullable * __nullable)error {
    self = [self init];
    if (self) {
        if (![self connectToHost:host port:port error:error]) {
            [self release];
            self = nil;
        }
    }
    return self;
}

- (void)dealloc  {
	[self disconnect];
	[super ss_dealloc];
}

- (NSInteger)read:(char *)buf length:(NSInteger)len {
	if (_sslContext) {
		size_t read;
		OSStatus status = SSLRead(_sslContext, buf, len, &read);
		switch (status) {
			case noErr:
				return read;
				break;
			case errSSLClosedGraceful:
            case errSSLClosedAbort:
				return 0L;
				break;
			default:
				return -1L;
				break;
		}
	}
	return read(_ssocket, buf, (size_t)len);
}

- (NSInteger)write:(char *)buf length:(NSInteger)len {
	if (_sslContext) {
		size_t written;
		OSStatus status = SSLWrite(_sslContext, buf, len, &written);
		switch (status) {
			case noErr:
				return written;
				break;
			case errSSLClosedGraceful:
            case errSSLClosedAbort:
				return 0L;
				break;
			default:
				return -1L;
				break;
		}
	}
	return write(_ssocket, buf, (size_t)len);
}

- (NSString *)hostReplyForCommand:(NSString *)command  {
    if (!self.isConnected) {
        return [NSString string];
    }
    
	NSStringEncoding encoding = NSUTF8StringEncoding;
    if (command && command.length) {
        [self write:(char *) [command cStringUsingEncoding:encoding] length:(NSInteger) [command lengthOfBytesUsingEncoding:encoding]];
    }
    
	char buffer[BUFFER_SIZE];
	NSInteger response = [self read:buffer length:BUFFER_SIZE];	
	buffer[response] = 0;
	
	return [[[NSString alloc] initWithCString:buffer encoding:encoding] autorelease];
}

- (BOOL)connectToHost:(NSString *)host port:(NSInteger)port error:(NSError *__nullable * __nullable)error {
	[self disconnect];
	
	SSDebugLog(@"%@ Attempting to connect to server \"%@:%@\"", self, host, @(port));
	
	struct hostent *hostbyname = gethostbyname(host.UTF8String);
	if (!hostbyname) {
        if (error) {
            *error = _provideDetailedConnectionError ? [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeConnectionFailed userInfo:@{NSLocalizedDescriptionKey: @"Could not connect to server", NSLocalizedRecoverySuggestionErrorKey: @"Error resolving the host."}] : [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeConnectionFailed userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"Could not connect to server", @""), NSLocalizedRecoverySuggestionErrorKey: SSLocalizedString(@"Error while connecting to the server. Verify your internet connection and/or if you are behind a firewall check your firewall configuration.", @"")}];
        }
		return NO;
	}
	
	unsigned long remote_h_addr = *(unsigned long *)hostbyname->h_addr_list[0];
	struct sockaddr_in remoteaddr;
	bzero((char *)&remoteaddr, sizeof(remoteaddr));
	remoteaddr.sin_family = AF_INET;
	remoteaddr.sin_addr.s_addr = (unsigned)remote_h_addr;
	remoteaddr.sin_port = htons(port);
	
	_ssocket = socket(AF_INET, SOCK_STREAM, 0);
	if (_ssocket == -1) {
        if (error) {
            *error = _provideDetailedConnectionError ? [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeConnectionFailed userInfo:@{NSLocalizedDescriptionKey: @"Could not connect to server", NSLocalizedRecoverySuggestionErrorKey: @"Could not allocate socket."}] : [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeConnectionFailed userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"Could not connect to server", @""), NSLocalizedRecoverySuggestionErrorKey: SSLocalizedString(@"Error while connecting to the server. Verify your internet connection and/or if you are behind a firewall check your firewall configuration.", @"")}];
        }
		return NO;
	}
	
	int loop = 1;
	if (setsockopt(_ssocket, SOL_SOCKET, SO_KEEPALIVE, &loop, sizeof(loop)) < 0) {
        if (error) {
            *error = _provideDetailedConnectionError ? [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeConnectionFailed userInfo:@{NSLocalizedDescriptionKey: @"Could not connect to server", NSLocalizedRecoverySuggestionErrorKey: @"Could not set SO_KEEPALIVE."}] : [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeConnectionFailed userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"Could not connect to server", @""), NSLocalizedRecoverySuggestionErrorKey: SSLocalizedString(@"Error while connecting to the server. Verify your internet connection and/or if you are behind a firewall check your firewall configuration.", @"")}];
        }
		return NO;
	}
	
	// Set NONBLOCK to realize a timeout
	
	int oldFlags = fcntl(_ssocket, F_GETFL, 0);
	if (fcntl(_ssocket, F_SETFL, oldFlags | O_NONBLOCK) < 0) {
        if (error) {
            *error = _provideDetailedConnectionError ? [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeConnectionFailed userInfo:@{NSLocalizedDescriptionKey: @"Could not connect to server", NSLocalizedRecoverySuggestionErrorKey: @"Could not set O_NONBLOCK for socket."}] : [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeConnectionFailed userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"Could not connect to server", @""), NSLocalizedRecoverySuggestionErrorKey: SSLocalizedString(@"Error while connecting to the server. Verify your internet connection and/or if you are behind a firewall check your firewall configuration.", @"")}];
        }
		return NO;
	}
	
	int connected = connect(_ssocket, (struct sockaddr *)&remoteaddr, sizeof(remoteaddr));
	if ((connected < 0) && (errno != EINPROGRESS)) {
		*error = [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeConnectionFailed userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"Could not connect to server", @""), NSLocalizedRecoverySuggestionErrorKey: SSLocalizedString(@"Error while connecting to the server. Verify your internet connection and/or if you are behind a firewall check your firewall configuration.", @"")}];
		return NO;
	}
	
	if (fcntl(_ssocket, F_SETFL, oldFlags) < 0) {
        if (error) {
            *error = _provideDetailedConnectionError ? [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeConnectionFailed userInfo:@{NSLocalizedDescriptionKey: @"Could not connect to server", NSLocalizedRecoverySuggestionErrorKey: @"Could not restore old flags for socket."}] : [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeConnectionFailed userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"Could not connect to server", @""), NSLocalizedRecoverySuggestionErrorKey: SSLocalizedString(@"Error while connecting to the server. Verify your internet connection and/or if you are behind a firewall check your firewall configuration.", @"")}];
        }
		return NO;
	}
	
	// Test if connected but with timeout
	
	fd_set fds;
	struct timeval timeout;
	timeout.tv_usec = 0;
	timeout.tv_sec = (__darwin_time_t)_timeout;
	
	FD_ZERO(&fds);
	FD_SET(_ssocket, &fds);
	
	connected = select(_ssocket + 1, &fds, &fds, NULL, &timeout);
	if (connected < 0) {
        if (error) {
            *error = _provideDetailedConnectionError ? [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeConnectionFailed userInfo:@{NSLocalizedDescriptionKey: @"Could not connect to server", NSLocalizedRecoverySuggestionErrorKey: @"Error in select()."}] : [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeConnectionFailed userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"Could not connect to server", @""), NSLocalizedRecoverySuggestionErrorKey: SSLocalizedString(@"Error while connecting to the server. Verify your internet connection and/or if you are behind a firewall check your firewall configuration.", @"")}];
        }
		return NO;
	} else if (!connected) {
        if (error) {
            *error = [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeConnectionTimeout userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"Could not connect to server", @""), NSLocalizedRecoverySuggestionErrorKey: SSLocalizedString(@"Timeout while connecting.", @"")}];
        }
		return NO;
	}
	
	SSDebugLog(@"%@:Connected to server \"%@:%@\"", self, host, @(port));
	
	self.host = host;
	self.port = port;
	
	return YES;
}


OSStatus SSSMTPConnectionSSLRead(SSLConnectionRef connection, void *data, size_t *dataLength) {
	size_t bytesToGo = *dataLength;
	size_t initLen = bytesToGo;
	UInt8 *currData = (UInt8 *)data;
	int	sock = *(int *)connection;
	OSStatus rtn = noErr;
	size_t bytesRead;
	ssize_t rrtn;
	
	*dataLength = 0;
	
	while (1) {
        bytesRead = 0;
		rrtn = read(sock, currData, bytesToGo);
		if (rrtn <= 0) {
			/* this is guesswork... */
			int theErr = errno;
			if ((rrtn == 0) && (theErr == 0)) {
				/* try fix for iSync */ 
				rtn = errSSLClosedGraceful;
				//rtn = errSSLClosedAbort;
			} else {
				switch(theErr) {
					case ENOENT:
						/* connection closed */
						rtn = errSSLClosedGraceful; 
						break;
					case ECONNRESET:
						rtn = errSSLClosedAbort;
						break;
					case 0:		/* ??? */
						rtn = errSSLWouldBlock;
						break;
					default:
						rtn = -36;//ioErr;
						break;
				}
			}
			break;
		} else {
			bytesRead = rrtn;
		}
		bytesToGo -= bytesRead;
		currData  += bytesRead;
		
		if (bytesToGo == 0) {
			/* filled buffer with incoming data, done */
			break;
		}
	}
	*dataLength = initLen - bytesToGo;
	return rtn;
}


OSStatus SSSMTPConnectionSSLWrite(SSLConnectionRef connection, const void *data, size_t *dataLength) {
	size_t bytesSent = 0;
	int	sock = *(int *)connection;
	ssize_t length;
	long dataLen = *dataLength;
	const UInt8 *dataPtr = (UInt8 *)data;
	OSStatus ortn;
	
	*dataLength = 0;
	
    do {
        length = write(sock, (char*)dataPtr + bytesSent, dataLen - bytesSent);
    } while ((length > 0) && ((bytesSent += length) < dataLen));
	
	if (length <= 0) {
		if (errno == EAGAIN) {
			ortn = errSSLWouldBlock;
		} else {
			ortn = -36;//ioErr;
		}
	} else {
		ortn = noErr;
	}
	*dataLength = bytesSent;
	return ortn;
}

- (BOOL)startSSL:(NSError *__nullable * __nullable)error {
	NSString *startTLS = @"STARTTLS\r\n";
	SSDebugLog(@"C:%@", startTLS);
	NSString *reply = [self hostReplyForCommand:startTLS];
	SSDebugLog(@"S:%@", reply);
	
	if (![reply hasPrefix:@"220 "]) {
        if (error) {
            *error = [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeSSLConnectionFailed userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"Server refused the STARTTLS message", @"")}];
        }
		return NO;
	}
	
    OSStatus status = noErr;
#if (!TARGET_OS_IPHONE && defined(__MAC_10_8)) || (TARGET_OS_IPHONE && defined(__IPHONE_5_0))
    if ((&SSLCreateContext) != NULL) {
        _sslContext = SSLCreateContext(NULL, kSSLClientSide, kSSLStreamType);
        status = _sslContext ? noErr : errSSLProtocol;
    }
#if !TARGET_OS_IPHONE
    else {
        status = SSLNewContext(false, &_sslContext);
    } 
#endif
#else
    status = SSLNewContext(false, &_sslContext);
#endif
 	
 	if (status != noErr) {
        if (error) {
            *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
        return NO;
    }
    
    SSLSetConnection(_sslContext, &_ssocket);
    SSLSetIOFuncs(_sslContext, SSSMTPConnectionSSLRead, SSSMTPConnectionSSLWrite);
#if (!TARGET_OS_IPHONE && defined(__MAC_10_8)) || (TARGET_OS_IPHONE && defined(__IPHONE_5_0))
    if ((&SSLSetProtocolVersionMin) != NULL) {
        switch (_securityLevel) {
            case SSSMTPConnectionSecurityLevelNone:
                break;
            case SSSMTPConnectionSecurityLevelSSLv3:
                SSLSetProtocolVersionMin(_sslContext, kSSLProtocol3);
                SSLSetProtocolVersionMax(_sslContext, kSSLProtocol3);
                break;
            case SSSMTPConnectionSecurityLevelTLSv1:
                SSLSetProtocolVersionMin(_sslContext, kTLSProtocol1);
                SSLSetProtocolVersionMax(_sslContext, kTLSProtocol12);
                break;
        }
    }
#if !TARGET_OS_IPHONE
    else {
        SSLSetProtocolVersionEnabled(_sslContext, kSSLProtocolAll, false);
        switch (_securityLevel) {
            case SSSMTPConnectionSecurityLevelSSLv3:
                SSLSetProtocolVersionEnabled(_sslContext, kSSLProtocol3, true);
                break;
            default:
                SSLSetProtocolVersionEnabled(_sslContext, kTLSProtocol1, true);
                break;
        }
    }
#endif
#else
    SSLSetProtocolVersionEnabled(_sslContext, kSSLProtocolAll, false);
    switch (_securityLevel) {
        case SSSMTPConnectionSecurityLevelSSLv3:
            SSLSetProtocolVersionEnabled(_sslContext, kSSLProtocol3, true);
            break;
        default:
            SSLSetProtocolVersionEnabled(_sslContext, kTLSProtocol1, true);
            break;
    }
#endif
    
    do {
        status = SSLHandshake(_sslContext);
    } while (status == errSSLWouldBlock || status == errSSLServerAuthCompleted);
    
    if (status != noErr) {
        if (error) {
            *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
        return NO;
    }
    
	return YES;
}

- (BOOL)autenthicateUser:(NSString *)user password:(NSString *)password scheme:(SSSMTPConnectionAuthenticationScheme)scheme error:(NSError *__nullable * __nullable)error {
    if (!self.isConnected) {
        return NO;
    }
    
	// Initiate interaction with the server
	
	NSString *reply = [self hostReplyForCommand:nil];
	if (!reply) {
        if (error) {
            *error = [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeConnectionFailed userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"Could not connect to server", @""), NSLocalizedRecoverySuggestionErrorKey: SSLocalizedString(@"Server does not respond.", @"")}];
        }
		return NO;
	}
	
	SSDebugLog(@"S:%@", reply);
	
	NSString *localhost = [self.class localIPAddress];
    if (localhost) {
        localhost = [NSString stringWithFormat:@"[%@]", localhost];
    } else {
        localhost = @"localhost";
    }
    
	NSString *ehlo = [NSString stringWithFormat:@"EHLO %@\r\n", localhost];
	SSDebugLog(@"C:%@", ehlo);
	reply = [self hostReplyForCommand:ehlo];
	SSDebugLog(@"S:%@", reply);
	
	if (![reply hasPrefix:@"250"]) {
        if (error) {
            *error = [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeEHLOMessage userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"Could not connect to server", @""), NSLocalizedRecoverySuggestionErrorKey: SSLocalizedString(@"The server refused our EHLO message.", @"")}];
        }
		return NO;
	}
	
	NSScanner *scanner = [NSScanner scannerWithString:reply];
	NSString *line = nil;
	
	while (!scanner.isAtEnd) {
		BOOL foundLine = [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&line];
		if (foundLine) {
            if ([line rangeOfString:@"8BITMIME" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                _supports8BITMIME = YES;
            }
            
			if ([line rangeOfString:@"STARTTLS" options:NSCaseInsensitiveSearch].location != NSNotFound) {
				_supportsSTARTTLS = YES;
				_supportsPlainAuth = YES;
				_supportsLoginAuth = YES;
			}
			
			if ([line rangeOfString:@"PLAIN" options:NSCaseInsensitiveSearch].location != NSNotFound) {
				_supportsPlainAuth = YES;
			}
			
			if ([line rangeOfString:@"LOGIN" options:NSCaseInsensitiveSearch].location != NSNotFound) {
				_supportsLoginAuth = YES;
			}
		}
    }
    
	if (_supportsSTARTTLS && (_securityLevel != SSSMTPConnectionSecurityLevelNone)) {
		// STARTTLS
        if (![self startSSL:error]) {
            return NO;
        }
        
		// RFC 3207 says that the EHLO command is discarded by the server after starting TLS, so we have to start again:
        
		SSDebugLog(@"C:%@", ehlo);
		reply = [self hostReplyForCommand:ehlo];
		SSDebugLog(@"S:%@", reply);
		
		if (![reply hasPrefix:@"250"]) {
            if (error) {
                *error = [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeEHLOMessage userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"Could not connect to server", @""), NSLocalizedRecoverySuggestionErrorKey: SSLocalizedString(@"The server refused our EHLO message.", @"")}];
            }
			return NO;
		}
	}
	
	// Authentication 
	
	BOOL schemeIsSupported = (_supportsPlainAuth || _supportsLoginAuth);
	if ((scheme != SSSMTPConnectionAuthenticationSchemeNone) && schemeIsSupported) {
		NSStringEncoding encoding = password.proposedStringEncoding;
		if ((scheme == SSSMTPConnectionAuthenticationSchemePlain) && _supportsPlainAuth) {
			NSString *loginString = [NSString stringWithFormat:@"\000%@\000%@", user, password];
			NSString *authString = [NSString stringWithFormat:@"AUTH PLAIN %@\r\n", [loginString dataUsingEncoding:encoding].encodeBase64];
			SSDebugLog(@"C:%@", authString);
			reply = [self hostReplyForCommand:authString];
			SSDebugLog(@"S:%@", reply);
		} else if ((scheme == SSSMTPConnectionAuthenticationSchemeLogin) && _supportsLoginAuth) {
			NSString *authString = @"AUTH LOGIN\r\n";
			SSDebugLog(@"C:%@", authString);
			reply = [self hostReplyForCommand:authString];
			SSDebugLog(@"S:%@", reply);
			if ([reply hasPrefix:@"334 VXNlcm5hbWU6"]) {
				authString = [NSString stringWithFormat:@"%@\r\n", [user dataUsingEncoding:encoding].encodeBase64];
				SSDebugLog(@"C:%@", authString);
				reply = [self hostReplyForCommand:authString];
				SSDebugLog(@"S:%@", reply);
				if ([reply hasPrefix:@"334 UGFzc3dvcmQ6"]) {
					authString = [NSString stringWithFormat:@"%@\r\n", [password dataUsingEncoding:encoding].encodeBase64];
					SSDebugLog(@"C:%@", authString);
					reply = [self hostReplyForCommand:authString];
					SSDebugLog(@"S:%@", reply);
				}
			}
		} else {
            if (error) {
                *error = [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeUnsupportedAuthenticationScheme userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"Unsupported login mechanism.", @""), NSLocalizedRecoverySuggestionErrorKey: SSLocalizedString(@"Could not find a compatible authentication mechanism.", @"")}];
            }
			return NO;
		}
		
		if ([reply hasPrefix:@"530"]) {
            if (error) {
                *error = [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeAuthenticationFailed userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"SMTP Server require SSL connection", @""), NSLocalizedRecoverySuggestionErrorKey: SSLocalizedString(@"Try enabling SSL.", @"")}];
            }
			return NO;
		}
		
		if (![reply hasPrefix:@"235"]) {
            if (error) {
                *error = [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeAuthenticationFailed userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"Authentication failed", @""), NSLocalizedRecoverySuggestionErrorKey: SSLocalizedString(@"Bad username or password.", @"")}];
            }
			return NO;
		}
	}		
	
	return YES;
}

- (BOOL)writeEnvelopeTo:(NSString *)to from:(NSString *)from error:(NSError *__nullable * __nullable)error {
    if (!self.isConnected) {
        return NO;
    }
    
	NSString *mailFrom = (_supports8BITMIME && _uses8BITMIME) ? [NSString stringWithFormat:@"MAIL FROM:<%@> BODY=8BITMIME\r\n", from] : [NSString stringWithFormat:@"MAIL FROM:<%@>\r\n", from];
	SSDebugLog(@"C:%@", mailFrom);
	NSString *reply = [self hostReplyForCommand:mailFrom];
	SSDebugLog(@"S:%@", reply);
	
	if (![reply hasPrefix:@"250"]) { //2.1.0
		NSString *recoverySuggestion = nil;
        if ([reply hasPrefix:@"530"]) {
            recoverySuggestion = SSLocalizedString(@"This server require authentication. Did you forgot to provide an authentication mechanism?. Please check your settings and try again later.", @"");
        } else {
            recoverySuggestion = SSLocalizedString(@"Sender rejected. From address is not one of your addresses.", @"");
        }
		
        if (error) {
            *error = [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeSenderRefused userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"The SMTP server refused the sender address", @""), NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion}];
        }
		return NO;
	}
	
	SSDebugLog(@"C:%@", to);
	reply = [self hostReplyForCommand:to];
	SSDebugLog(@"S:%@", reply);
	
	if (![reply hasPrefix:@"250"]) { //2.1.5
        if (error) {
            *error = [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeRecipientsRefused userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"All recipient addresses rejected.", @"")}];
        }
		return NO;
	}	
	
	return YES;
}

- (BOOL)writeSource:(NSString *)source error:(NSError *__nullable * __nullable)error  {
    if (!self.isConnected) {
        return NO;
    }
    
	NSString *data = @"DATA\r\n";
	SSDebugLog(@"C:%@", data);
	NSString *reply = [self hostReplyForCommand:data];
	SSDebugLog(@"S:%@", reply);
	
	if (![reply hasPrefix:@"354"]) {
        if (error) {
            *error = [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeInvalidMessageData userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"The SMTP server refused to accept the message's data.", @"")}];
        }
		return NO;
	}
	
	SSDebugLog(@"C:%@", source);
	reply = [self hostReplyForCommand:source];
	SSDebugLog(@"S:%@", reply);
	
	if (![reply hasPrefix:@"250"]) { // 2.2.0
        if (error) {
            *error = [NSError errorWithDomain:SSMessageErrorDomain code:SSMessageErrorCodeInvalidMessageData userInfo:@{NSLocalizedDescriptionKey: SSLocalizedString(@"The SMTP server refused to accept the message's data.", @"")}];
        }
		return NO;
	}	
	
	return YES;
}

- (void)disconnect  {
    if (!self.isConnected) {
        return;
    }
    
    SSDebugLog(@"%@ %@", self, NSStringFromSelector(_cmd));
    
    @try {
        NSString *quit = @"QUIT\r\n";
        SSDebugLog(@"C:%@", quit);
        NSString *reply = nil;
#if 1
        reply = [self hostReplyForCommand:quit];
#endif
        SSDebugLog(@"S:%@", reply);
    }
    @catch (NSException * e) {
        NSLog(@"%@ %@ \"%@\" %@", self, NSStringFromSelector(_cmd), e.name, e.reason);
    }
    @finally {
        if (_sslContext) {
            SSDebugLog(@"%@:Shutting down SSL...", self);
            
            SSLClose(_sslContext);
#if (!TARGET_OS_IPHONE && defined(__MAC_10_8)) || (TARGET_OS_IPHONE && defined(__IPHONE_5_0))
            if (!(&SSLCreateContext)) {
                CFRelease(_sslContext);
            }
#if !TARGET_OS_IPHONE
            else {
                SSLDisposeContext(_sslContext);
            }
#endif
#else
            SSLDisposeContext(_sslContext);
#endif
            _sslContext = NULL;
        }
        
        SSDebugLog(@"%@:Closing connection with server...", self);
        
        shutdown(_ssocket, 2);
        close(_ssocket);
        _ssocket = -1;
        
        self.host = nil;
    }
}



#pragma mark getters and setters

- (BOOL)isConnected  {
	return (_ssocket != -1);
}

- (NSString *)host  {
    return SSAtomicAutoreleasedGet(_host);
}

- (void)setHost:(NSString *)host {
    SSAtomicCopiedSet(_host, host);
}

- (NSInteger)port; {
    return _port;
}

- (void)setPort:(NSInteger)port; {
    _port = port;
}

- (BOOL)uses8BITMIME; {
    return _uses8BITMIME;
}

- (void)setUses8BITMIME:(BOOL)uses8BITMIME; {
    _uses8BITMIME = uses8BITMIME;
}

- (BOOL)supports8BITMIME; {
    return _supports8BITMIME;
}

- (void)setSupports8BITMIME:(BOOL)supports8BITMIME; {
    _supports8BITMIME = supports8BITMIME;
}

- (BOOL)provideDetailedConnectionError; {
    return _provideDetailedConnectionError;
}

- (void)setProvideDetailedConnectionError:(BOOL)provideDetailedConnectionError; {
    _provideDetailedConnectionError = provideDetailedConnectionError;
}

- (SSSMTPConnectionSecurityLevel)securityLevel; {
    return _securityLevel;
}

- (void)setSecurityLevel:(SSSMTPConnectionSecurityLevel)securityLevel; {
    _securityLevel = securityLevel;
}

- (NSTimeInterval)timeout; {
    return _timeout;
}

- (void)setTimeout:(NSTimeInterval)timeout; {
    _timeout = timeout;
}

+ (NSString *)localIPAddress  {
	NSString *address = nil;
#if 0
    NSURL *URL = [NSURL URLWithString:@"http://whatsmyip.islayer.com"];
	if ((SSMessageValidateConnectionWithURL(URL, NULL) == kCFNetDiagnosticConnectionUp)) {
		address = [NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:nil];
        if ([[address componentsSeparatedByString:@"."] count] > 3) {
            return address;
        }
	}
#endif
	struct ifaddrs *interfaces = NULL;
	struct ifaddrs *temp_addr = NULL;
	int success = getifaddrs(&interfaces);
	if (success == 0) {
		temp_addr = interfaces;
		while (temp_addr != NULL) {
			if (temp_addr->ifa_addr->sa_family == AF_INET) {
                if ([@(temp_addr->ifa_name) isEqualToString:@"en0"]) {
                    address = @(inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr));
                }
			}
			temp_addr = temp_addr->ifa_next;
		}
        freeifaddrs(interfaces);
	}
	return address;
}

@end
