//  Created by Sean Heber on 6/25/10.
#import "UIWebView.h"

@implementation UIWebView
@synthesize loading=_loading, canGoBack=_canGoBack, canGoForward=_canGoForward, request=_request, delegate=_delegate, dataDetectorTypes=_dataDetectorTypes;

- (void)setDelegate:(id<UIWebViewDelegate>)newDelegate
{
	_delegate = newDelegate;
	_delegateHas.shouldStartLoadWithRequest = [_delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)];
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
}

- (void)loadRequest:(NSURLRequest *)request
{
}

- (void)stopLoading
{
}

- (void)reload
{
}

- (void)goBack
{
}

- (void)goForward
{
}

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script
{
	return nil;
}

// The only reason this is here is because Flamingo currently tries a hack to get at the web view's internals UIScrollView to get
// the desk ad view to stop stealing the scrollsToTop event. Lame, yes...
- (id)valueForUndefinedKey:(NSString *)key
{
	return nil;
}

@end
