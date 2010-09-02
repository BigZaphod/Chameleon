//  Created by Sean Heber on 9/2/10.
#import <UIKit/UINavigationController.h>

@class MFMailComposeViewController;

enum MFMailComposeResult {
	MFMailComposeResultCancelled,
	MFMailComposeResultSaved,
	MFMailComposeResultSent,
	MFMailComposeResultFailed
};
typedef enum MFMailComposeResult MFMailComposeResult;

@protocol MFMailComposeViewControllerDelegate <NSObject>
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
@end

@interface MFMailComposeViewController : UINavigationController {
@private
	id<MFMailComposeViewControllerDelegate> _mailComposeDelegate;
}

+ (BOOL)canSendMail;

- (void)setSubject:(NSString*)subject;
- (void)setToRecipients:(NSArray*)toRecipients;
- (void)setMessageBody:(NSString*)body isHTML:(BOOL)isHTML;
- (void)setCcRecipients:(NSArray*)ccRecipients;
- (void)setBccRecipients:(NSArray*)bccRecipients;
- (void)addAttachmentData:(NSData*)attachment mimeType:(NSString*)mimeType fileName:(NSString*)filename;

@property (nonatomic,assign) id<MFMailComposeViewControllerDelegate> mailComposeDelegate;

@end
