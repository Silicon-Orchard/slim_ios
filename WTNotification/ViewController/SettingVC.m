//
//  SettingVC.m
//  WTNotification
//
//  Created by Mehedi Hasan on 7/14/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import "SettingVC.h"

typedef void(^myCompletion)(BOOL);

@interface SettingVC ()

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
    
    NSString *imageName = mySelf.profileImageName.length ? mySelf.profileImageName : @"no-profile.png";
    self.imageView.image = [UIImage imageNamed:imageName];
    
    
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
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    //Save the image
    
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *fileName = [FileHandler getFileNameOfType:kFileTypePhoto];
    
    
    [[FileHandler sharedHandler] writeData:imageData toFileName:fileName ofType:kFileTypePhoto];
    
    [self sendFile:fileName ofType:kFileTypePhoto andCompletionBlock:^(BOOL finished) {
        
        if(finished){
            
            
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (void)sendFile:(NSString *) fileName ofType:(int) fileType andCompletionBlock:(myCompletion) completionBlock {
    
    NSArray *chunkStringArray = [[MessageHandler sharedHandler] jsonStringArrayWithFile:fileName OfType:fileType];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        NSArray *channelMembers = [[UserHandler sharedInstance] getAllUserIPs];
        
        for (NSString *ipAddress in channelMembers) {
            
            
            for (int j = 0; j<chunkStringArray.count; j++) {
                NSLog(@"message to send %@", [chunkStringArray objectAtIndex:j]);
                if (j%5 == 0) {
                    [NSThread sleepForTimeInterval:0.09];
                }
                
                [[ConnectionHandler sharedHandler] sendFileMessage:[chunkStringArray objectAtIndex:j] toIPAddress:ipAddress];
            }
        }

        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
            //                                                            message: [NSString stringWithFormat:@"Sent packet count %lu", (unsigned long)chunkStringArray.count] //@"Voice Message Sent to Channel Members!"
            //                                                           delegate: nil
            //                                                  cancelButtonTitle:@"OK"
            //                                                  otherButtonTitles:nil];
            //
            //
            //            [alert show];
            
            completionBlock(YES);
        });
    });
    
}

@end
