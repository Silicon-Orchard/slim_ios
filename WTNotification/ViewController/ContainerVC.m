//
//  ContainerVC.m
//  WTNotification
//
//  Created by Mehedi Hasan on 7/22/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import "ContainerVC.h"

@interface ContainerVC ()

@end

@implementation ContainerVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    // add viewController so you can switch them later.
    UIViewController *vc = [self viewControllerForSegmentIndex:self.typeSegmentedControl.selectedSegmentIndex];
    [self addChildViewController:vc];
    vc.view.frame = self.contentView.bounds;
    [self.contentView addSubview:vc.view];
    self.currentViewController = vc;
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    
    UIViewController *vc = [self viewControllerForSegmentIndex:sender.selectedSegmentIndex];
    [self addChildViewController:vc];
    
    [self transitionFromViewController:self.currentViewController toViewController:vc duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        [self.currentViewController.view removeFromSuperview];
        vc.view.frame = self.contentView.bounds;
        [self.contentView addSubview:vc.view];
        
    } completion:^(BOOL finished) {
        
        [vc didMoveToParentViewController:self];
        [self.currentViewController removeFromParentViewController];
        self.currentViewController = vc;
    }];
    
    //self.navigationItem.title = vc.title;
}

- (UIViewController *)viewControllerForSegmentIndex:(NSInteger)index {
    UIViewController *vc;
    switch (index) {
        case 0:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainVCID"];
            break;
        case 1:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileVCID"];
            break;
    }
    return vc;
}

@end
