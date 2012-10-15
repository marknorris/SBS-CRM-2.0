//
//  dateTimePickerViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 22/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface dateTimePickerViewControllerOld : UIViewController

- (IBAction)clickDone:(id)sender;
- (IBAction)clickCancel:(id)sender;

@property (strong, nonatomic) NSDate *dateTime;
@property (nonatomic) NSInteger mode;

@property (strong, nonatomic) IBOutlet UIDatePicker *dateTimePicker;

@end
