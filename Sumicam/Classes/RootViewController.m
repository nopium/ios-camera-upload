//
//  RootViewController.m
//  Sumicam
//
//  Created by nop on 9/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "ImageViewController.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h"

// Private stuff
@interface RootViewController ()
- (void)imageFetchComplete:(ASIHTTPRequest *)request;
- (void)imageFetchFailed:(ASIHTTPRequest *)request;
- (void)presentImagePickerController:(UIImagePickerController *)imagePickerController;
- (void)uploadFailed:(ASIHTTPRequest *)theRequest;
- (void)uploadFinished:(ASIHTTPRequest *)theRequest;
@end


@implementation RootViewController

@synthesize request;
@synthesize requestForm;
@synthesize tableView;
@synthesize imagesList;


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	imagesList = [[NSMutableArray alloc] init];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
																							target:self 
																							action:@selector(addPhoto)] autorelease];	
	
	[self refreshDirContents];
	//NSArray *dirContents = [[NSFileManager defaultManager] directoryContentsAtPath:path];
	//только contentsOfDirectoryAtPath
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)refreshDirContents {
	[imagesList removeAllObjects];
	NSArray *dirContents = [[NSFileManager defaultManager] directoryContentsAtPath: [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] ];
	for (int i=0;i< [dirContents count]; i++){
//		NSLog( @"Dir contents[%d]: %@", i,  );
		[imagesList addObject:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent: [dirContents objectAtIndex:i] ]];
		
	}
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [imagesList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cell at %d", indexPath.row);
    static NSString *CellIdentifier = @"ImagesCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

	// Configure the cell.
	NSLog(@"cell image: %@", [imagesList objectAtIndex:indexPath.row] );
	//cell.textLabel.text=[imagesList objectAtIndex:indexPath.row];
	UIImage *img = [UIImage imageWithContentsOfFile:[imagesList objectAtIndex:indexPath.row]];
	
	if (img) {
		//cell.textLabel.text = @"test";
		cell.imageView.image = img;
		NSLog(@"cell image: %@", img );
	}

    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view Select Item

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	/**
	 * UIViewController* vc = nil;
	 */
	UIImage *detailImage = [UIImage imageWithContentsOfFile:[imagesList objectAtIndex:indexPath.row]];
	NSLog(@"selected: %@ : %@", detailImage, [imagesList objectAtIndex:indexPath.row]);
	ImageViewController *imageViewController = [[ImageViewController alloc] initWithNibName:@"ImageViewController" bundle:nil];
	
	self.navigationItem.backBarButtonItem =[[[UIBarButtonItem alloc] initWithTitle:@"Back" style: UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
	[self.navigationController pushViewController:imageViewController animated:YES];
	imageViewController.selectedImageView.image = detailImage;
	
	[imageViewController setTitle: @"View Image" ];
	//[imageViewController ];
	// Pass the selected object to the new view controller.
	
	[imageViewController release];
}

#pragma mark -
#pragma mark simpleURLFetch
// Runs a request synchronously
- (IBAction)simpleURLFetch:(id)sender
//-(void)simpleUrlFetch
{
	NSURL *url = [NSURL URLWithString:@"http://www.sumilux.com/mia/?a=fetchImageListJSON"];//[urlField text]
	NSLog(@"<<<simpleURLFetch>>>");
	// Create a request
	// You don't normally need to retain a synchronous request, but we need to in this case because we'll need it later if we reload the table data
	[self setRequest:[ASIHTTPRequest requestWithURL:url]];
		NSLog(@">>>simpleURLFetch<<<");
	
	// Start the request
	[request startSynchronous];
	
	// Request has now finished
	//[[self tableView] reloadData];
	NSError *error = [request error];
	if (!error) {
		NSString *response = [request responseString];
		NSLog(@"%@",[request responseString]);
		// Create a dictionary from the JSON string
		NSDictionary *results = [response JSONValue];
		
		if (!networkQueue) {
			networkQueue = [[ASINetworkQueue alloc] init];	
		}
		failed = NO;
		[networkQueue reset];
		[networkQueue setRequestDidFinishSelector:@selector(imageFetchComplete:)];
		[networkQueue setRequestDidFailSelector:@selector(imageFetchFailed:)];
		[networkQueue setDelegate:self];
		ASIHTTPRequest *request;
		
		for (NSDictionary *file in results)
		{
			// Get name and url of the image
			NSString *fileName = [file objectForKey:@"fileName"];
			NSString *fileURL = [[file objectForKey:@"fileURL"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			//NSLog(@"fileURL: %@", fileURL);
			
			request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString: fileURL ]];
			[request setDownloadDestinationPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent: fileName ]];
			
			//[request setUserInfo:[NSDictionary dictionaryWithObject:@"request1" forKey:@"name"]];
			[networkQueue addOperation:request];
			//NSLog(@"added %@", fileURL);
		}
		[networkQueue go];
		//NSLog(@"networkQueue go");
	}
}

- (void)imageFetchComplete:(ASIHTTPRequest *)request
{
	//[imagesList addObject: [request downloadDestinationPath]];
	[self refreshDirContents];
	NSLog(@"imageFetchComplete: %d %@", [imagesList count], [request downloadDestinationPath] );
	[tableView reloadData];
	
}

- (void)imageFetchFailed:(ASIHTTPRequest *)request
{
	if (!failed) {
		if ([[request error] domain] != NetworkRequestErrorDomain || [[request error] code] != ASIRequestCancelledErrorType) {
			UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Download failed" message:@"Failed to download images" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
			[alertView show];
		}
		failed = YES;
	}
}

#pragma mark -
#pragma mark Camera
-(void) addPhoto
{
	projectAddActionsCameraButton = INT_MAX;
	projectAddActionsAlbumsButton = INT_MAX;
	
	projectAddActions = [[UIActionSheet alloc] initWithTitle:nil 
													delegate:self 
										   cancelButtonTitle:nil
									  destructiveButtonTitle:nil 
										   otherButtonTitles:nil];
	if ( [ UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] ){
		projectAddActionsCameraButton = [projectAddActions addButtonWithTitle:@"Camera"];
	}
	if ( [ UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary] ){
		projectAddActionsAlbumsButton = [projectAddActions addButtonWithTitle:@"Albums"];
	}
	projectAddActions.cancelButtonIndex = [projectAddActions addButtonWithTitle:@"Cancel"];
	
	[projectAddActions showInView:self.view];
	
	/*
	//UIImagePickerController *imagePickerController;
	imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.delegate = self;
	
	imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	
	
	[self presentImagePickerController:imagePickerController];
	[imagePickerController release];	
	*/
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ( actionSheet == projectAddActions ){
		if (projectAddActionsCameraButton == buttonIndex || projectAddActionsAlbumsButton == buttonIndex) 
		{
			imagePickerController = [[UIImagePickerController alloc] init];
			imagePickerController.delegate = self;
			
			if (projectAddActionsCameraButton == buttonIndex) {
				imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
			} else {
				imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			}
			
			[self presentImagePickerController:imagePickerController];
			[imagePickerController release];	
			
		}
		[projectAddActions release];
		projectAddActions = nil;
	}
	
}

- (void)presentImagePickerController:(UIImagePickerController *)imagePickerController {
		[self presentModalViewController:imagePickerController animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *choosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	NSLog(@"chosenImage: %@", choosenImage);
	choosenImage = [choosenImage imageByScalingAndCroppingForSize:CGSizeMake(320, 480)];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
	
	NSLog(@"Date: ", [dateFormatter stringFromDate:[NSDate date]]);

	NSString *fileName = [[[[[NSString stringWithFormat:@"photo-%@.jpg", [dateFormatter stringFromDate:[NSDate date]]] stringByReplacingOccurrencesOfString:@" " withString:@"_"] stringByReplacingOccurrencesOfString:@":" withString:@""] stringByReplacingOccurrencesOfString:@"/" withString:@""] stringByReplacingOccurrencesOfString:@"+" withString:@""];
	NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent: fileName ];
	[dateFormatter release];

	NSData *imageData = UIImageJPEGRepresentation(choosenImage, 0.9);
	[imageData writeToFile:filePath atomically:NO];
	NSLog(@"Saved to %@", filePath);
	//[imagesList addObject:filePath];

	NSString *url = @"http://www.sumilux.com/mia/?a=doUpload";
	ASIFormDataRequest *requestForm = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
	[requestForm setTimeOutSeconds:30];

	[requestForm setFile:filePath forKey:@"file"];
	[requestForm setDelegate:self];
	[requestForm setDidFailSelector:@selector(uploadFailed:)];
	[requestForm setDidFinishSelector:@selector(uploadFinished:)];
	NSLog(@"starting upload....");
	[requestForm startAsynchronous];
	
	//[tableView reloadData];
	//[picker dismissModalViewControllerAnimated:YES];

}

- (void)uploadFailed:(ASIHTTPRequest *)theRequest
{
	
	NSLog(@"Upload failed: %@",[[theRequest error] localizedDescription]);
	[imagePickerController dismissModalViewControllerAnimated:YES];

}

- (void)uploadFinished:(ASIHTTPRequest *)theRequest
{
	NSLog(@"Upload finished! %llu bytes of data",[theRequest postLength]);
	
	[imagePickerController dismissModalViewControllerAnimated:YES];
	[self refreshDirContents];
	[tableView reloadData];
}


-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[imagesList release]; imagesList = nil;
}


- (void)dealloc {
	[networkQueue reset];
	[networkQueue release];
	[tableView release];
	[imagesList release];

	[request clearDelegatesAndCancel];
	[request release];

	[requestForm clearDelegatesAndCancel];
    [requestForm release];

    [super dealloc];
}

@end

@implementation UIImage (Extras) 
#pragma mark -
#pragma mark Scale and crop image

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
	UIImage *sourceImage = self;
	UIImage *newImage = nil;        
	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	if (CGSizeEqualToSize(imageSize, targetSize) == NO) 
	{
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
		
        if (widthFactor > heightFactor) 
			scaleFactor = widthFactor; // scale to fit height
        else
			scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
		
        // center the image
        if (widthFactor > heightFactor)
		{
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
		}
        else 
			if (widthFactor < heightFactor)
			{
				thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
			}
	}       
	
	UIGraphicsBeginImageContext(targetSize); // this will crop
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
	[sourceImage drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	if(newImage == nil) 
        NSLog(@"could not scale image");
	
	//pop the context to get back to the default
	UIGraphicsEndImageContext();
	return newImage;
}
@end
