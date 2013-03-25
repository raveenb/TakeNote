//
//  main.m
//
//  Created by Pavel Gorb on 9/4/11.
//  Copyright 2011 Exadel Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
        return UIApplicationMain(argc, argv, nil, @"ApplicationDelegate");
    } @catch (NSException *exception) {
        NSLog(@"%@", [exception reason]);
    } @finally {
        [pool release];
    }
}
