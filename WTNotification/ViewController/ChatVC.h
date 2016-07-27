//
//  ChatVC.h
//  WTNotification
//
//  Created by Mehedi Hasan on 7/26/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPChangeNotifier.h"
#import "Channel.h"

@interface ChatVC : UIViewController <UITextFieldDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, IPChangeNotifierDelegate>


@property (strong, nonatomic) Channel *currentActiveChannel;


//Stroyboard
@property (weak, nonatomic) IBOutlet UILabel *channelNameLabel;


@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UITextView *memberTextView;

@property (weak, nonatomic) IBOutlet UITableView *chatTableView;

@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpaceForSendContainer;

- (IBAction)sendBtnPress:(id)sender;
- (IBAction)backBtnPress:(id)sender;

@end
