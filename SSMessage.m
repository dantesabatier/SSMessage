//
//  SSMessage.m
//  SSMessage
//
//  Created by Dante Sabatier on 30/08/09.
//  Copyright 2009 Dante Sabatier. All rights reserved.
//


#import "SSMessage.h"
#import "SSMessageDefines.h"
#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h>
#endif
#import <objc/objc-sync.h>

@interface SSMessage ()

@end

@implementation SSMessage

#pragma mark Life Cycle

- (instancetype)init {
	self = [super init];
	if (self) {
		self.format = SSMessageFormatMultipartAlternative;
		self.encoding = NSASCIIStringEncoding;
		self.priority = SSMessagePriorityNormal;
	}
	return self;
}

- (instancetype)initWithHeaders:(NSDictionary <SSMessageHeaderKey, id>*)messageHeaders content:(NSAttributedString *)messageBody format:(SSMessageFormat)messageFormat {
	self = [self init];
	if (self) {
		self.headers = messageHeaders;
		self.content = messageBody;
		self.format = messageFormat;
	}
	return self;
}

- (instancetype)initWithHeaders:(NSDictionary <SSMessageHeaderKey, id>*)messageHeaders content:(NSAttributedString *)messageBody  {
	return [self initWithHeaders:messageHeaders content:messageBody format:SSMessageFormatMultipartAlternative];
}

- (instancetype)copyWithZone:(NSZone *)zone {
	SSMessage *message = [super copyWithZone:zone];
    if (message) {
        message.encoding = self.encoding;
        message.priority = self.priority;
    }
	return message;
}

- (void)encodeWithCoder:(NSCoder *)coder  {
	[super encodeWithCoder:coder];
	[coder encodeObject:self.parts forKey:@"parts"];
	[coder encodeObject:self.source forKey:@"source"];
	[coder encodeInteger:self.encoding forKey:@"encoding"];
}

- (instancetype)initWithCoder:(NSCoder *)coder  {
	self = [super initWithCoder:coder];
	if (self) {
		self.parts = [coder decodeObjectForKey:@"parts"];
		self.source = [coder decodeObjectForKey:@"source"];
		self.encoding = [coder decodeIntegerForKey:@"encoding"];
	}
	return self;
}

- (void)dealloc  {
	[_representedObject release];
	[_dateSent release];
	[_parts release];
	[_source release];
	[_attachments release];
	[_sender release];
	[_subject release];
	[_replyTo release];
	[_recipients release];
	[_toRecipients release];
	[_ccRecipients release];
	[_bccRecipients release];
    [_relatedBoundary release];
	
	[super ss_dealloc];
}

#pragma mark getters & setters

- (NSDictionary <SSMessageHeaderKey, id> *)headers {
    return super.headers;
}

- (void)setHeaders:(NSDictionary <SSMessageHeaderKey, id> *)headers {
    super.headers = headers;
    self.sender = [headers objectForCaseInsensitiveKey:SSMessageHeaderKeyFrom];
    self.subject = [headers objectForCaseInsensitiveKey:SSMessageHeaderKeySubject];
    self.replyTo = [headers messageAddresseesForKey:SSMessageHeaderKeyReplyTo];
    self.toRecipients = [headers messageAddresseesForKey:SSMessageHeaderKeyToRecipients];
    self.ccRecipients = [headers messageAddresseesForKey:SSMessageHeaderKeyCcRecipients];
    self.bccRecipients = [headers messageAddresseesForKey:SSMessageHeaderKeyBccRecipients];
    self.source = nil;
}

- (void)setContent:(id<NSCopying, NSCoding>)content {
    super.content = content;
    if ([content isKindOfClass:[NSAttributedString class]]) {
        self.attachments = (NSArray <SSMessageAttachment*>*)[((NSAttributedString *)self.content).attachments mapObjectsUsingBlock:^id _Nullable(NSTextAttachment * _Nonnull obj) {
            SSMessageAttachment *attachment = [[SSMessageAttachment alloc] initWithMessageAttachment:obj];
            attachment.boundary = self.relatedBoundary;
            return attachment.autorelease;
        }];
    }
}

- (id<SSMessageAddressee>)sender {
    return SSAtomicAutoreleasedGet(_sender);
}

- (void)setSender:(id<SSMessageAddressee>)sender {
    SSAtomicCopiedSet(_sender, sender);
}

- (NSString *)subject {
    return SSAtomicAutoreleasedGet(_subject);
}

