//
//  ChatVC.h
//  WTNotification
//
//  Created by Mehedi Hasan on 7/26/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPChangeNotifier.h"

@interface ChatVC : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, IPChangeNotifierDelegate>

@end
