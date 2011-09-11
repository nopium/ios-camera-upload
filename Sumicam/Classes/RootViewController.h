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

@interface RootViewController : UITableViewController {
	ASIHTTPRequest *request;
	ASINetworkQueue *networkQueue;
	
	UITableView *tableView;
	BOOL failed;
	NSMutableArray *imagesList;
	
}
- (IBAction)simpleURLFetch:(id)sender;

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) ASIHTTPRequest *request;
@property (retain) NSMutableArray *imagesList;
@end