//
//  ContainerDetailViewController.h
//  bac_01
//
//  Created by Christoph Hechenblaikner on 22.02.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import <DropboxSDK/DropboxSDK.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ModifyCertPropertyDelegate.h"
#import "ModifyContainerPropertyDelegate.h"
#import "MWPhotoBrowser.h"


@class SecureContainer, NameCell;
@class SourceSelectionViewController;

@interface ContainerDetailViewController : UITableViewController <ModifyContainerPropertyDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, ModifyCertPropertyDelegate, UIPopoverControllerDelegate, MWPhotoBrowserDelegate, DBRestClientDelegate, UIDocumentInteractionControllerDelegate>


@property (nonatomic, strong) SecureContainer* container;
@property (nonatomic, strong) NSData* currentCertificate;
@property (nonatomic, retain) NSArray *photos;
@property (nonatomic, assign) BOOL shouldRotateToPortrait;
@property (nonatomic, strong) NSString *recipientMail;
@property (nonatomic, assign) BOOL isQuickForward;

- (void)setCert:(NSData*)cert;
- (void)setRecipientMail:(NSString *)recipientMail;
- (IBAction)addFile;
- (NSData*)zipAndEncryptContainer;

@end
