//
//  WebProjectInfo.h
//
//  Created by Sergey Seroshtan on 03.07.12.
//  Copyright (c) 2012 Exadel Inc. All rights reserved.
//
//  This class provides information about web project,
//      namely it folder location, start page name, etc.
//

#import <Foundation/Foundation.h>

@interface WebProjectInfo : NSObject

/**
 * @returns - web project folder path. 
 */
- (NSString *) folderPath;

/**
 * @returns - start page name for web project
 */
- (NSString *) startPageName;

@end
