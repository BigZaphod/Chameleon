//
//  MFMessageComposeViewController.h
//  MessageUI
//
//  Created by Peter Steinberger on 24.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@protocol MFMessageComposeViewControllerDelegate;

enum MessageComposeResult {
  MessageComposeResultCancelled,
  MessageComposeResultSent,
  MessageComposeResultFailed
};
typedef enum MessageComposeResult MessageComposeResult;

@interface MFMessageComposeViewController : NSObject {
  __weak id<MFMessageComposeViewControllerDelegate> _messageComposeDelegate;
}

@property (nonatomic, assign) id<MFMessageComposeViewControllerDelegate> messageComposeDelegate;

@end


@protocol MFMessageComposeViewControllerDelegate <NSObject>
@required
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result;
@end