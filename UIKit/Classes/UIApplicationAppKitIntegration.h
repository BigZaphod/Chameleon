/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UIApplication.h"

extern NSString *const UIApplicationNetworkActivityIndicatorChangedNotification;

@interface UIApplication (AppKitIntegration)

// the -runBackgroundTasksBeforeDate:title:message:buttonTitle:completionHandler: method will
// put the app into a modal state and present an alert using the titles/messages given.
// then it will allow any background tasks registered with UIApplcation (if any) to finish.
// if time expires before they finish, their expiration handlers will be called.
// once this is finished waiting/expiring stuff, it will run the completionHandler block.
// this is intended to be run from NSApplicationDelegate's -applicationShouldTerminate: method.
// with code that looks something like this:
/*

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    [[UIApplication sharedApplication] runBackgroundTasksBeforeDate:[NSDate dateWithTimeIntervalSinceNow:10]
                                                              title:@"Finishing"
                                                            message:@"Got some last minute things to finish up here..."
                                                        buttonTitle:@"Quit Now"
                                                  completionHandler:^(BOOL allTasksEnded) {
                                                      // tell the app we're done now and allow it to quit
                                                      [NSApp replyToApplicationShouldTerminate:YES];
                                                  }
     ];
    
    // tell the OS that we'll quit when we are good and ready!
    return NSTerminateLater;
}

 */
- (void)runBackgroundTasksBeforeDate:(NSDate *)timeoutDate
                               title:(NSString *)title
                             message:(NSString *)message
                         buttonTitle:(NSString *)buttonTitle
                   completionHandler:(void (^)(BOOL allTasksEnded))completionHandler;
@end
