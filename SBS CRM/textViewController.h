//
//  textViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 15/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface textViewController : UIViewController


@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) IBOutlet UITextView *txtText;


@end
