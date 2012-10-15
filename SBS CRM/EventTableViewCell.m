//
//  EventTableViewCell.m
//  SBS CRM
//
//  Created by Tom Couchman on 09/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventTableViewCell.h"

@implementation EventTableViewCell
@synthesize eventTitle;
@synthesize siteNameDesc;
@synthesize eventTypeType2;
@synthesize eventComments;
@synthesize eventDueTime;
@synthesize unreadClosedImage;
@synthesize watchedImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
