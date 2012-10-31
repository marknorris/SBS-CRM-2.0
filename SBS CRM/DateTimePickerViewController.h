//
//  dateTimePickerViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 22/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@class dateTimePickerViewController;

@protocol dateTimePickerViewControllerDelegate <NSObject>
-(void)dateTimePickerViewController:(dateTimePickerViewController *)controller
                  didSelectDateTime: (NSDate *)date withSourceCellIdentifier:(NSString *)sourceCellIdentifier withSender:(id)sender;
@end

@interface dateTimePickerViewController : UIViewController


@property (nonatomic, weak) id <dateTimePickerViewControllerDelegate> delegate;

@property (strong, nonatomic) NSString *sourceCellIdentifier;
@property (strong, nonatomic) id sender;

- (IBAction)clickDone:(id)sender;
- (IBAction)clickCancel:(id)sender;

@property (strong, nonatomic) NSDate *dateTime;
@property (nonatomic) NSInteger mode;

@property (strong, nonatomic) IBOutlet UIDatePicker *dateTimePicker;

@end