- (void)setSubject:(NSString *)subject {
    SSAtomicCopiedSet(_subject, subject);
}

- (NSArray <__kindof id <SSMessageAddressee>>*)replyTo {
    return SSAtomicAutoreleasedGet(_replyTo);
}

- (void)setReplyTo:(NSArray <__kindof id <SSMessageAddressee>>*)replyTo {
    SSAtomicCopiedSet(_replyTo, replyTo);
}

- (NSArray <__kindof id <SSMessageAddressee>>*)toRecipients {
    return SSAtomicAutoreleasedGet(_toRecipients);
}

- (void)setToRecipients:(NSArray <__kindof id <SSMessageAddressee>>*)toRecipients {
    SSAtomicCopiedSet(_toRecipients, toRecipients);
}

- (NSArray <__kindof id <SSMessageAddressee>>*)ccRecipients {
    return SSAtomicAutoreleasedGet(_ccRecipients);
}

- (void)setCcRecipients:(NSArray <__kindof id <SSMessageAddressee>>*)ccRecipients {
    SSAtomicCopiedSet(_ccRecipients, ccRecipients);
}

- (NSArray <__kindof id <SSMessageAddressee>>*)bccRecipients {
    return SSAtomicAutoreleasedGet(_bccRecipients);
}

- (void)setBccRecipients:(NSArray <__kindof id <SSMessageAddressee>>*)bccRecipients {
    SSAtomicCopiedSet(_bccRecipients, bccRecipients);
}

- (NSArray <__kindof id <SSMessageAddressee>>*)recipients {
    objc_sync_enter(self);
    if (!_recipients) {
        NSMutableArray *recipients = [NSMutableArray array];
        [recipients addObjectsFromArray:self.ccRecipients];
        [recipients addObjectsFromArray:self.toRecipients];
        [recipients addObjectsFromArray:self.bccRecipients];
        _recipients = [recipients copy];
    }
    objc_sync_exit(self);
    return SSAtomicAutoreleasedGet(_recipients);
}

- (void)setRecipients:(NSArray <__kindof id <SSMessageAddressee>>*)recipients {
    SSAtomicCopiedSet(_recipients, recipients);
}

- (NSDate *)dateSent {
	return SSAtomicAutoreleasedGet(_dateSent);
}

- (void)setDateSent:(NSDate *)dateSent {
	SSAtomicRetainedSet(_dateSent, dateSent);
}

- (NSArray <id <SSMessagePart>>*)parts {
    objc_sync_enter(self);
    if (!_parts) {
        NSAttributedString *content = self.content;
        NSString *plainText = content.plainText.stringWithCRLFLineBreaks;
        NSStringEncoding encoding = self.encoding;
        if (encoding == NSASCIIStringEncoding) {
            encoding = plainText.proposedStringEncoding;
        }
        
        self.encoding = encoding;
        self.charset = [NSString mimeNameOfStringEncoding:encoding];
        self.contentTransferEncoding = (encoding != NSASCIIStringEncoding) ? @"8bit" : @"7bit" ;
        
        NSMutableArray <id <SSMessagePart>>*messageParts = [NSMutableArray array];
        
        SSMessagePart *textPart = [[SSMessagePart alloc] init];
        textPart.contentType = SSMessagePartContentTypePlainText;
        textPart.charset = self.charset;
        textPart.format = SSMessagePartFormatFlowed;
        textPart.contentTransferEncoding = self.contentTransferEncoding;
        textPart.content = plainText;
        textPart.boundary = self.boundary;
        
        [messageParts addObject:textPart];
        
        [textPart release];
        
        if (self.format == SSMessageFormatMultipartAlternative) {
            NSString *htmlContent = content.HTMLString.stringWithCRLFLineBreaks;
            NSArray <id <SSMessageAttachment>>*attachments = self.attachments;
            if (attachments.count) {
                NSMutableString *htmlString = [NSMutableString stringWithString:htmlContent];
                for (id <SSMessageAttachment>attachment in attachments) {
                    [htmlString replaceOccurrencesOfString:[NSString stringWithFormat:@"file:///%@", [attachment.filename stringByAddingPercentEscapesUsingEncoding:attachment.filename.proposedStringEncoding]] withString:[NSString stringWithFormat:@"cid:%@", attachment.contentID] options:NSLiteralSearch range:NSMakeRange(0, htmlString.length)];
                }
                htmlContent = htmlString;
            }
            
            SSMessagePart *htmlPart = [[SSMessagePart alloc] init];
            htmlPart.contentType = SSMessagePartContentTypeHTML;
            htmlPart.charset = self.charset;
            htmlPart.contentTransferEncoding = self.contentTransferEncoding;
            htmlPart.content = htmlContent;
            htmlPart.boundary = attachments.count ? self.relatedBoundary : self.boundary;
            
            [messageParts addObject:htmlPart];
            [messageParts addObjectsFromArray:attachments];
            
            [htmlPart release];
        }
        _parts = [messageParts copy];			
    }
    objc_sync_exit(self);
	return SSAtomicAutoreleasedGet(_parts);
}

