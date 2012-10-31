//
//  documentViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 29/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DocumentViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString *eventID;
@property (strong, nonatomic) NSString *attOriginalFilename;
@property (strong, nonatomic) NSString *attachmentID;
@property (strong, nonatomic) NSString *atyMnemonic;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

- (IBAction)clickDone:(id)sender;

@end
