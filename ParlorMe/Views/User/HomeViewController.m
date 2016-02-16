
//  HomeViewController.m
//  ParlorMe

#import "HomeViewController.h"
#import "LoginViewController.h"
#import "SWRevealViewController.h"
#import "JoinParlorViewController.h"
#import "CoreDataModel.h"
#import "User.h"
#import "UserAccount.h"
#import "StylistAccount.h"
#import "ServicesViewController.h"
#import "SingletonClass.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UIButton *signInBtn;
@property (weak, nonatomic) IBOutlet UIButton *signUpBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoTopHeightContant;

@end

@implementation HomeViewController

#pragma-mark  View Lifecycle Related Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    //add gesture to view, to open the left menu
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    //add border to sign in button
    self.signInBtn.layer.borderWidth = 2.0;
    self.signInBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    //check for iphone4 screen and reduce the LOGO height by 20
    if ([UIScreen mainScreen].bounds.size.height <= 568) {
        self.logoTopHeightContant.constant = self.logoTopHeightContant.constant - 10.0;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Hide the Navigation bar
    self.navigationController.navigationBarHidden = YES;
    //check for user exists in DB
    [self checkUsersInDB];
}

#pragma mark ButtonActions
- (IBAction)buttonActions:(UIButton *)sender
{
    if (sender.tag == 1) {//sign in
        
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logOut];
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *lvc = [storyBoard instantiateViewControllerWithIdentifier:@"LoginSB"];
        [self.navigationController pushViewController:lvc animated:NO];
    }
    
    else if (sender.tag == 2) {//sign up
        
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logOut];
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        JoinParlorViewController *joinParlorViewController = [storyBoard instantiateViewControllerWithIdentifier:@"JoinParlorSB"];
        joinParlorViewController.delegate = self;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:joinParlorViewController];
        [self presentViewController:navController animated:YES completion:nil];
    }
}

#pragma mark CheckUser
- (void)checkUsersInDB {
    NSArray *userRecords = [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:nil andSortDescriptor:nil forContext:nil];
    
    if(userRecords.count > 0)
    {
        User *currentUser = [userRecords objectAtIndex:0];
        
        if ([currentUser.isUserTypeClient boolValue])
        {
            UserAccount *userAccount = [UserAccount sharedInstance];
            userAccount.userId = currentUser.userId;
            userAccount.accessToken = currentUser.accessToken;
            userAccount.isUserTypeClient = [currentUser.isUserTypeClient boolValue];
        }
        
        else
        {
            StylistAccount *stylistAccount = [StylistAccount sharedInstance];
            stylistAccount.userId = currentUser.userId;
            stylistAccount.accessToken = currentUser.accessToken;
        }	
        
        if([[[SingletonClass shareManager]directSignUp] isEqualToString:@"YES"])
        {
            [[SingletonClass shareManager]setDirectSignUp:@"NO"];
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ServicesViewController *svc = [storyBoard  instantiateViewControllerWithIdentifier:@"ServicesStoryView"];
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[svc] animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        }
        
        self.signInBtn.hidden = YES;
        self.signUpBtn.hidden = YES;
    }
    
    else
    {
        self.signInBtn.hidden = NO;
        self.signUpBtn.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
