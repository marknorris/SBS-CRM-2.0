//
//  pickerViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 27/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PickerViewController;

@protocol PickerViewControllerDelegate <NSObject>

- (void)pickerViewController:(PickerViewController *)controller didSelectItem:(NSString *)Item withSourceCellIdentifier:(NSString *)sourceCellIdentifier;

@end

@interface PickerViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> 

@property (nonatomic, weak) id <PickerViewControllerDelegate> delegate;
@property (strong, nonatomic) NSString *sourceCellIdentifier;
@property (strong, nonatomic) NSString *item;
@property (strong, nonatomic) NSArray *itemArray;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;

- (IBAction)clickDone:(id)sender;
- (IBAction)clickCancel:(id)sender;

@end