- (void)setParts:(NSArray <id <SSMessagePart>>*)parts {
    SSAtomicCopiedSet(_parts, parts);
}

- (NSString *)source {
    objc_sync_enter(self);
    if (!_source) {
        // start
        self.contentTransferEncoding = (self.encoding != NSASCIIStringEncoding) ? @"8bit" : @"7bit" ;
        self.contentType = self.format;
        self.charset = [NSString mimeNameOfStringEncoding:self.encoding];
        
        NSMutableString *messagePart = [NSMutableString string];
        [messagePart appendFormat:@"Message-id: %@\r\n", self.identifier];
        
        NSString *format = self.format;
        if (format == SSMessageFormatMultipartAlternative) {
            [messagePart appendFormat:@"Content-Type: %@; boundary=%@\r\n", self.contentType, self.boundary];
        } else {
            [messagePart appendFormat:@"Content-Type: %@; charset=%@; format=flowed\r\n", self.contentType, self.charset];
        }
        
#if TARGET_OS_IPHONE
        NSDateFormatter	*dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss Z";
        NSString *date = [dateFormatter stringFromDate:[NSDate date]];
        [messagePart appendFormat:@"Date: %@\r\n", date];
        [messagePart appendFormat:@"Mime-Version: 1.0 (%@ framework v%@)\r\n", NSStringFromClass(SSMessage.class), @"1.0.9"];
#else
        NSString *date = [[NSCalendarDate calendarDate] descriptionWithCalendarFormat:@"%a, %e %b %Y %H:%M:%S %z" locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
        NSBundle *framework = [NSBundle bundleForClass:SSMessage.class];
        [messagePart appendFormat:@"Date: %@\r\n", date];
        [messagePart appendFormat:@"Mime-Version: 1.0 (%@ framework v%@)\r\n", [framework objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleNameKey], [framework objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleVersionKey]];
#endif
        [messagePart appendFormat:@"X-Priority: %@\r\n", @(self.priority)];
        
        NSDictionary *headers = self.headers;
        NSArray *keys = [headers.allKeys sortedArrayUsingSelector:@selector(compare:)];
        for (NSString *key in keys) {
            if (!key.length) {
                continue;
            }
            
            NSString *headerName = key.capitalizedString;
            //the value of a header must be an NSString object
            NSString *headerValue = nil;
            id object = headers[key];
            if ([object isKindOfClass:[NSArray class]]) {
                headerValue = [(NSArray *)object componentsJoinedByString:@", "];
            } else if ([object isKindOfClass:[NSString class]]) {
                headerValue = (NSString *)object;
            } else if ([object conformsToProtocol:@protocol(SSMessageAddressee)]) {
                headerValue = ((id <SSMessageAddressee>)object).fullMessageAddress;
            } else if ([object isKindOfClass:[NSNumber class]]) {
                headerValue = ((NSNumber *)object).stringValue;
            }
            
            if (headerValue) {
                //TODO: Check message header line length limits...
                [messagePart appendFormat:@"%@: %@\r\n", headerName, headerValue];
            }
        }
        
        [messagePart appendString:@"\r\n"];
        
        //end of the message itself part, append parts
        
        NSMutableString *messageContent = [NSMutableString string];
        if (self.parts.count) {
            if ([format isEqualToString:SSMessageFormatMultipartAlternative]) {
                BOOL hasAttachments = (self.parts.count > 2);
                for (id <SSMessagePart>part in self.parts) {
                    id content = part.content;
                    NSString *contentType = part.contentType;
                    if ([content isKindOfClass:[NSString class]]) {
                        if ((contentType == SSMessagePartContentTypeHTML) && hasAttachments) {
                            [messageContent appendFormat:@"\r\n—%@\r\n", self.boundary];
                            [messageContent appendFormat:@"Content-Type: multipart/related;\r\n\tboundary=%@;\r\n\ttype=\"%@\"\r\n", part.boundary, SSMessagePartContentTypeHTML];
                        }
                        
                        [messageContent appendFormat:@"\r\n—%@\r\n", part.boundary];
                        [messageContent appendFormat:@"Content-Type: %@;\r\n\tcharset=%@;\r\n", part.contentType, part.charset];
                        [messageContent appendFormat:@"Content-Transfer-Encoding: %@\r\n", part.contentTransferEncoding];
                        [messageContent appendString:@"\r\n"];
                        [messageContent appendString:((NSString *)content).stringWithCRLFLineBreaks];
                    } else if ([content isKindOfClass:[NSData class]]) {
                        [messageContent appendFormat:@"\r\n—%@\r\n", part.boundary];
                        [messageContent appendFormat:@"Content-Transfer-Encoding: %@\r\n", part.contentTransferEncoding];
                        
                        if ([part.contentDisposition isEqualToString:SSMessagePartContentDispositionAttachment]) {
                            // this content could be displayed inline and we don't want that
                            if ((contentType == SSMessagePartContentTypeHTML) || (contentType == SSMessagePartContentTypePlainText)) {
                                contentType = @"text/directory";
                            }
                        }
                        
                        [messageContent appendFormat:@"Content-Type: %@;\r\n\tx-unix-mode=0644;\r\n\tname=\"%@\"\r\n", contentType, part.filename];
                        [messageContent appendFormat:@"Content-Disposition: %@;\r\n\tfilename=%@\r\n", part.contentDisposition, part.filename];
                        [messageContent appendFormat:@"Content-Id: <%@>\r\n", part.contentID];
                        [messageContent appendString:@"\r\n"];
                        
                        //every line must end with CRFL line breaks
                        [messageContent appendString:[(NSData *)part.content encodeBase64WithNewlines:YES].stringWithCRLFLineBreaks];
                        [messageContent appendString:@"\r\n"];
                    }
                }
                if (hasAttachments) {
                    [messageContent appendFormat:@"\r\n—%@—\r\n", self.relatedBoundary];
                }
                [messageContent appendFormat:@"\r\n—%@—\r\n", self.boundary];
            } else {
                if ([self.parts.firstObject.content isKindOfClass:[NSString class]]) {
                    [messageContent appendString:((NSString *)self.parts.firstObject.content).stringWithCRLFLineBreaks];
                }
            }
        } else {
            if ([self.content isKindOfClass:[NSAttributedString class]]) {
                [messageContent appendString:((NSAttributedString *)self.content).plainText.stringWithCRLFLineBreaks];
            }
        }
        
        // the end
        
        NSMutableString *messageSource = [NSMutableString string];
        [messageSource appendString:messagePart];
        [messageSource appendString:messageContent];
        [messageSource appendString:@"\r\n.\r\n"];
        
        _source = [messageSource copy];
    }
    objc_sync_exit(self);
	return SSAtomicAutoreleasedGet(_source);
}

- (void)setSource:(NSString *)source {
    SSAtomicCopiedSet(_source, source);
}

- (NSArray <id <SSMessageAttachment>>*)attachments {
    return SSAtomicAutoreleasedGet(_attachments);
}

- (void)setAttachments:(NSArray <id <SSMessageAttachment>>*)attachments {
    SSAtomicRetainedSet(_attachments, attachments);
}

- (NSStringEncoding)encoding {
    return _encoding;
}

- (void)setEncoding:(NSStringEncoding)encoding {
    _encoding = encoding;
}

- (SSMessagePriority)priority {
    return _priority;
}

- (void)setPriority:(SSMessagePriority)priority {
    _priority = priority;
}

- (NSString *)relatedBoundary {
    objc_sync_enter(self);
    if (!_relatedBoundary) {
        NSString *boundary = self.boundary;
        NSString *baseBoundary = [boundary componentsSeparatedByString:@"—"].lastObject;
        NSArray *boundaryItems = [boundary componentsSeparatedByString:@"-"];
        NSString *bundleName = boundaryItems[0];
        NSInteger partNumber = [boundaryItems[1] integerValue];
        _relatedBoundary = [[NSString alloc] initWithFormat:@"%@-%@—%@", bundleName, @(partNumber - 1), baseBoundary];
    }
    objc_sync_exit(self);
    return SSAtomicAutoreleasedGet(_relatedBoundary);
}

- (id)representedObject {
    return SSAtomicAutoreleasedGet(_representedObject);
}

- (void)setRepresentedObject:(id)representedObject {
    SSAtomicRetainedSet(_representedObject, representedObject);
}

@end
