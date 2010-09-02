//  Created by Sean Heber on 9/2/10.
#import "MFMailComposeViewController.h"

@implementation MFMailComposeViewController
@synthesize mailComposeDelegate=_mailComposeDelegate;

+ (BOOL)canSendMail
{
	return NO;
}

- (void)setSubject:(NSString*)subject
{
}

- (void)setToRecipients:(NSArray*)toRecipients
{
}

- (void)setMessageBody:(NSString*)body isHTML:(BOOL)isHTML
{
}

- (void)setCcRecipients:(NSArray*)ccRecipients
{
}

- (void)setBccRecipients:(NSArray*)bccRecipients
{
}

- (void)addAttachmentData:(NSData*)attachment mimeType:(NSString*)mimeType fileName:(NSString*)filename
{
}

@end
