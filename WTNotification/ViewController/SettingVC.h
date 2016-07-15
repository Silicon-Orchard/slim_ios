//
//  SettingVC.h
//  WTNotification
//
//  Created by Mehedi Hasan on 7/14/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingVC : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate>





@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextView *statusTV;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;
@property (weak, nonatomic) IBOutlet UIButton *postBtn;


- (IBAction)uploadBtnPress:(id)sender;
- (IBAction)postBtnPress:(id)sender;

@end
