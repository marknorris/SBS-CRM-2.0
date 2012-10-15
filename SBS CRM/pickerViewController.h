//
//  pickerViewController.h
//  SBS CRM
//
//  Created by Tom Couchman on 27/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class pickerViewController;

@protocol pickerViewControllerDelegate <NSObject>
-(void)pickerViewController:(pickerViewController *)controller
                  didSelectItem: (NSString *)Item withSourceCellIdentifier:(NSString *)sourceCellIdentifier;
@end

@interface pickerViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>{
    
    IBOutlet UIPickerView *picker;
    NSInteger selectedIndex;
}

@property (nonatomic, weak) id <pickerViewControllerDelegate> delegate;

@property (strong, nonatomic) NSString *sourceCellIdentifier;
@property (strong, nonatomic) NSString *item;
@property (strong, nonatomic) NSArray *itemArray;

- (IBAction)clickDone:(id)sender;
- (IBAction)clickCancel:(id)sender;




@end
