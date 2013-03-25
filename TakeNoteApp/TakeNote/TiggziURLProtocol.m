//
//  TiggziURLProtocol.m
//
//  Created by Sergey Seroshtan on 16.11.12.
//
//

#import "TiggziURLProtocol.h"

static CDVWhitelist *gWhiteList = nil;
static BOOL gAllowAllCertificates = NO;

@interface TiggziURLProtocol ()
@property (retain) NSURLRequest *request;
@property (retain) NSURLRequest *initialRequest;
@property (retain) NSURLConnection *connection;
@end

@implementation TiggziURLProtocol

@synthesize connection = _connection;
@synthesize request = _request;
@synthesize initialRequest = _initialRequest;

+ (void)registerWithWhiteList:(CDVWhitelist *)whiteList allowAllCertificates:(BOOL)allowAllCertificates
{
    gWhiteList = whiteList;
    gAllowAllCertificates = allowAllCertificates;
    [self registerClass: self];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)theRequest
{
    NSString *scheme = theRequest.URL.scheme;
    NSString *header = [theRequest valueForHTTPHeaderField:@"X-PHONEGAP-AUTHPROTOCOL"];
    if([scheme isEqualToString:@"https"] && header == nil)
    {
        return ((![self whiteListAllowsRequest:theRequest]) || gAllowAllCertificates);
    }
    
    return NO;
}

+ (BOOL)whiteListAllowsRequest:(NSURLRequest *)candidate
{
    NSURL* theUrl = [candidate URL];
    NSString* theScheme = [theUrl scheme];
    
    if(gWhiteList == nil)
    {
        // If there is no any hosts - deny all requests!
        return NO;
    }
    
	if ([gWhiteList schemeIsAllowed:theScheme])
    {
        return [gWhiteList URLIsAllowed:theUrl];
    }
    else
    {
        // The scheme is not interesting (not http(s) and not ftp(s)).
        // Allow the request.
        return YES;
    }
}

/**
 * Initialize the URL protocol instance to serve given request on behalf of given protocol client.
 */
-(id)initWithRequest:(NSURLRequest *)request
      cachedResponse:(NSCachedURLResponse *)cachedResponse
              client:(id <NSURLProtocolClient>)client
{
    NSLog(@"URL: %@", request.URL);
    NSMutableURLRequest *myRequest = [[request mutableCopy] autorelease];
    [myRequest setValue:@"true" forHTTPHeaderField:@"X-PHONEGAP-AUTHPROTOCOL"];
    
    // Pass instance initialization downstairs with modified request
    self = [super initWithRequest:myRequest cachedResponse:cachedResponse client:client];
    if( self != nil )
    {
        [self.class setProperty:_initialRequest forKey:@"initialRequest" inRequest:myRequest];
        [self setRequest:myRequest];
    }
    
    return self;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)startLoading
{
    if(nil != self.connection)
    {
        return;
    }
    
    if([[self class] whiteListAllowsRequest:[self request]])
    {
        // use the regular URL donwload machinery to get the url contents
        self.connection = [NSURLConnection connectionWithRequest:[self request]
                                                        delegate:self];
    }
    else
    {
        // Fail the request which is not allowed by white list.
        NSURL *url = [[self request] URL];
        NSString *body = [gWhiteList errorStringForURL:url];

        NSHTTPURLResponse* response = [[NSHTTPURLResponse alloc] initWithURL:url MIMEType:@"text/plain" expectedContentLength:-1 textEncodingName:@"UTF-8"];
        [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [[self client] URLProtocol:self didLoadData:[body dataUsingEncoding:NSASCIIStringEncoding]];
        [[self client] URLProtocolDidFinishLoading:self];
        [response release];
    }
}

- (void)stopLoading
{
    [_connection cancel];
    self.connection = nil;
}


- (void)dealloc
{
    [self.connection cancel];
    self.connection = nil;
    
    self.request = nil;
    self.initialRequest = nil;
    
    [super dealloc];
}

#pragma mark - NSURLConnectionDelegate implementation

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [[self client] URLProtocol:self didLoadData:data];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
        willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return cachedResponse;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request
        redirectResponse:(NSURLResponse *)response
{
    if(response)
    {
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
    return request;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.connection = nil;
    [[self client] URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [_connection cancel];
    self.connection = nil;
    [[self client] URLProtocol:self didFailWithError:error];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    return YES;
}

- (void)connection:(NSURLConnection *)connection
        didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if(NSURLAuthenticationMethodServerTrust == [[challenge protectionSpace] authenticationMethod])
    {
        if(gAllowAllCertificates)
        {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
        }
    }
    else
    {
        [[self client] URLProtocol:self didReceiveAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection
        willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if(NSURLAuthenticationMethodServerTrust == [[challenge protectionSpace] authenticationMethod])
    {
        if(gAllowAllCertificates)
        {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
        }
    }
    else
    {
        [[self client] URLProtocol:self didReceiveAuthenticationChallenge:challenge];
    }
}

-(void)connection:(NSURLConnection*)connection
        didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [[self client] URLProtocol:self didCancelAuthenticationChallenge:challenge];
}
@end
