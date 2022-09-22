//
//  SSMessagePart.m
//  SSMessage
//
//  Created by Dante Sabatier on 9/26/09.
//  Copyright 2009 Dante Sabatier. All rights reserved.
//

#import "SSMessagePart.h"
#import "SSMessageUtilities.h"
#import "SSMessageDefines.h"


SSMessagePartFormat const SSMessagePartFormatFlowed = @"flowed";

@implementation SSMessagePart

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *name = nil;//[[[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString *) kCFBundleNameKey] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        if (!name) {
#if TARGET_OS_IPHONE
            name = @"SSMessage";
#else
            name = [[NSBundle bundleForClass:SSMessagePart.class] objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleNameKey];
#endif
        }
        self.identifier = (__bridge NSString *)SSAutorelease(CFUUIDCreateString(kCFAllocatorDefault, SSAutorelease(CFUUIDCreate(kCFAllocatorDefault))));
        self.boundary = [NSString stringWithFormat:@"%@-%@—%@", name, @(arc4random_uniform(11) + 4), @(arc4random_uniform(1000))];
        self.creationDate = [NSDate date];
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    SSMessagePart *part = [[self.class allocWithZone:zone] init];
    part.content = self.content;
    part.headers = self.headers;
    part.name = self.name;
    part.contentType = self.contentType;
    part.contentID = self.contentID;
    part.contentDisposition = self.contentDisposition;
    part.contentTransferEncoding = self.contentTransferEncoding;
    part.filename = self.filename;
    part.format = self.format;
    part.protocol = self.protocol;
    part.charset = self.charset;
    part.creationDate = [NSDate date];
	return part;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.identifier forKey:@"identifier"];
	[coder encodeObject:self.content forKey:@"content"];
	[coder encodeObject:self.headers forKey:@"headers"];
	[coder encodeObject:self.name forKey:@"name"];
	[coder encodeObject:self.contentType forKey:@"contentType"];
    [coder encodeObject:self.contentID forKey:@"contentID"];
    [coder encodeObject:self.contentDisposition forKey:@"contentDisposition"];
	[coder encodeObject:self.contentTransferEncoding forKey:@"contentTransferEncoding"];
	[coder encodeObject:self.filename forKey:@"filename"];
	[coder encodeObject:self.format forKey:@"format"];
    [coder encodeObject:self.boundary forKey:@"boundary"];
    [coder encodeObject:self.protocol forKey:@"protocol"];
	[coder encodeObject:self.charset forKey:@"charset"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder  {
    self = [super init];
    if (self) {
        self.identifier = [coder decodeObjectForKey:@"identifier"];
        self.content = [decoder decodeObjectForKey:@"content"];
        self.headers = [decoder decodeObjectForKey:@"headers"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.contentType = [decoder decodeObjectForKey:@"contentType"];
        self.contentID = [decoder decodeObjectForKey:@"contentID"];
        self.contentDisposition = [decoder decodeObjectForKey:@"contentDisposition"];
        self.contentTransferEncoding = [decoder decodeObjectForKey:@"contentTransferEncoding"];
        self.filename = [decoder decodeObjectForKey:@"filename"];
        self.format = [decoder decodeObjectForKey:@"format"];
        self.boundary = [decoder decodeObjectForKey:@"boundary"];
        self.protocol = [decoder decodeObjectForKey:@"protocol"];
        self.charset = [decoder decodeObjectForKey:@"charset"];
    }
    return self;
}

- (void)dealloc  {
    [_identifier release];
	[_name release];
	[_content release];
	[_contentType release];
	[_contentID release];
	[_contentDisposition release];
	[_contentTransferEncoding release];
	[_filename release];
	[_format release];
	[_boundary release];
	[_protocol release];
	[_charset release];
	[_headers release];
	[_creationDate release];
	
	[super ss_dealloc];
}

- (NSString *)identifier {
	return SSAtomicAutoreleasedGet(_identifier);
}

- (void)setIdentifier:(NSString *)identifier  {
    SSAtomicCopiedSet(_identifier, identifier);
}

- (nullable NSString *)name  {
    return SSAtomicAutoreleasedGet(_name);
}

- (void)setName:(nullable NSString *)name  {
    SSAtomicCopiedSet(_name, name);
}

- (nullable id<NSCopying, NSCoding>)content  {
    return SSAtomicAutoreleasedGet(_content);
}

- (void)setContent:(nullable id<NSCopying, NSCoding>)content  {
	SSAtomicCopiedSet(_content, content);
}

- (nullable NSString *)contentType  {
   return SSAtomicAutoreleasedGet(_contentType);
}

- (void)setContentType:(nullable NSString *)contentType  {
    SSAtomicCopiedSet(_contentType, contentType);
}

- (nullable NSString *)contentID  {
    return SSAtomicAutoreleasedGet(_contentID);
}

- (void)setContentID:(nullable NSString *)contentID  {
    SSAtomicCopiedSet(_contentID, contentID);
}

- (nullable NSString *)contentDisposition  {
    return SSAtomicAutoreleasedGet(_contentDisposition);
}

- (void)setContentDisposition:(nullable NSString *)contentDisposition  {
    SSAtomicCopiedSet(_contentDisposition, contentDisposition);
}

- (nullable NSString *)contentTransferEncoding  {
    return SSAtomicAutoreleasedGet(_contentTransferEncoding);
}

- (void)setContentTransferEncoding:(nullable NSString *)contentTransferEncoding  {
     SSAtomicCopiedSet(_contentTransferEncoding, contentTransferEncoding);
}

- (nullable NSString *)filename  {
    return SSAtomicAutoreleasedGet(_filename);
}

- (void)setFilename:(nullable NSString *)filename  {
    SSAtomicCopiedSet(_filename, filename);
}

- (nullable NSString *)format  {
    return SSAtomicAutoreleasedGet(_format);
}

- (void)setFormat:(nullable NSString *)format  {
    SSAtomicCopiedSet(_format, format);
}

- (nullable NSString *)boundary  {
	return SSAtomicAutoreleasedGet(_boundary);
}

- (void)setBoundary:(nullable NSString *)boundary  {
     SSAtomicRetainedSet(_boundary, boundary);
}

- (nullable NSString *)protocol  {
    return SSAtomicAutoreleasedGet(_protocol);
}

- (void)setProtocol:(nullable NSString *)protocol  {
     SSAtomicCopiedSet(_protocol, protocol);
}

- (nullable NSString *)charset  {
    return SSAtomicAutoreleasedGet(_charset);
}

- (void)setCharset:(nullable NSString *)charset  {
    SSAtomicCopiedSet(_charset, charset);
}

- (nullable NSDictionary <SSMessagePartHeaderKey, id>*)headers  {
    return SSAtomicAutoreleasedGet(_headers);
}

- (void)setHeaders:(nullable NSDictionary <SSMessagePartHeaderKey, id>*)headers  {
    SSAtomicCopiedSet(_headers, headers);
}

- (NSDate *)creationDate  {
    return SSAtomicAutoreleasedGet(_creationDate);
}

- (void)setCreationDate:(NSDate *)creationDate  {
    SSAtomicCopiedSet(_creationDate, creationDate);
}

@end
