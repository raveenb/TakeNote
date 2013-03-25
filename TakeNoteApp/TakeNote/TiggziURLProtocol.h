//
//  TiggziURLProtocol.h
//
//  Created by Sergey Seroshtan on 16.11.12.
//
//

#import <Cordova/CDVWhitelist.h>

/**
 * This protocol is used to configure accepting connections from the self-signed servers.
 */
@interface TiggziURLProtocol : NSURLProtocol

/**
 * Register and configure URL protocol for Tiggzi purposes,
 *     which allow/deny to accept connection from the servers with self-signed certificates.
 */
+ (void)registerWithWhiteList:(CDVWhitelist *)whiteList allowAllCertificates:(BOOL)allowAllCertificates;
@end
