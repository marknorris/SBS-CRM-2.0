//
//  textViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 15/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "addCommentViewController.h"

@interface textViewController : UIViewController <addCommentDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnAdd;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) IBOutlet UITextView *txtText;

@property (strong, nonatomic) NSString *eventId;

@property (nonatomic) BOOL editable;

@end
