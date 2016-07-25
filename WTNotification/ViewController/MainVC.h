//
//  MainVC.h
//  WTNotification
//
//  Created by Mehedi Hasan on 7/14/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailVC.h"

@interface MainVC : UIViewController <UITableViewDelegate, UITableViewDataSource, DetailVCBackBtnPressDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segControlForColor;


- (IBAction)segmentSwitch:(UISegmentedControl *)sender;


@end
