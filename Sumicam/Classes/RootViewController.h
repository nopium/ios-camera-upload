//
//  RootViewController.h
//  Sumicam
//
//  Created by nop on 9/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ASIHTTPRequest;

@interface RootViewController : UITableViewController {
		ASIHTTPRequest *request;
}
- (IBAction)simpleURLFetch:(id)sender;
@property (retain, nonatomic) ASIHTTPRequest *request;

@end
