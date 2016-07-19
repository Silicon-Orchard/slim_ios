//
//  SettingVC.m
//  WTNotification
//
//  Created by Mehedi Hasan on 7/14/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import "SettingVC.h"
#import <SVProgressHUD/SVProgressHUD.h>

typedef void(^myCompletion)(BOOL);

@interface SettingVC (){
    
    UIImage *uploadedResizedImage;
}

@end

@implementation SettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Settings";
    self.nameTF.delegate = self;
    
    User *mySelf = [UserHandler sharedInstance].mySelf;
    
    self.nameTF.text = mySelf.profileName;
    self.statusTV.text = mySelf.profileStatus;
    
    
    if(mySelf.profileImageName.length){
        
        NSString *imagePath = [[FileHandler sharedHandler] pathToFileWithFileName:mySelf.profileImageName OfType:kFileTypePhoto];
        UIImage *proImage = [UIImage imageWithContentsOfFile:imagePath];
        
        if(proImage != nil){
            self.imageView.image = proImage;
        }else{
            self.imageView.image = [UIImage imageNamed: @"no-profile.png"];
            
        }
        
    }else{
        self.imageView.image = [UIImage imageNamed: @"no-profile.png"];
    }

    
    
    [self configUI];
    
    UITapGestureRecognizer *aTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ScreenTapped)];
    [self.view addGestureRecognizer:aTap];
    
}

-(void) configUI {
    
    UIColor *borderColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    
    self.statusTV.layer.borderColor = borderColor.CGColor;
    self.statusTV.layer.borderWidth = 1.0;
    self.statusTV.layer.cornerRadius = 5.0;
}


#pragma mark - IBAction

- (IBAction)uploadBtnPress:(id)sender {
    
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

- (IBAction)postBtnPress:(id)sender {
    
    if(uploadedResizedImage != nil || self.statusTV.text.length || self.nameTF.text.length){
        
        [SVProgressHUD showWithStatus:@"Please wait ..."];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // long-running code
            //Name
            if(self.nameTF.text.length){
                
                NSString * name = self.nameTF.text;
                [UserHandler sharedInstance].mySelf.profileName = name;
                
                [[NSUserDefaults standardUserDefaults] setObject:name forKey:USERDEFAULTS_KEY_NAME];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            //status
            if(self.statusTV.text.length){
                
                [UserHandler sharedInstance].mySelf.profileStatus = self.statusTV.text;
                
                [[NSUserDefaults standardUserDefaults] setObject:self.statusTV.text forKey:USERDEFAULTS_KEY_IMAGE];
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
    
    self.imageView.image = uploadedResizedImage;
    
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
