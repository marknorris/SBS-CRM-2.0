//
//  loadingSavingView.m
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 15/06/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "loadingSavingView.h"

@implementation loadingSavingView

- (id)initWithFrame:(CGRect)frame withMessage:(NSString *)message
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIActivityIndicatorView *refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        refreshSpinner.frame = CGRectMake(0, 0, 30, 30);
        refreshSpinner.hidesWhenStopped = YES;
        [refreshSpinner startAnimating];
        
        UILabel *savingLabel = [[UILabel alloc] init];
        savingLabel.text = message;
        savingLabel.frame = CGRectMake(30, 0, 90, 30);
        savingLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        
       [self addSubview:refreshSpinner ]; 
        [self addSubview:savingLabel];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
