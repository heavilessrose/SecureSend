//
//  ContainerDetailViewController.m
//  bac_01
//
//  Created by Christoph Hechenblaikner on 22.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Crypto.h"
#import "ContainerDetailViewController.h"
#import "SecureContainer.h"
#import "SourceSelectionViewController.h"
#import "AppDelegate.h"
#import "FilePathFactory.h"
#import "NameCell.h"
#import "ZipArchive.h"
#import "KeyChainManager.h"
#import "CertificateXplorerViewController.h"
#import "LoadingView.h"


@interface ContainerDetailViewController() {
@private
    NSInteger rowAddFile;
}

@property (nonatomic, retain) UIPopoverController *popoverController;
@end

@implementation ContainerDetailViewController

#define SECTION_NAME 0
#define SECTION_ACTION 2
#define SECTION_FILES 1
#define NUMBER_ROWS_INFOS 1
#define NUMBER_SECTIONS 3
#define NUMBER_ROWS_ACTION 1
#define ROW_SEND_CONTAINER 0
#define ROW_NAME 0



#define SEGUE_TO_SOURCESEL @"toSourceSelectionViewController"
#define SEGUE_TO_XPLORER @"toCertificateXplorer"
#define SEGUE_TO_PREVIEW @"toPreviewImageScreen"
#define SEGUE_TO_SOURCESELVIEW @"toSourceSelectionView"
#define SEGUE_TO_ENCRYPT @"toEncryptAndSend"


@synthesize navigationBar = _navigationBar;
@synthesize addFileButton = _addFileButton;
@synthesize container, currentCertificate = _currentCertificate;
@synthesize show = _show;
@synthesize popoverController=_myPopoverController;



- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"linenbg.png"]];
    CGRect background_frame = self.tableView.frame;
    background_frame.origin.x = 0;
    background_frame.origin.y = 0;
    background.frame = background_frame;
    background.contentMode = UIViewContentModeTop;
    self.tableView.backgroundView = background;
}

