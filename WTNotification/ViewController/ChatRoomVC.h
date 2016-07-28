//
//  ChatRoomVC.h
//  WTNotification
//
//  Created by Mehedi Hasan on 7/28/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatRoomVC : UIViewController <UITableViewDelegate, UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UITableView *statusTableView;


@end
