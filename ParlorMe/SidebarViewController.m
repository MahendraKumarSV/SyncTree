//
//  SidebarViewController.m
//  SidebarDemo
//
//  Created by Simon on 29/6/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "SidebarViewController.h"
#import "SWRevealViewController.h"
#import "SideMenuTableViewCell.h"
#import "ServicesViewController.h"
#import "HomeViewController.h"
#import "SettingsViewController.h"
#import "LoginViewController.h"
#import "Constants.h"
#import "UserAccount.h"
#import "StylistAccount.h"
#import "CoreDataModel.h"
#import "SetScheduleViewController.h"
#import "AppointmentsViewController.h"
#import "UpdateProfileViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "FavouritiesViewController.h"

@interface SidebarViewController ()

@end

@implementation SidebarViewController {
    NSMutableArray *menuItems;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.scrollEnabled = NO;
    menuItems = [[NSMutableArray alloc] init];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LeftMenuImage"]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //remove all menu items and set according to user type and login information
    [menuItems removeAllObjects];
    NSArray *tempMenuItems;
    NSArray *userRecords = [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:nil andSortDescriptor:nil forContext:nil];
    if(userRecords.count > 0)
    {
        User *currentUser = [userRecords objectAtIndex:0];
        if ([[currentUser.userId stringByReplacingOccurrencesOfString:@" " withString:@""]length] > 0 && ![currentUser.userId caseInsensitiveCompare:@"guest"] == NSOrderedSame) {
            if ([currentUser.isUserTypeClient boolValue]) {
                tempMenuItems =  @[@"Select Services", @"My Account", @"FAQ’s", @"Messages", @"Favorites", @"History", @"Contact Parlor"];
            }
            else {
                tempMenuItems =  @[@"Schedule", @"My Appointments", @"My Account", @"Messages", @"History", @"Contact Parlor"];
            }
        }
        else {
            tempMenuItems =  @[@"Select Services"];
        }
    }
    
    else
    {
        tempMenuItems =  @[@"Select Services"];
    }
    
    for (int i = 0; i < [tempMenuItems count]; i++) {
        [menuItems addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[tempMenuItems objectAtIndex:i], nil] forKeys:[NSArray arrayWithObjects:@"MenuName", nil]]];
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    
    UIImageView *closeMenuImgView = [[UIImageView alloc] initWithFrame:CGRectMake(25.0, 15.0, 25.0, 25.0)];
    closeMenuImgView.image = [UIImage imageNamed:@"CloseLeftMenuImage"];
    [view addSubview:closeMenuImgView];
    
    UITapGestureRecognizer *closeMenuGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.revealViewController action:@selector(revealToggle:)];
    [view addGestureRecognizer:closeMenuGesture];
    
    return view;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    
    UIButton *settingsBtn = [[UIButton alloc] initWithFrame:CGRectMake(25.0, 15.0, 70.0, 50.0)];
    settingsBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [settingsBtn setTitleColor:DashedLineRGBColor(36.0, 38.0, 41.0) forState:UIControlStateNormal];
    [settingsBtn setImage:[UIImage imageNamed:@"SettingsLeftMenuImage"] forState:UIControlStateNormal];
    [settingsBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 17.0, 25.0, 0.0)];
    [settingsBtn setTitleEdgeInsets:UIEdgeInsetsMake(30.0, -25.0, 0.0, 0.0)];
    [settingsBtn setTitle:@"SETTINGS" forState:UIControlStateNormal];
    [view addSubview:settingsBtn];
    
    NSArray *userRecords = [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:nil andSortDescriptor:nil forContext:nil];
    if(userRecords.count > 0)
    {
        User *currentUser = [userRecords objectAtIndex:0];
        if ([[currentUser.userId stringByReplacingOccurrencesOfString:@" " withString:@""]length] > 0) {
            UIButton *logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake((settingsBtn.frame.origin.x + settingsBtn.frame.size.width + 10.0), settingsBtn.frame.origin.y, 70.0, 50.0)];
            logoutBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
            [logoutBtn setTitleColor:DashedLineRGBColor(36.0, 38.0, 41.0) forState:UIControlStateNormal];
            [logoutBtn setImage:[UIImage imageNamed:@"SignoutLeftMenuImage"] forState:UIControlStateNormal];
            [logoutBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 17.0, 25.0, 0.0)];
            [logoutBtn setTitleEdgeInsets:UIEdgeInsetsMake(30.0, -25.0, 0.0, 0.0)];
            [logoutBtn setTitle:@"LOG OUT" forState:UIControlStateNormal];
            [logoutBtn addTarget:self action:@selector(logOut) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:logoutBtn];
        }
    }
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"SIDEMENU";
    SideMenuTableViewCell *cell = (SideMenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    NSDictionary *menuDict = [menuItems objectAtIndex:indexPath.row];
    cell.menuNameLbl.text = menuDict[@"MenuName"];
    
    //UserAccount *userAccount = [UserAccount sharedInstance];
    UINavigationController *navController = (UINavigationController *)self.revealViewController.frontViewController;
    
    NSArray *userRecords = [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:nil andSortDescriptor:nil forContext:nil];
    
    if(userRecords.count > 0)
    {
        User *currentUser = [userRecords objectAtIndex:0];
        
        if([currentUser.userId caseInsensitiveCompare:@"guest"] == NSOrderedSame)
        {
        }
        
        if ([currentUser.isUserTypeClient boolValue])
        {
            if ([[navController.viewControllers objectAtIndex:0] isKindOfClass:[ServicesViewController class]] && indexPath.row == 0)
            {
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            
            /*else if ([[userAccount.userId stringByReplacingOccurrencesOfString:@" " withString:@""]length] > 0)
            {
                if ([[navController.viewControllers objectAtIndex:0] isKindOfClass:[SettingsViewController class]] && indexPath.row == 1)
                {
                    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }*/
            
            else if ([[navController.viewControllers objectAtIndex:0] isKindOfClass:[SettingsViewController class]] && indexPath.row == 1)
            {
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            
            else if ([[navController.viewControllers objectAtIndex:0] isKindOfClass:[FavouritiesViewController class]] && indexPath.row == 4)
            {
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:4 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
        
        else
        {
            if ([[navController.viewControllers objectAtIndex:0] isKindOfClass:[SetScheduleViewController class]] && indexPath.row == 0)
            {
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            
            else if ([[navController.viewControllers objectAtIndex:0] isKindOfClass:[AppointmentsViewController class]] && indexPath.row == 1)
            {
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            
            else if ([[navController.viewControllers objectAtIndex:0] isKindOfClass:[UpdateProfileViewController class]] && indexPath.row == 2)
            {
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
    
    /*if (indexPath.row == 0) {//home screen - BOOK AN APPOINTMENT
        HomeViewController *hvc = [storyBoard instantiateViewControllerWithIdentifier:@"HomeViewController"];
        [navController setViewControllers:@[hvc] animated: NO];
    }
    else {
        NSArray *userRecords = [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:nil andSortDescriptor:nil forContext:nil];
        if(userRecords.count > 0)
        {
            User *currentUser = [userRecords objectAtIndex:0];
            if ([[currentUser.userId stringByReplacingOccurrencesOfString:@" " withString:@""]length] > 0)
            {
                if([currentUser.userId caseInsensitiveCompare:@"guest"] == NSOrderedSame)
                {
                    ServicesViewController *svc = [storyBoard instantiateViewControllerWithIdentifier:@"ServicesStoryView"];
                    [navController setViewControllers:@[svc] animated: NO];
                }
                else if ([currentUser.isUserTypeClient boolValue])
                {
                    if (indexPath.row == 1) {//Select Servcie page
                        ServicesViewController *svc = [storyBoard instantiateViewControllerWithIdentifier:@"ServicesStoryView"];
                        [navController setViewControllers:@[svc] animated: NO];
                    }
                    else if (indexPath.row == 2) {//PROFILE
                        SettingsViewController *svc = [storyBoard instantiateViewControllerWithIdentifier:@"SettingsSB"];
                        [navController setViewControllers: @[svc] animated: NO];
                    }
                    else if (indexPath.row == 3) {//FAQ's
                        
                    }
                    else if (indexPath.row == 4) {//Messages
                        
                    }
                    else if (indexPath.row == 5) {//Favorites
                        
                    }
                    else if (indexPath.row == 6) {//History
                        
                    }
                }
                
                else
                {
                    if (indexPath.row == 1) {//Schedule
                        SetScheduleViewController *svc = [storyBoard  instantiateViewControllerWithIdentifier:@"SetScheduleViewControllerSB"];
                        [navController setViewControllers: @[svc] animated: NO ];
                    }
                    else if (indexPath.row == 2) {//MyAppointments
                        AppointmentsViewController *svc = [storyBoard  instantiateViewControllerWithIdentifier:@"AppointmentsViewControllerSB"];
                        [navController setViewControllers: @[svc] animated: NO ];
                    }
                    else if (indexPath.row == 3) {//PROFILE
                        UpdateProfileViewController *svc = [storyBoard  instantiateViewControllerWithIdentifier:@"UpdateProfileViewControllerSB"];
                        [navController setViewControllers: @[svc] animated: NO ];
                    }
                    else if (indexPath.row == 4) {//Messages
                        
                    }
                    else if (indexPath.row == 5) {//History
                        
                    }
                }
            }
        }
        
        else if (indexPath.row == 1) {//Select Servcie page
            ServicesViewController *svc = [storyBoard instantiateViewControllerWithIdentifier:@"ServicesStoryView"];
            [navController setViewControllers:@[svc] animated: NO];
        }
    }*/
    
    NSArray *userRecords = [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:nil andSortDescriptor:nil forContext:nil];
    if(userRecords.count > 0)
    {
        User *currentUser = [userRecords objectAtIndex:0];
        if ([[currentUser.userId stringByReplacingOccurrencesOfString:@" " withString:@""]length] > 0)
        {
            if([currentUser.userId caseInsensitiveCompare:@"guest"] == NSOrderedSame)
            {
                ServicesViewController *svc = [storyBoard instantiateViewControllerWithIdentifier:@"ServicesStoryView"];
                [navController setViewControllers:@[svc] animated: NO];
            }
            
            else if ([currentUser.isUserTypeClient boolValue])
            {
                if (indexPath.row == 0) {//Select Servcie page
                    ServicesViewController *svc = [storyBoard instantiateViewControllerWithIdentifier:@"ServicesStoryView"];
                    [navController setViewControllers:@[svc] animated: NO];
                }
                else if (indexPath.row == 1) {//PROFILE
                    SettingsViewController *svc = [storyBoard instantiateViewControllerWithIdentifier:@"SettingsSB"];
                    [navController setViewControllers: @[svc] animated: NO];
                }
                else if (indexPath.row == 2) {//FAQ's
                    
                }
                else if (indexPath.row == 3) {//Messages
                    
                }
                else if (indexPath.row == 4) {//Favorites
                    FavouritiesViewController *svc = [storyBoard instantiateViewControllerWithIdentifier:@"FavouritiesViewControllerSB"];
                    [navController setViewControllers: @[svc] animated: NO];
                }
                else if (indexPath.row == 5) {//History
                    
                }
            }
            
            else
            {
                if (indexPath.row == 0) {//Schedule
                    SetScheduleViewController *svc = [storyBoard  instantiateViewControllerWithIdentifier:@"SetScheduleViewControllerSB"];
                    [navController setViewControllers: @[svc] animated: NO ];
                }
                else if (indexPath.row == 1) {//MyAppointments
                    AppointmentsViewController *svc = [storyBoard  instantiateViewControllerWithIdentifier:@"AppointmentsViewControllerSB"];
                    [navController setViewControllers: @[svc] animated: NO ];
                }
                else if (indexPath.row == 2) {//PROFILE
                    UpdateProfileViewController *svc = [storyBoard  instantiateViewControllerWithIdentifier:@"UpdateProfileViewControllerSB"];
                    [navController setViewControllers: @[svc] animated: NO ];
                }
                else if (indexPath.row == 3) {//Messages
                    
                }
                else if (indexPath.row == 4) {//History
                    
                }
            }
        }
    }
    
    else if (indexPath.row == 0) {//Select Servcie page
        ServicesViewController *svc = [storyBoard instantiateViewControllerWithIdentifier:@"ServicesStoryView"];
        [navController setViewControllers:@[svc] animated: NO];
    }
    
    [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
}

- (void)logOut
{
    //remove user details from local and DB
    NSArray *firstLoad= [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:nil andSortDescriptor:nil forContext:nil];
    if([firstLoad count] > 0) {
        [[CoreDataModel sharedCoreDataModel]deleteEntityObject:[firstLoad objectAtIndex:0] withContext:nil];
    }
    
    [[CoreDataModel sharedCoreDataModel]saveContext];
    [UserAccount removeSharedInstance];
    [StylistAccount removeSharedInstance];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
    //[self.delegate loginButtonDidLogOut:self];
    
    /*HomeViewController *hvc = [storyBoard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    [navController setViewControllers: @[hvc] animated: NO];
    [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];*/
    
    LoginViewController *lvc = [storyBoard instantiateViewControllerWithIdentifier:@"LoginSB"];
    [navController setViewControllers: @[lvc] animated: NO];
    [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
}

// To check if user logouts out from Facebook
/*- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"fbUserName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}*/

@end