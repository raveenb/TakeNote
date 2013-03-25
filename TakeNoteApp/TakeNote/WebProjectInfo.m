//
//  WebProjectInfo.m
//
//  Created by Sergey Seroshtan on 03.07.12.
//  Copyright (c) 2012 Exadel Inc. All rights reserved.
//

#import "WebProjectInfo.h"

static NSString *const kDefaultFolderName = @"www";
static NSString *const kDefaultStartPageName = @"index.html";
static NSString *const kDescriptorFileName = @"descriptor.txt";

#pragma mark - Private interface declaration
@interface WebProjectInfo ()

/**
 * @returns - YES if item spefified by path parameter is directory;
 *          - NO otherwise.
 * @parameter path - path to tested element.
 */
- (BOOL) isDirectory: (NSString *) path error: (NSError **) error;

/**
 * Fixes start page name if it includes double encoded URL special characters.
 *      For example index%2528.html wil be fixed to index%28.html.
 */
- (NSString *) fixStartPageName: (NSString *) baseName;

@end

#pragma mark - Public interface implementation

@implementation WebProjectInfo

- (NSString *) folderPath
{
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *wwwPath = [resourcePath stringByAppendingPathComponent:kDefaultFolderName];
    
    NSError *wwwReadContentError = nil;
    NSArray *wwwContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:wwwPath error:&wwwReadContentError];
    
    if (wwwReadContentError || wwwContent == nil || [wwwContent count] <= 0)
    {
        // no files in the root web folder - assume that project will be located in the root web folder
        return kDefaultFolderName;
    }
    else
    {
        // assume that project is located in first subfolder of the root web folder
        for (NSString *itemName in wwwContent)
        {
            NSString *itemPath = [wwwPath stringByAppendingPathComponent: itemName];
            
            NSError *checkError = nil;
            BOOL itemPathIsDirectory = [self isDirectory: itemPath error: &checkError];
            if (checkError)
            {
                NSLog (@"Error was occured during read check element: %@. Details: %@.", itemPath, checkError);
            }
            else if (itemPathIsDirectory)
            {
                return [kDefaultFolderName stringByAppendingPathComponent: itemName];
            }
        }
    }
    
    // project is located in the root web folder
    return kDefaultFolderName;
}

- (NSString *) startPageName
{
    NSString *projectFolderFullPath = [[[NSBundle mainBundle] resourcePath]
                                       stringByAppendingPathComponent: [self folderPath]];
    
    NSString *descriptorPath = [projectFolderFullPath stringByAppendingPathComponent: kDescriptorFileName];
    
    NSError *readError = nil;
    NSString *startPage = [NSString stringWithContentsOfFile: descriptorPath
                                                 encoding: NSUTF8StringEncoding error: &readError];
    if (readError)
    {
        NSLog (@"Error was occured during read file: %@. Details: %@.", descriptorPath, readError);
        return kDefaultStartPageName;
    }
    else if (startPage == nil || [startPage length] <= 0)
    {
        NSLog (@"File %@ is empty but should contain web project start page name.", descriptorPath);
        return kDefaultStartPageName;
    }
    else
    {
        return [self fixStartPageName: startPage];
    }
}

#pragma mark - Private interface implementation
- (BOOL) isDirectory: (NSString *) path error: (NSError **) error
{
    NSDictionary *itemAttributes = [[NSFileManager defaultManager]
                                    attributesOfItemAtPath: path error: error];
        
    if (!*error)
    {
        return [[itemAttributes objectForKey: NSFileType] isEqualToString: NSFileTypeDirectory];
    }
    return NO;
}

- (NSString *) fixStartPageName: (NSString *) baseName
{
    if(baseName)
    {
        return [(NSString *) CFURLCreateStringByReplacingPercentEscapes
                (NULL, (CFStringRef)[[baseName mutableCopy] autorelease], CFSTR("")) autorelease];
    }
    return nil;
}

@end
