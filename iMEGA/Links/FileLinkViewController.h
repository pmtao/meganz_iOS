/**
 * @file FileLinkViewController.h
 * @brief View controller that allows to see and manage MEGA file links.
 *
 * (c) 2013-2015 by Mega Limited, Auckland, New Zealand
 *
 * This file is part of the MEGA SDK - Client Access Engine.
 *
 * Applications using the MEGA API must present a valid application key
 * and comply with the the rules set forth in the Terms of Service.
 *
 * The MEGA SDK is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 * @copyright Simplified (2-clause) BSD License.
 *
 * You should have received a copy of the license along with this
 * program.
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FileLinkMode) {
    FileLinkModeDefault = 0,
    FileLinkModeNodeFromFolderLink
};

@interface FileLinkViewController : UIViewController

@property (nonatomic) FileLinkMode fileLinkMode;

@property (nonatomic, strong) NSString *fileLinkString;

@property (nonatomic, strong) MEGANode *nodeFromFolderLink;

@end
