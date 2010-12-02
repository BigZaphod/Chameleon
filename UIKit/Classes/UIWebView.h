//  Created by Sean Heber on 6/25/10.
#import "UIView.h"
#import "UIDataDetectors.h"

enum {
	UIWebViewNavigationTypeLinkClicked,
	UIWebViewNavigationTypeFormSubmitted,
	UIWebViewNavigationTypeBackForward,
	UIWebViewNavigationTypeReload,
	UIWebViewNavigationTypeFormResubmitted,
	UIWebViewNavigationTypeOther
};
typedef NSUInteger UIWebViewNavigationType;

@class UIWebView, UIViewAdapter, WebView;

@protocol UIWebViewDelegate <NSObject>
@optional
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error;
@end

@interface UIWebView : UIView {
@private
	id _delegate;
	NSURLRequest *_request;
	UIDataDetectorTypes _dataDetectorTypes;
	WebView *_webView;
	UIViewAdapter *_webViewAdapter;
	
	struct {
		BOOL shouldStartLoadWithRequest : 1;
		BOOL didFailLoadWithError : 1;
	} _delegateHas;
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;
- (void)loadRequest:(NSURLRequest *)request;
- (void)stopLoading;
- (void)reload;
- (void)goBack;
- (void)goForward;

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;

@property (nonatomic, assign) id<UIWebViewDelegate> delegate;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;
@property (nonatomic, readonly, getter=canGoBack) BOOL canGoBack;
@property (nonatomic, readonly, getter=canGoForward) BOOL canGoForward;
@property (nonatomic, readonly, retain) NSURLRequest *request;
@property (nonatomic) UIDataDetectorTypes dataDetectorTypes;

@end