- (void)viewDidUnload
{
    [self setAddFileButton:nil];
    [self setNavigationBar:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view setNeedsLayout];
    [self.view setNeedsDisplay];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
    if ( gesture.state == UIGestureRecognizerStateBegan ) 
    {
        if ([self.tableView isEditing])
        {
            [self.tableView setEditing:NO animated:YES];
        }
        else
        {
            [self.tableView setEditing:YES animated:YES];
        }
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUMBER_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(section == SECTION_FILES)
    {
        rowAddFile = [self.container.fileUrls count];
        return rowAddFile + 1;
    }
    else if(section == SECTION_ACTION)
        return NUMBER_ROWS_ACTION;
    
    else if(section == SECTION_NAME)
        return NUMBER_ROWS_INFOS;
    else
        return [self.container.fileUrls count];
    
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == SECTION_NAME)
    {
        if(indexPath.row == ROW_NAME)
        {
            NameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NameCell"];
            
            cell.nameField.text = self.container.name;
            
            return cell;
        }
    }
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    if(indexPath.section == SECTION_FILES)
    {
        if(indexPath.row == rowAddFile)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"Add file";
        }
        else
        {
            NSString* path = [container.fileUrls objectAtIndex:indexPath.row];
            cell.textLabel.text = [path lastPathComponent];
            if([[path pathExtension] isEqualToString:EXTENSION_JPG] || [[path pathExtension] isEqualToString:EXTENSION_PDF])
            {
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else 
            {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    else if(indexPath.section == SECTION_ACTION)
    {
        if(indexPath.row == ROW_SEND_CONTAINER)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"Encrypt / Share container";
        }
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    if(section == SECTION_ACTION)
        return @"Actions";
    else if(section == SECTION_FILES)
        return @"Files";
    else if(section == SECTION_NAME)
        return @"Name";
    else
        return @"ERROR";
    
    return @"Files in Container";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == SECTION_ACTION)
    {
        if(indexPath.row == ROW_SEND_CONTAINER)
        {
            [self performSegueWithIdentifier:SEGUE_TO_XPLORER sender:nil];
        }
    }
    else if(indexPath.section == SECTION_FILES || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if(indexPath.row == rowAddFile && !(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
        {
            [self addFile];
        }
        else 
        {
            NSString* path = [self.container.fileUrls objectAtIndex:indexPath.row];
            
            NSString* pathextension = [path pathExtension];
            if([pathextension isEqualToString:EXTENSION_JPG] || [pathextension isEqualToString:EXTENSION_PDF])
            {
                /*if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                {
                    SplitViewController* split = (SplitViewController*) self.splitViewController;
                    PreviewViewController* preview = split.preview;
                    preview.path = [container.fileUrls objectAtIndex:indexPath.row];
                    [preview refreshPreview];
                }
                else 
                {*/
                    [self performSegueWithIdentifier:SEGUE_TO_PREVIEW sender:path];
                //}
                
            }
            
        }
        
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == SECTION_FILES && indexPath.row != rowAddFile)
        return YES;
    
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSError * error;
    if([[NSFileManager defaultManager] removeItemAtPath:[self.container.fileUrls objectAtIndex:indexPath.row] error:&error] == NO)
    {
        NSLog(@"Problem deleting file");
        
        //TODO error description
    }
    
    [self.container.fileUrls removeObjectAtIndex:indexPath.row];
    
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *hView = [[UIView alloc] initWithFrame:CGRectZero];
    hView.backgroundColor=[UIColor clearColor];
    
    UILabel *hLabel=[[UILabel alloc] initWithFrame:CGRectMake(19,10,301,21)];
    
    hLabel.backgroundColor=[UIColor clearColor];
    hLabel.shadowColor = [UIColor blackColor];
    hLabel.shadowOffset = CGSizeMake(0.5,1);
    hLabel.textColor = [UIColor whiteColor];
    hLabel.font = [UIFont boldSystemFontOfSize:17];
    hLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    [hView addSubview:hLabel];
        
    return hView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //creating new path
    NSString* newpath = [[FilePathFactory applicationDocumentsDirectory] stringByAppendingPathComponent:textField.text];
    
    //check if the filename is allready present, checking if name is not an emtpy string
    if([[NSFileManager defaultManager] fileExistsAtPath:newpath] == YES && ![self.container.name isEqualToString:textField.text])
    {
        UIAlertView* alert;
        
        if([textField.text isEqualToString:@""])
        {
            alert = [[UIAlertView alloc] initWithTitle:@"Enter a name" message:@"Please enter a name for the container" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        }
        else {
            alert = [[UIAlertView alloc] initWithTitle:@"Container allready exists" message:@"There seems to exist another container with the same namne, please choose a different one" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        }
        
        [alert show];
        
        textField.text = self.container.name;
        
    }
    else if([self.container.name isEqualToString:textField.text] == NO)
    {
        //assigning container properties and renamind directory
        self.container.name = textField.text;
        
        NSError* err = 0;
        [[NSFileManager defaultManager] moveItemAtPath:self.container.basePath toPath:newpath error:&err];
        if(err != 0)
        {
            NSLog(@"Problem renaming container directory!!");
        }
        
        self.container.basePath = newpath;
        
        //changing paths of the existing files
        NSMutableArray* newfileurls = [[NSMutableArray alloc] init];
        
        for(NSString __strong *file in self.container.fileUrls)
        {
            file = [self.container.basePath stringByAppendingPathComponent:[file lastPathComponent]];
            [newfileurls addObject:file];
        }
        
        self.container.fileUrls = newfileurls;
    }
    
    [textField endEditing:YES];
    return YES;
}

#pragma mark - ModifyContainerPropertyDelegate methods

-(void) addFilesToContainer:(NSArray*) filePaths
{
    [self.container.fileUrls addObjectsFromArray:filePaths];
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_FILES] withRowAnimation:UITableViewRowAnimationRight];
    //todo! didn't work after refactoring of iPad UI
    
    [self.popoverController dismissPopoverAnimated:YES];
    
    [self.tableView reloadData]; 
}

-(IBAction)addFile
{
    [self performSegueWithIdentifier:SEGUE_TO_SOURCESEL sender:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    //TODO cover errors
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - ModifyCertPropertyDelegate methods

-(void) setCert: (NSData*) cert
{
    self.currentCertificate = cert;
    
    [self dismissModalViewControllerAnimated:YES];
    
    
    UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:@"Choose action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share via Dropbox",@"Send Container via Mail", nil];
    
    [action showInView:self.view];
    
}

#pragma mark - methods for sharing container

-(void) sendContainerMail: (NSData*) data
{
    
    //creating and initialising mail composer
    MFMailComposeViewController* mailcontroller = [[MFMailComposeViewController alloc] init];
    [mailcontroller setSubject:@"Container"];
    [mailcontroller setTitle:@"Secure files via container"];
    mailcontroller.mailComposeDelegate = self;
    
    
    //attaching encrypted file to mail
    NSString* filename = [self.container.name stringByAppendingPathExtension:@"iaikcontainer"];
    
    [mailcontroller addAttachmentData:data mimeType:@"application/iaikencryption" fileName:filename];
    
    [self presentModalViewController:mailcontroller animated:YES];
}


#pragma mark - methods for encrypting/zipping containers

-(NSData*) zipAndEncryptContainer
{    
    
    //Creating zipper for compressing data
    ZipArchive* zipper = [[ZipArchive alloc] init];
    
    NSString* zippath = [FilePathFactory getTemporaryZipPath];
    
    //creating zip-file at documents-directory
    bool success = [zipper CreateZipFile2:zippath];
    
    if(success == NO)
    {
        NSLog(@"Could not create zip-file!!");
    }
    
    BOOL goodfolder = [zipper addFileToZip:self.container.basePath newname:[[self.container.basePath lastPathComponent] stringByAppendingPathExtension:DIRECTORY_EXTENSION]];
    
    if(goodfolder == NO)
    {
        NSLog(@"Could not add folder to zip!!");
    }
    
    
    //adding files of container to zip
    for(NSString* path in self.container.fileUrls)
    {
        BOOL good = [zipper addFileToZip:path newname:[path lastPathComponent]];
        if(good == NO)
        {
            NSLog(@"Could not add file to zip!!");
        }
    }
    
    //closing zip
    [zipper CloseZipFile2];
    
    //getting zipped data
    NSData* zippeddata = [NSData dataWithContentsOfFile:zippath];
    
    //deleting zip-file
    if([[NSFileManager defaultManager] 	fileExistsAtPath:[FilePathFactory getTemporaryZipPath]])
    {
        
        NSError* removeerror;
        bool really = [[NSFileManager defaultManager] removeItemAtPath:zippath error:&removeerror];
        
        if(really == NO)
        {
            NSLog(@"Error deleting zip-file %@",[removeerror userInfo]);
        }
    }
    
    NSArray* contents_after = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[FilePathFactory applicationDocumentsDirectory] error:nil];
    
    NSLog(@"currrent contents after deletion of zip-file: %@",contents_after.description);
    
    NSData* encryptedContainer = [[Crypto getInstance] encryptBinaryFile:zippeddata withCertificate:self.currentCertificate];
    
    return encryptedContainer;
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    
    self.currentCertificate = nil;
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSData* encryptedcontainer = [self zipAndEncryptContainer];
    switch (buttonIndex) {
        case 1:
        {
            if([MFMailComposeViewController canSendMail])
            {
                [self sendContainerMail:encryptedcontainer];
            }
            else 
            {
                NSLog(@"cannot send mail");    
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - segue control methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:SEGUE_TO_SOURCESEL])
    {
        SourceSelectionViewController* src = (SourceSelectionViewController*) segue.destinationViewController;
        src.basePath = self.container.basePath;
        src.delegate = self;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_XPLORER])
    {
        UINavigationController* navi = (UINavigationController*) segue.destinationViewController;
        
        CertificateXplorerViewController* xplorer = [navi.viewControllers objectAtIndex:0];
        
        xplorer.delegate = self;
    }
   /* else if([segue.identifier isEqualToString:SEGUE_TO_PREVIEW])
    {
        PreviewViewController* prev = (PreviewViewController*) segue.destinationViewController;
        NSString* path = (NSString*) sender;
        prev.path = path;
    }*/
    else if ([segue.identifier isEqualToString:SEGUE_TO_SOURCESELVIEW])
    {
        SourceSelectionViewController *destination = (SourceSelectionViewController*)segue.destinationViewController;
        destination.button = self.addFileButton;
        destination.basePath = self.container.basePath;
        destination.delegate = self;
        
        UIStoryboardPopoverSegue* popSegue = (UIStoryboardPopoverSegue*)segue;        
        self.popoverController = popSegue.popoverController;
    }
}

-(void) dealloc
{

}


#pragma mark - Splitview master detail methods
- (BOOL)splitViewController:(UISplitViewController *)svc 
   shouldHideViewController:(UIViewController *)vc 
              inOrientation:(UIInterfaceOrientation)orientation
{   
    return UIInterfaceOrientationIsPortrait(orientation);
    
    //return NO;
    
    //pre
    if (self.show == YES && UIInterfaceOrientationIsPortrait(orientation))
        return YES;
    
    return !self.show;
}

- (void)splitViewController:(UISplitViewController *)svc 
     willHideViewController:(UIViewController *)aViewController 
          withBarButtonItem:(UIBarButtonItem *)barButtonItem 
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = self.title;
   // [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)splitViewController:(UISplitViewController *)svc 
     willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
   // [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
    
    // create button
    UIButton* backButton = [UIButton buttonWithType:101]; // left-pointing shape!
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    
    // create button item -- possible because UIButton subclasses UIView!
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    
}

@end