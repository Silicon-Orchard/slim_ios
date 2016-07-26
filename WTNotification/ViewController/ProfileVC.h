//
//  ProfileVC.h
//  WTNotification
//
//  Created by Mehedi Hasan on 7/22/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileVC : UIViewController <UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;




@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@property (weak, nonatomic) IBOutlet UITextField *usernameTF;
@property (weak, nonatomic) IBOutlet UITextField *statusTF;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *middleConstraint;

@property (weak, nonatomic) IBOutlet UIView *postBtn;

- (IBAction)postBtnPress:(UIButton *)sender;
- (IBAction)tapOnChangeBtnPress:(UIButton *)sender;


@property (weak, nonatomic) IBOutlet UIView *backgroundView;

#pragma mark - popup
@property (weak, nonatomic) IBOutlet UIView *popupView;

- (IBAction)cancelBtnPress:(id)sender;
- (IBAction)galleryBtnPress:(id)sender;
- (IBAction)cameraBtnPress:(id)sender;


#pragma mark - StatusPopup

@property (weak, nonatomic) IBOutlet UIView *statusPopupView;
@property (weak, nonatomic) IBOutlet UILabel *StatusPopupTitle;
@property (weak, nonatomic) IBOutlet UITableView *selectStatusTableView;
@property (weak, nonatomic) IBOutlet UITextView *writeStatusTextView;
@property (weak, nonatomic) IBOutlet UIButton *WriteStatusBtn;


- (IBAction)statusCancelBtnPress:(id)sender;
- (IBAction)writeStatusBtnPress:(id)sender;




@end
