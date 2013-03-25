//
//  MainViewController.m
//
#import "MainViewController.h"
#import "TiggziURLProtocol.h"

@interface MainViewController ()

@property (nonatomic, assign) BOOL initializeCompleted;
@property (nonatomic, retain) NSURLRequest *delayedRequest;

/**
 * Register TiggziURLProtocol to configure server trust authentication chalenge
 *     for allow or reject self-signed certificates.
 * This method should be invoked after [CDVViewController viewDidLoad] method
 *     to place TiggziURLProtocol behind CDVURLProtocol.
 */
- (void)registerCustomURLProtocol;
- (void)unregisterCustomURLProtocol;

@end

@implementation MainViewController

@synthesize initializeCompleted, delayedRequest;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.initializeCompleted = NO;
        self.delayedRequest = nil;
    }
    return self;
}

- (void)dealloc
{
    [self unregisterCustomURLProtocol];
    self.delayedRequest = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerCustomURLProtocol];
    self.initializeCompleted = YES;
    if(nil != self.delayedRequest)
    {
        [self.webView loadRequest:self.delayedRequest];
        self.delayedRequest = nil;
    }
}

- (void)viewDidUnload
{
    [self unregisterCustomURLProtocol];
    [super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated
{
    self.view.frame = [[UIScreen mainScreen] applicationFrame];
    [super viewWillAppear:animated];
}

#pragma mark - UIWebViewDelegate

- (BOOL) webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    if(self.initializeCompleted)
    {
        return [super webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    self.delayedRequest = request;
    return NO;
}

#pragma mark - Utility methods
- (void)registerCustomURLProtocol {
    BOOL allowAllCertificates = [(NSNumber *)[self.settings objectForKey:@"AllowAllHTTPSCertificates"] boolValue];
    [TiggziURLProtocol registerWithWhiteList:self.whitelist allowAllCertificates:allowAllCertificates];
}

- (void)unregisterCustomURLProtocol {
    [TiggziURLProtocol unregisterClass:[TiggziURLProtocol class]];
}

@end
