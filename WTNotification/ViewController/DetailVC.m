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
    
    [self setupUI];
}



-(void) configUI {
    
    self.backBtn.layer.cornerRadius = 5;
    self.backBtn.clipsToBounds = YES;
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    
    self.profileImageView.layer.borderWidth = 2.0f;
    UIColor *defaultColor = UIColorFromRGB(0x00a651);
    self.profileImageView.layer.borderColor = defaultColor.CGColor;

}

-(void)setupUI{

    
    //self.profileImageView.image =
    NSLog(@"nameStr: %@", self.nameStr);
    NSLog(@"statusStr: %@", self.statusStr);
    
    self.nameLabel.text = self.nameStr;
    self.statusLabel.text = self.statusStr;
    [self.statusLabel sizeToFit];
    
    self.nameLabel.text = @"MR. Rony";
    
    if(self.imageStr.length){
        
        NSString *imagePath = [[FileHandler sharedHandler] pathToFileWithFileName:self.imageStr OfType:kFileTypePhoto];
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
