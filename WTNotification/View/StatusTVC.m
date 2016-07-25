//
//  StatusTVC.m
//  WTNotification
//
//  Created by Mehedi Hasan on 7/15/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import "StatusTVC.h"
#import <QuartzCore/QuartzCore.h>

@implementation StatusTVC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
        
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    
    self.profileImageView.layer.borderWidth = 1.0f;
    UIColor *defaultColor = UIColorFromRGB(0x00a651);
    self.profileImageView.layer.borderColor = defaultColor.CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
