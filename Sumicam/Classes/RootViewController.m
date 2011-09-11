//
//  RootViewController.m
//  Sumicam
//
//  Created by nop on 9/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"


// Private stuff
@interface RootViewController ()
- (void)imageFetchComplete:(ASIHTTPRequest *)request;
- (void)imageFetchFailed:(ASIHTTPRequest *)request;
@end


@implementation RootViewController

@synthesize request;
@synthesize tableView;
@synthesize imagesList;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	imagesList = [[NSMutableArray alloc] init];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
	cell.textLabel.text=[imagesList objectAtIndex:indexPath.row];
	UIImage *img = [UIImage imageWithContentsOfFile:[imagesList objectAtIndex:indexPath.row]];
	/*
	if (img) {
		//UITableViewCell *cell;
		static NSString *CellIdentifier = @"ImagesCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		cell.textLabel.text = @"test";
		cell.imageView.image = img;
		//[tableView insertRowsAtIndexPaths: withRowAnimation:<#(UITableViewRowAnimation)animation#>]
		NSLog(@"cell image: %@", img );
	}
	 */
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
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}

#pragma mark -
#pragma mark simpleURLFetch
// Runs a request synchronously
- (IBAction)simpleURLFetch:(id)sender
//-(void)simpleUrlFetch
{
	NSURL *url = [NSURL URLWithString:@"http://www.sumilux.com/mia/?a=fetchImageListJSON"];//[urlField text]
	
	// Create a request
	// You don't normally need to retain a synchronous request, but we need to in this case because we'll need it later if we reload the table data
	[self setRequest:[ASIHTTPRequest requestWithURL:url]];
	
	
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
		//ASIHTTPRequest *request;
		
		for (NSDictionary *file in results)
		{
			// Get name and url of the image
			NSString *fileName = [file objectForKey:@"fileName"];
			NSString *fileURL = [file objectForKey:@"fileURL"];
			NSLog(@"%@", fileURL);
			
			request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString: fileURL ]];
			[request setDownloadDestinationPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent: fileName ]];
			
			//[request setUserInfo:[NSDictionary dictionaryWithObject:@"request1" forKey:@"name"]];
			[networkQueue addOperation:request];
			NSLog(@"added %@", fileURL);
		}
		[networkQueue go];
		NSLog(@"networkQueue go");
	}
}

- (void)imageFetchComplete:(ASIHTTPRequest *)request
{
	[imagesList addObject: [request downloadDestinationPath]];
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
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[networkQueue reset];
	[networkQueue release];
	[tableView release];
	[imagesList release];
    [super dealloc];
}

@end

