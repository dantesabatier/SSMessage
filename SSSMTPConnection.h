//
//  SSSMTPConnection.h
//  SSMessage
//
//  Created by Dante Sabatier on 9/24/09.
//  Copyright 2009 Dante Sabatier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/SecureTransport.h>
#import "SSMessageErrors.h"
#import "SSSMTPConnectionSecurityLevel.h"
#import "SSSMTPConnectionAuthenticationScheme.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @class SSSMTPConnection
  @brief Class to connect to a TCP server and to send email messages.
 @discussion Represents the connection with the server and our client to send the email message.
 */

@interface SSSMTPConnection : NSObject {
@package
    SSLContextRef _sslContext;
    int _ssocket;
    NSInteger _port;
    NSString *_host;
    SSSMTPConnectionSecurityLevel _securityLevel;
    NSTimeInterval _timeout;
    BOOL _supports8BITMIME;
    BOOL _supportsSTARTTLS;
    BOOL _supportsPlainAuth;
    BOOL _supportsLoginAuth;
    BOOL _uses8BITMIME;
    BOOL _provideDetailedConnectionError;
}

- (instancetype)init __attribute__((objc_designated_initializer));

/*!
 @discussion if the connection fails, this method returns nil.
 @param host
 the name of the host.
 @param port
 the number of port to make the connection.
 */

- (nullable instancetype)initWithHost:(NSString *)host port:(NSInteger)port error:(NSError *__nullable * __nullable)error;

/*!
 @brief the name of the host. E.g. smtp.mac.com.
 */

@property (nullable, readonly, copy) NSString *host;

/*!
 @brief port
 */

@property (readonly) NSInteger port;

/*!
 @brief should use 8 bit data transmission (if possible)?, default is YES. You can turn off this value if you need to send a message in a quoted printable form using SMIME for example.
 */

@property BOOL uses8BITMIME;

/*!
 @discussion conection timeout, default is 60 seconds. <tt>SSMessageDelivery</tt> set this value to 8 seconds.
 */

@property NSTimeInterval timeout;

/*!
 @discussion SSSMTPConnectionSecurityLevel, default is <tt>SSSMTPConnectionSecurityLevelTLSv1</tt>.
 */

@property SSSMTPConnectionSecurityLevel securityLevel;

/*!
 @return <tt>YES</tt> if the reciver is connected to a host.
 */

@property (readonly) BOOL isConnected;

/*!
 @return YES if the relay host supports 8 bit data transmission.
 */

@property (readonly) BOOL supports8BITMIME;

/*!
 @discussion if NO, a generic error will be returned, this only affects to the posible errors at the moment of the connection, note that most of these errors are not good to present to the user, are there only to provide detailed information about when a connection fails. Default if YES, <tt>SSMessageDelivery</tt> sets this value to NO.
 */

@property BOOL provideDetailedConnectionError;

/*!
 @discussion attempts to connect to a SMTP server.
 @param host
 the name of the host.
 @param port
 the number of port to make the connection.
 */

- (BOOL)connectToHost:(NSString *)host port:(NSInteger)port error:(NSError *__nullable * __nullable)error;

/*!
 @brief starts the SSL handshake */

- (BOOL)startSSL:(NSError *__nullable * __nullable)error;

/*!
 @method autenthicateUser:password:scheme:
 @brief authenticates user using password and scheme.
 @param user
 the username.
 @param password
 the password.
 @param scheme
 the <tt>SSSMTPConnectionAuthenticationScheme</tt> to use.
 */

- (BOOL)autenthicateUser:(NSString *)user password:(NSString *)password scheme:(SSSMTPConnectionAuthenticationScheme)scheme error:(NSError *__nullable * __nullable)error;

/*!
 @brief write the message envelope.
 @param to
 a CRLF separated list of addresses using the format @textblock \@"RCPT TO:<email>. @/textblock See @link //message_ref/occ/instm/NSArray(NSArray+SSAdditions)/componentsJoinedAsRecipients componentsJoinedAsRecipients @/link.
 @param from
 who sends the message.
 */

- (BOOL)writeEnvelopeTo:(NSString *)to from:(NSString *)from error:(NSError *__nullable * __nullable)error;

/*!
 @brief sends the source of the message.
 @param source
 the raw source of the message. End with CRLF.CRLF (\@"\r\n.\r\n").
 */

- (BOOL)writeSource:(NSString *)source error:(NSError *__nullable * __nullable)error;

/*!
 @brief disconnects the reciver from a server.
 */

- (void)disconnect;

@end

NS_ASSUME_NONNULL_END
