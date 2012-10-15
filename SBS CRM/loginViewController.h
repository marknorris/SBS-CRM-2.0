//
//  loginViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 08/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeychainItemWrapper.h"
#import "fetchXML.h"

//##################################################################
//  login View Controller - Public Interface
//##################################################################

@interface loginViewController : UIViewController <fetchXMLDelegate>


@property (strong, nonatomic) IBOutlet UISegmentedControl *stayLoggedIn;
@property (strong, nonatomic) IBOutlet UIButton *logInButton;


//-------------------------- User details --------------------------
@property (strong, nonatomic) IBOutlet UITextField *txtUserName;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtURL;
//------------------------------------------------------------------

@end
