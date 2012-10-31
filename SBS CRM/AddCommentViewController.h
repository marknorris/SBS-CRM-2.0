//
//  addCommentViewController.h
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 10/05/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fetchXML.h"

@protocol addCommentViewControllerDelegate <NSObject>
@required
-(void)commentUpdated:(NSString *)comment;
@end

@interface addCommentViewController : UIViewController <fetchXMLDelegate, UITextViewDelegate>



- (IBAction)btnCancelClick:(id)sender;
- (IBAction)btnDoneClick:(id)sender;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnDone;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCancel;

@property (strong, nonatomic) IBOutlet UITextView *txtComment;

@property (nonatomic, retain) id <addCommentViewControllerDelegate> delegate;
@property (strong, nonatomic) NSString *eventId;

@end
