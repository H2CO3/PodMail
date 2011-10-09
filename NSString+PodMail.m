//
// NSString+PodMail.m
// PodMail
//
// Copyright H2CO3, 2011.
// Created by Árpád Goretity, 04/10/2011.
//
// Licensed under a CreativeCommons Attribution 3.0 Unported License
//

#import "NSString+PodMail.h"


@implementation NSString (PodMail)

- (NSString *) mimeType {
	CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[self pathExtension], NULL);
	NSString *mimeType = [(NSString *)UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType) autorelease];
	CFRelease(UTI);
	if (mimeType == NULL) {
		mimeType = @"application/octet-stream";
	}
	return mimeType;
}

@end

