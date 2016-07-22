//
//  ContainerVC.h
//  WTNotification
//
//  Created by Mehedi Hasan on 7/22/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContainerVC : UIViewController

@property (weak, nonatomic) UIViewController *currentViewController;

@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegmentedControl;
@property (weak, nonatomic) IBOutlet UIView *contentView;

- (IBAction)segmentChanged:(UISegmentedControl *)sender;

@end
