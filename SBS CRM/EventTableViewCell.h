//
//  EventTableViewCell.h
//  SBS CRM
//
//  Created by Tom Couchman on 09/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *eventTitle;
@property (strong, nonatomic) IBOutlet UILabel *siteNameDesc;
@property (strong, nonatomic) IBOutlet UILabel *eventTypeType2;
@property (strong, nonatomic) IBOutlet UILabel *eventComments;
@property (strong, nonatomic) IBOutlet UILabel *eventDueTime;
@property (strong, nonatomic) IBOutlet UIImageView *unreadClosedImage;
@property (strong, nonatomic) IBOutlet UIImageView *watchedImage;

@end
