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
	
	//UIImageView *imageView1;
	//UIImageView *imageView2;
	//UIImageView *imageView3;
	//UIProgressView *progressIndicator;
	//UISwitch *accurateProgress;
	//UIProgressView *imageProgressIndicator1;
	//UIProgressView *imageProgressIndicator2;
	//UIProgressView *imageProgressIndicator3;
	//UILabel *imageLabel1;
	//UILabel *imageLabel2;
	//UILabel *imageLabel3;
	UITableView *tableView;
	BOOL failed;
	
}
- (IBAction)simpleURLFetch:(id)sender;

@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property (retain, nonatomic) ASIHTTPRequest *request;

@end