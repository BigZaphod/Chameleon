//  Created by Sean Heber on 6/25/10.
#import "UIWebView.h"
#import "UIViewAdapter.h"
#import <WebKit/WebKit.h>

@implementation UIWebView
@synthesize request=_request, delegate=_delegate, dataDetectorTypes=_dataDetectorTypes;

- (id)initWithFrame:(CGRect)frame
{
	if ((self=[super initWithFrame:frame])) {
		_webView = [(WebView *)[WebView alloc] initWithFrame:NSRectFromCGRect(self.bounds)];
		[_webView setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
		[_webView setPolicyDelegate:self];
		[_webView setFrameLoadDelegate:self];

		_webViewAdapter = [[UIViewAdapter alloc] initWithFrame:self.bounds];
		_webViewAdapter.NSView = _webView;
		
		[self addSubview:_webViewAdapter];
	}
	return self;
}

- (void)dealloc
{
	[_webViewAdapter release];
	[_webView release];
	[super dealloc];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	_webViewAdapter.frame = self.bounds;
}

- (void)setDelegate:(id<UIWebViewDelegate>)newDelegate
{
	_delegate = newDelegate;
	_delegateHas.shouldStartLoadWithRequest = [_delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)];
	_delegateHas.didFailLoadWithError = [_delegate respondsToSelector:@selector(webView:didFailLoadWithError:)];
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
	[[_webView mainFrame] loadHTMLString:string baseURL:baseURL];
}

- (void)loadRequest:(NSURLRequest *)request
{
	if (request != _request) {
		[_request release];
		_request = [request retain];
	}

	[[_webView mainFrame] loadRequest:_request];
}

- (void)stopLoading
{
	[_webView stopLoading:self];
}

- (void)reload
{
	[_webView reload:self];
}

- (void)goBack
{
	[_webView goBack];
}

- (void)goForward
{
	[_webView goForward];
}

- (BOOL)isLoading
{
	return [_webView isLoading];
}

- (BOOL)canGoBack
{
	return [_webView canGoBack];
}

- (BOOL)canGoForward
{
	return [_webView canGoForward];
}

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script
{
	return [_webView stringByEvaluatingJavaScriptFromString:script];
}

// The only reason this is here is because Flamingo currently tries a hack to get at the web view's internals UIScrollView to get
// the desk ad view to stop stealing the scrollsToTop event. Lame, yes...
- (id)valueForUndefinedKey:(NSString *)key
{
	return nil;
}

#pragma mark -
#pragma mark WebView Policy Delegate

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id < WebPolicyDecisionListener >)listener
{
	BOOL shouldStartLoad = YES;
	
	if (_delegateHas.didFailLoadWithError) {
		id navTypeObject = [actionInformation objectForKey:WebActionNavigationTypeKey];
		NSInteger navTypeCode = [navTypeObject intValue];
		UIWebViewNavigationType navType = UIWebViewNavigationTypeOther;
		
		switch (navTypeCode) {
			case WebNavigationTypeLinkClicked:		navType = UIWebViewNavigationTypeLinkClicked;		break;
			case WebNavigationTypeFormSubmitted:	navType = UIWebViewNavigationTypeFormSubmitted;		break;
			case WebNavigationTypeBackForward:		navType = UIWebViewNavigationTypeBackForward;		break;
			case WebNavigationTypeReload:			navType = UIWebViewNavigationTypeReload;			break;
			case WebNavigationTypeFormResubmitted:	navType = UIWebViewNavigationTypeFormResubmitted;	break;
		}
		
		shouldStartLoad = [_delegate webView:self shouldStartLoadWithRequest:request navigationType:navType];
	}
	
	if (shouldStartLoad) {
		[listener use];
	} else {
		[listener ignore];
	}
}

#pragma mark -
#pragma mark WebView Frame Load Delegate

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
	if (_delegateHas.didFailLoadWithError) {
		[_delegate webView:self didFailLoadWithError:error];
	}
}

@end
