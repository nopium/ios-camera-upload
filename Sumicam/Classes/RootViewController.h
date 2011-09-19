//
//  RootViewController.h
//  Sumicam
//
//  Created by nop on 9/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ASIHTTPRequest;
@class ASINetworkQueue;
@class ASIFormDataRequest;

@interface RootViewController : UITableViewController <UIActionSheetDelegate> {
	ASIHTTPRequest *request;
	ASIFormDataRequest *requestForm;
	ASINetworkQueue *networkQueue;

	UITableView *tableView;
	BOOL failed;
	NSMutableArray *imagesList;
	UIImagePickerController *imagePickerController;
	
	UIActionSheet *projectAddActions;
	NSInteger projectAddActionsCameraButton;
	NSInteger projectAddActionsAlbumsButton;
}
- (IBAction)simpleURLFetch:(id)sender;

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) ASIHTTPRequest *request;
@property (retain) NSMutableArray *imagesList;
@property (retain, nonatomic) ASIFormDataRequest *requestForm;
@end