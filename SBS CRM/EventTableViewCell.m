//
//  EventTableViewCell.m
//  SBS CRM
//
//  Created by Tom Couchman on 09/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "EventTableViewCell.h"

@implementation EventTableViewCell

@synthesize eventTitle = _eventTitle;
@synthesize siteNameDesc = _siteNameDesc;
@synthesize eventTypeType2 = _eventTypeType2;
@synthesize eventComments = _eventComments;
@synthesize eventDueTime = _eventDueTime;
@synthesize unreadClosedImage = _unreadClosedImage;
@synthesize watchedImage = _watchedImage;

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
