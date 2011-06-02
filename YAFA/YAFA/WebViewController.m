//
//  WebViewController.m
//  YAFA
//
//  Created by Judy Liu on 5/31/11.
//

#import "WebViewController.h"

#import "YAFAPhoto.h"

static NSString *kImageHtmlFormat = @"<html><body style='margin:0'>"
                                "<img src='%@'>"
                                "</body></html>";

@implementation WebViewController

@synthesize activityIndicator;
@synthesize loadingLabel;
@synthesize photo;
@synthesize webView;

- (id)initWithPhoto:(YAFAPhoto *)thePhoto {
    self = [super initWithNibName:@"WebViewController" bundle:nil];
    if (self) {
        self.photo = thePhoto;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    self.photo = nil;
    self.webView = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.photo.title;
    
    // add the Loading... label
	NSString *labelText = @"Loading...";
	UIFont *labelFont = [UIFont systemFontOfSize:15.0];
	CGSize labelSize = [labelText sizeWithFont:labelFont];
	self.loadingLabel = [[[UILabel alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - labelSize.width)/2, 180, labelSize.width, labelSize.height)] autorelease];
	self.loadingLabel.font = labelFont;
	self.loadingLabel.text = labelText;
	self.loadingLabel.hidden = YES;
	self.loadingLabel.backgroundColor = [UIColor clearColor];
	[self.view addSubview:self.loadingLabel];
	
	// add the activity indicator
	self.activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
	self.activityIndicator.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 20)/2, 185 + labelSize.height, 20, 20);
	self.activityIndicator.hidesWhenStopped = YES;
	self.activityIndicator.backgroundColor = [UIColor clearColor];
	[self.view addSubview:self.activityIndicator];
    
    NSString *html = [NSString stringWithFormat:kImageHtmlFormat, 
                      [photo photoUrlForSize:YAFAPhotoSizeMedium]];
    
    [self.webView loadHTMLString:html baseURL:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.webView stopLoading];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    self.webView = nil;
    self.activityIndicator = nil;
    self.loadingLabel = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	self.loadingLabel.hidden = NO;
	[self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {	
	self.loadingLabel.hidden = YES;
	[self.activityIndicator stopAnimating];
}

@end
