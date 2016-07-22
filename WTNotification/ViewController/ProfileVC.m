//
//  ProfileVC.m
//  WTNotification
//
//  Created by Mehedi Hasan on 7/22/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import "ProfileVC.h"

@interface ProfileVC (){
    
    UIImage *uploadedResizedImage;
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
    
//    UITapGestureRecognizer *aTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ScreenTapped)];
//    [self.view addGestureRecognizer:aTap];

    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnProfileImage)];
    singleTap.numberOfTapsRequired = 1;
    self.profileImageView.userInteractionEnabled = YES;
    [self.profileImageView addGestureRecognizer:singleTap];
    
}


-(void) configUI {
    
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2 - 10;
    self.profileImageView.clipsToBounds = YES;
    
    self.profileImageView.layer.borderWidth = 2.0f;
    UIColor *defaultColor = UIColorFromRGB(0x00a651);
    self.profileImageView.layer.borderColor = defaultColor.CGColor;
}


-(void)tapOnProfileImage{
    NSLog(@"single Tap on imageview");
    
}




@end
