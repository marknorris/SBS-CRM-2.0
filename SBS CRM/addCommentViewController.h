//
//  addCommentViewController.h
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 10/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fetchXML.h"

@protocol addCommentDelegate <NSObject>
@required
-(void)commentUpdated:(NSString *)comment;
@end

@interface addCommentViewController : UIViewController <fetchXMLDelegate, UITextViewDelegate>



- (IBAction)btnCancelClick:(id)sender;
- (IBAction)btnDoneClick:(id)sender;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnDone;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCancel;

@property (strong, nonatomic) IBOutlet UITextView *txtComment;

@property (nonatomic, retain) id delegate;
@property (strong, nonatomic) NSString *eventId;

@end
