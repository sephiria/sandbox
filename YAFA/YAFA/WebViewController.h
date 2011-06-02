//
//  WebViewController.h
//  YAFA
//
//  Created by Judy Liu on 5/31/11.
//

#import <UIKit/UIKit.h>

@class YAFAPhoto;

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) YAFAPhoto *photo;
@property (nonatomic, assign) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) UILabel *loadingLabel;

- (id)initWithPhoto:(YAFAPhoto *)thePhoto;

@end
