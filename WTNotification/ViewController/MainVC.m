//
//  MainVC.m
//  WTNotification
//
//  Created by Mehedi Hasan on 7/14/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import "MainVC.h"
#import "Constants.h"
#import "StatusTVC.h"

#import "AppDelegate.h"

@interface MainVC ()

@property (nonatomic, strong) NSArray * userListArrays;

@end


@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    self.userListArrays = [NSArray arrayWithArray:[[UserHandler sharedInstance] getUsers]];
    
    
    //TableView
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[[UIColor clearColor] colorWithAlphaComponent:0.2f]];
    


    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDeviceJoined:) name:NOTIFICATIONKEY_NEW_DEVICE_JOINED_APPDELEGATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDeviceConfirmed:) name:NOTIFICATIONKEY_NEW_DEVICE_CONFIRMED_APPDELEGATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfileInfoNotification:) name:NOTIFICATIONKEY_UPDATE_PROFILE_INFO_APPDELEGATE object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.title = @"Contact List";
}

-(void)viewWillDisappear:(BOOL)animated{
    
    self.title = @"Back";
    
    [super viewWillDisappear:animated];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATIONKEY_NEW_DEVICE_JOINED_APPDELEGATE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATIONKEY_NEW_DEVICE_CONFIRMED_APPDELEGATE object:nil];
}


#pragma mark - IBAction

- (IBAction)segmentSwitch:(UISegmentedControl *)sender {
    
    
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
//    if (selectedSegment == 0) {
//        //toggle the correct view to be visible
//        [firstView setHidden:NO];
//        [secondView setHidden:YES];
//    }
//    else{
//        //toggle the correct view to be visible
//        [firstView setHidden:YES];
//        [secondView setHidden:NO];
//    }
    
}

#pragma mark - NSNotification

-(void) newDeviceJoined:(NSNotification*)notification{
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    //Save The User
    //User *newUser = [[User alloc] initWithDictionary:jsonDict andActive:YES];
    //[[UserHandler sharedInstance] addUser:newUser];

    
    //Update the Table
    self.userListArrays = [[UserHandler sharedInstance] getUsers];
    [self.tableView reloadData];
    
}

-(void) newDeviceConfirmed:(NSNotification*)notification{
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    //Update the Table
    self.userListArrays = [[UserHandler sharedInstance] getUsers];
    [self.tableView reloadData];

}

-(void) updateProfileInfoNotification:(NSNotification*)notification{
    
    //Update the Table
    self.userListArrays = [[UserHandler sharedInstance] getUsers];
    [self.tableView reloadData];
}



- (void)addNewDeviceToNetWorkDeviceList:(NSNotification *) sender {
    
    self.userListArrays = [[UserHandler sharedInstance] getUsers];
    
    [self.tableView reloadData];
    
}

- (void)userLeftSystem:(NSNotification *) sender {
    
    self.userListArrays = [[UserHandler sharedInstance] getUsers];
    [self.tableView reloadData];
}




#pragma mark - UITableViewDataSource

static NSString * CellID = @"StatusCellID";

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.userListArrays.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    User * user = [self.userListArrays objectAtIndex:indexPath.row];
    
    StatusTVC *cell =  (StatusTVC *)[tableView dequeueReusableCellWithIdentifier:CellID forIndexPath:indexPath];
    cell.nameLabel.text = user.profileName;
    cell.statusLabel.text = user.profileStatus;
    
    if(user.profileImageName.length){
        NSString *imagePath = [[FileHandler sharedHandler] pathToFileWithFileName:user.profileImageName OfType:kFileTypePhoto];
        
        UIImage *cellImage = [UIImage imageWithContentsOfFile:imagePath];
        
        if(cellImage != nil){
            cell.profileImageView.image = cellImage;
        }else{
            cell.profileImageView.image = [UIImage imageNamed:@"no-profile.png"];
        }
        
    }else{
        cell.profileImageView.image = [UIImage imageNamed:@"no-profile.png"];
    }
    
    
    cell.backgroundColor = cell.contentView.backgroundColor;
    
    return cell;
}


#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60.0f;
}




@end
