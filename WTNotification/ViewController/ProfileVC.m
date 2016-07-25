//
//  ProfileVC.m
//  WTNotification
//
//  Created by Mehedi Hasan on 7/22/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import "ProfileVC.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <QuartzCore/QuartzCore.h>

typedef void(^myCompletion)(BOOL);

@interface ProfileVC (){
    
    UIImage *uploadedResizedImage;
    
    UITextField *activeField;
}

@end

@implementation ProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usernameTF.delegate = self;
    self.statusTF.delegate = self;
    
    User *mySelf = [UserHandler sharedInstance].mySelf;
    
    self.usernameTF.text = mySelf.profileName;
    self.statusTF.text = mySelf.profileStatus;
    
    
    if(mySelf.profileImageName.length){
        
        NSString *imagePath = [[FileHandler sharedHandler] pathToFileWithFileName:mySelf.profileImageName OfType:kFileTypePhoto];
        UIImage *proImage = [UIImage imageWithContentsOfFile:imagePath];
        
        if(proImage != nil){
            self.profileImageView.image = proImage;
        }else{
            self.profileImageView.image = [UIImage imageNamed: @"no-profile.png"];
            
        }
        
    }else{
        self.profileImageView.image = [UIImage imageNamed: @"no-profile.png"];
    }
    
    
    
    [self configUI];
    [self registerForKeyboardNotifications];
    
    UITapGestureRecognizer *aTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ScreenTapped)];
    [self.view addGestureRecognizer:aTap];

    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnProfileImage)];
    singleTap.numberOfTapsRequired = 1;
    self.profileImageView.userInteractionEnabled = YES;
    [self.profileImageView addGestureRecognizer:singleTap];
    
}


-(void) configUI {
    
    //Adjust The view
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
    CGFloat AdjustMiddleHeight = screenHeight - 488;
    
    if(AdjustMiddleHeight < 40){
        AdjustMiddleHeight = 40;
    }
    
    self.middleConstraint.constant = AdjustMiddleHeight;
    [self.view layoutIfNeeded];
    
    
    //
    
    self.postBtn.layer.cornerRadius = 5;
    self.postBtn.clipsToBounds = YES;
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    
    self.profileImageView.layer.borderWidth = 2.0f;
    UIColor *defaultColor = UIColorFromRGB(0x00a651);
    self.profileImageView.layer.borderColor = defaultColor.CGColor;
    
    

    
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}




#pragma mark - IBAction

- (IBAction)tapOnChangeBtnPress:(UIButton *)sender {
    
    [self tapOnProfileImage];
    
}

-(void)tapOnProfileImage{
    NSLog(@"single Tap on imageview");
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Select Options" message:@"Either capture an image from the camera or open from the Photo Library." preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // Camera button tapped.
        [self dismissViewControllerAnimated:NO completion:NULL];
        
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // Photo Gallery button tapped.
        [self dismissViewControllerAnimated:NO completion:nil];
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

- (IBAction)postBtnPress:(UIButton *)sender {
    
    if(uploadedResizedImage != nil || self.statusTF.text.length || self.usernameTF.text.length){
        
        [SVProgressHUD showWithStatus:@"Please wait ..."];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // long-running code
            //Name
            if(self.usernameTF.text.length){
                
                NSString * name = self.usernameTF.text;
                [UserHandler sharedInstance].mySelf.profileName = name;
                
                [[NSUserDefaults standardUserDefaults] setObject:name forKey:USERDEFAULTS_KEY_NAME];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            //status
            if(self.statusTF.text.length){
                
                [UserHandler sharedInstance].mySelf.profileStatus = self.statusTF.text;
                
                [[NSUserDefaults standardUserDefaults] setObject:self.statusTF.text forKey:USERDEFAULTS_KEY_STATUS];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            //save the image
            if(!CGSizeEqualToSize(uploadedResizedImage.size, CGSizeZero)){
                
                NSData *imageData = UIImagePNGRepresentation(uploadedResizedImage);
                NSString *fileName = [NSString stringWithFormat:@"%@.png",[UserHandler sharedInstance].mySelf.deviceID];
                NSString *imagePath = [[FileHandler sharedHandler] writeData:imageData toFileName:fileName ofType:kFileTypePhoto];
                
                [UserHandler sharedInstance].mySelf.profileImageName = fileName;
                
                [[NSUserDefaults standardUserDefaults] setObject:fileName forKey:USERDEFAULTS_KEY_IMAGE];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            
            [self sendPostMessageWithCompletionBlock:^(BOOL finished) {
                
                if(finished){
                    
                    NSLog(@"Successfully finished.");
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Successfully notification send."
                                                                    message: @""
                                                                   delegate: nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    
                    [alert show];
                    
                    
                }
            }];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [SVProgressHUD dismiss];
            });
        });
        
        
        
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"All Empty. please update something."
                                                        message: @""
                                                       delegate: nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
    }
    
}


#pragma mark - UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    activeField = textField;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 128;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}

-(void)ScreenTapped {
    
    [self.view endEditing:YES];
}

#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *uploadedImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    
    NSData *imageData = UIImagePNGRepresentation(uploadedImage);
    
    //resize the image
    uploadedResizedImage = [[FileHandler sharedHandler] resizeImage:uploadedImage];
    
    imageData = UIImagePNGRepresentation(uploadedResizedImage);
    
    self.profileImageView.image = uploadedResizedImage;
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (void)sendPostMessageWithCompletionBlock:(myCompletion) completionBlock {
    
    
    NSString *postMessage = [[MessageHandler sharedHandler] postMessage];
    
    NSUInteger bytes = [postMessage lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%lu bytes", (unsigned long)bytes);
    
    [[ConnectionHandler sharedHandler] enableBroadCast];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        NSArray *channelMembers = [[UserHandler sharedInstance] getAllUserIPs];
        
        for (NSString *ipAddress in channelMembers) {
            
            [[ConnectionHandler sharedHandler] sendMessage:postMessage toIPAddress:ipAddress];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            completionBlock(YES);
        });
    });
    
}





@end
