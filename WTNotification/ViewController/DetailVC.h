//
//  DetailVC.h
//  WTNotification
//
//  Created by Mehedi Hasan on 7/25/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DetailVCBackBtnPressDelegate <NSObject>

- (void)detailVCBackBtnPress:(id)sender;
@end


@interface DetailVC : UIViewController

@property (weak, nonatomic) User *user;
@property (nonatomic, weak) id<DetailVCBackBtnPressDelegate> delegate;


@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;


- (IBAction)backBtnPress:(id)sender;

@end
