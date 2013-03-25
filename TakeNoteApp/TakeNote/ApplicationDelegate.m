//
//  ApplicationDelegate.m
//
//  Created by Pavel Gorb on 8/18/11.
//  Copyright Exadel Inc. 2011. All rights reserved.
//

#import "ApplicationDelegate.h"
#import "MainViewController.h"

#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVURLProtocol.h>

#import "PushNotification.h"

#import "WebProjectInfo.h"

@implementation ApplicationDelegate

@synthesize invokeString, window, viewController;

- (id) init
{	
	/** If you need to do any extra app-specific initialization, you can do it here
	 *  -jm
	 **/
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage]; 
    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    return [super init];
}


#pragma UIApplicationDelegate implementation

/**
 * This is main kick off after the app inits, the views and Settings are setup here. (preferred - iOS4 and up)
 */
- (BOOL) application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{    
    NSURL* url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if (url && [url isKindOfClass:[NSURL class]]) {
        self.invokeString = [url absoluteString];
		NSLog(@"Application launchOptions = %@",url);
    }    
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.window = [[[UIWindow alloc] initWithFrame:screenBounds] autorelease];
    self.window.autoresizesSubviews = YES;
    
    self.viewController = [[[MainViewController alloc] init] autorelease];
    self.viewController.useSplashScreen = YES;
    
    // Retreive information about web project.
    WebProjectInfo *webProjectInfo = [[WebProjectInfo alloc] init];

    self.viewController.wwwFolderName = [webProjectInfo folderPath];
    NSLog(@"ProjectFolder: %@",self.viewController.wwwFolderName);
    
    self.viewController.startPage = [webProjectInfo startPageName];
    NSLog(@"StartPage: %@", self.viewController.startPage);
    
    [webProjectInfo release];
    
    // over-ride delegates
    self.viewController.webView.delegate = self;
    
    // check whether the current orientation is supported: if it is, keep it, rather than forcing a rotation
    UIDeviceOrientation curDevOrientation = [[UIDevice currentDevice] orientation];
    
    if (UIDeviceOrientationUnknown == curDevOrientation) {
        // UIDevice isn't firing orientation notifications yet… go look at the status bar
        curDevOrientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    }

    BOOL forceStartupRotation = ![self.viewController supportsOrientation: curDevOrientation];
    if (forceStartupRotation) {
        // The first item in the supportedOrientations array is the start orientation (guaranteed to be at least Portrait)
        UIInterfaceOrientation newOrient = UIInterfaceOrientationPortrait;
        NSLog(@"AppDelegate forcing status bar to: %d from: %d", newOrient, curDevOrientation);
        [[UIApplication sharedApplication] setStatusBarOrientation:newOrient];
    }
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    // PushNotification - Handle launch from a push notification
    NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(userInfo) {
        PushNotification *pushHandler = [self.viewController getCommandInstance:@"PushNotification"];
        NSMutableDictionary* mutableUserInfo = [userInfo mutableCopy];
        [mutableUserInfo setValue:@"1" forKey:@"applicationLaunchNotification"];
        [mutableUserInfo setValue:@"0" forKey:@"applicationStateActive"];
        [pushHandler.pendingNotifications addObject:mutableUserInfo];
        [mutableUserInfo release];
    }
    
    return YES;
}


// this happens while we are running ( in the background, or from within our own app )
// only valid if FooBar.plist specifies a protocol to handle
- (BOOL) application:(UIApplication*)application handleOpenURL:(NSURL*)url 
{
    if (!url) { 
        return NO; 
    }
    
	// calls into javascript global function 'handleOpenURL'
    NSString* jsString = [NSString stringWithFormat:@"handleOpenURL(\"%@\");", url];
    [self.viewController.webView stringByEvaluatingJavaScriptFromString:jsString];
    
    // all plugins will get the notification, and their handlers will be called 
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification object:url]];
    
    return YES;    
}

#pragma UIWebDelegate implementation

- (void) webViewDidFinishLoad:(UIWebView*) theWebView 
{
	// only valid if FooBar.plist specifies a protocol to handle
	if (self.invokeString)
	{
		// this is passed before the deviceready event is fired, so you can access it in js when you receive deviceready
		NSString* jsString = [NSString stringWithFormat:@"var invokeString = \"%@\";", self.invokeString];
		[theWebView stringByEvaluatingJavaScriptFromString:jsString];
	}
	
    // Black base color for background matches the native apps
   	theWebView.backgroundColor = [UIColor blackColor];
    
	return [self.viewController webViewDidFinishLoad:theWebView];
}

- (void) webViewDidStartLoad:(UIWebView*)theWebView 
{
	return [self.viewController webViewDidStartLoad:theWebView];
}

- (void) webView:(UIWebView*)theWebView didFailLoadWithError:(NSError*)error 
{
	return [self.viewController webView:theWebView didFailLoadWithError:error];
}

- (BOOL) webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
	return [self.viewController webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType];
}

#pragma PushNotification delegation

- (void)application:(UIApplication*)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    PushNotification* pushHandler = [self.viewController getCommandInstance:@"PushNotification"];
    [pushHandler didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication*)app didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    PushNotification* pushHandler = [self.viewController getCommandInstance:@"PushNotification"];
    [pushHandler didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    PushNotification* pushHandler = [self.viewController getCommandInstance:@"PushNotification"];
    NSMutableDictionary* mutableUserInfo = [userInfo mutableCopy];
    
    // Get application state for iOS4.x+ devices, otherwise assume active
    UIApplicationState appState = UIApplicationStateActive;
    if ([application respondsToSelector:@selector(applicationState)]) {
        appState = application.applicationState;
    }
    
    [mutableUserInfo setValue:@"0" forKey:@"applicationLaunchNotification"];
    if (appState == UIApplicationStateActive) {
        [mutableUserInfo setValue:@"1" forKey:@"applicationStateActive"];
        [pushHandler didReceiveRemoteNotification:mutableUserInfo];
    } else {
        [mutableUserInfo setValue:@"0" forKey:@"applicationStateActive"];
        [mutableUserInfo setValue:[NSNumber numberWithDouble: [[NSDate date] timeIntervalSince1970]] forKey:@"timestamp"];
        [pushHandler.pendingNotifications addObject:mutableUserInfo];
    }
    [mutableUserInfo release];
}

- (void)dealloc
{
	[ super dealloc ];
}

@end
