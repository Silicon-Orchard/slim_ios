//
//  DetailVC.m
//  WTNotification
//
//  Created by Mehedi Hasan on 7/25/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import "DetailVC.h"

@interface DetailVC ()

@end

@implementation DetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configUI];
}



-(void) configUI {
    
    self.backBtn.layer.cornerRadius = 5;
    self.backBtn.clipsToBounds = YES;
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2 - 10;
    self.profileImageView.clipsToBounds = YES;
    
    self.profileImageView.layer.borderWidth = 2.0f;
    UIColor *defaultColor = UIColorFromRGB(0x00a651);
    self.profileImageView.layer.borderColor = defaultColor.CGColor;

}

-(void)setUser:(User *)user{

    //self.profileImageView.image =
    NSLog(@"user.profileName: %@", user.profileName);
    
    self.nameLabel.text = user.profileName;
    self.statusLabel.text = user.profileStatus;
    [self.statusLabel sizeToFit];
    
    if(user.profileImageName.length){
        
        NSString *imagePath = [[FileHandler sharedHandler] pathToFileWithFileName:user.profileImageName OfType:kFileTypePhoto];
        UIImage *proImage = [UIImage imageWithContentsOfFile:imagePath];
        
        if(proImage != nil){
            self.profileImageView.image = proImage;
        }else{
            self.profileImageView.image = [UIImage imageNamed: @"no-profile.png"];
            
        }
        
    }else{
        self.profileImageView.image = [UIImage imageNamed: @"no-profile.png"];
    }
    
}

- (IBAction)backBtnPress:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(detailVCBackBtnPress:)]) {
        
        [self.delegate detailVCBackBtnPress:sender];
    }
    
}
@end
