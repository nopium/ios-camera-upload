//
//  ImageViewController.h
//  Sumicam
//
//  Created by nop on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ImageViewController : UIViewController {
	
	UIImageView *selectedImageView;
}
@property (retain, nonatomic) IBOutlet UIImageView *selectedImageView;
@end
