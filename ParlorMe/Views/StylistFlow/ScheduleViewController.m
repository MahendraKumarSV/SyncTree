//
//  ScheduleViewController.m
//  ParlorMe
//

#import "ScheduleViewController.h"
#import "SetScheduleViewController.h"
#import "AppointmentsViewController.h"
#import "UpdateProfileViewController.h"
#import "Constants.h"
#import <LatoFont/UIFont+Lato.h>
#import "SingletonClass.h"

@interface ScheduleViewController ()<UITabBarControllerDelegate>
{
    CGFloat  buttonWidth;
    UITabBarController *tabbarController;
    CGFloat tabBarTitleFont;
}

@end

@implementation ScheduleViewController
@synthesize updatedProfile;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = true;
    buttonWidth = self.view.frame.size.width/3;
    
    tabbarController = [[UITabBarController alloc] init];
    self.tabBarController.delegate = self;
    tabbarController.tabBar.frame = CGRectMake(0, 0, self.view.frame.size.width, tabbarController.tabBar.frame.size.height);
    [[UITabBar appearance] setBarTintColor:DashedLineRGBColor(228, 199, 194)];
    
    //Change the x position of tabbar title
    [UITabBarItem appearance].titlePositionAdjustment = UIOffsetMake(5, 0);
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
    //Tabbar title font according to screen Height
    if(screenHeight <= IS_iPhone4SOR5)
    {
        tabBarTitleFont = 17.0;
    }
    
    else if(screenHeight == IS_iPhone6 || screenHeight == IS_iPhone6Plus)
    {
        tabBarTitleFont = 20.0;
    }
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Lato-LightItalic" size:tabBarTitleFont], NSFontAttributeName, [UIColor darkGrayColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Lato-Black" size:tabBarTitleFont], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName,nil] forState:UIControlStateSelected];
    
    UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    SetScheduleViewController *setScheduleView = [aStoryboard instantiateViewControllerWithIdentifier:@"SetScheduleViewControllerSB"];
    setScheduleView.title = @"Set Schedule";
    setScheduleView.tabBarItem.tag = 0;
    
    AppointmentsViewController *appointmentsView = [aStoryboard instantiateViewControllerWithIdentifier:@"AppointmentsViewControllerSB"];
    appointmentsView.title = @"     Appointments";
    appointmentsView.tabBarItem.tag = 1;
    
    UpdateProfileViewController *profileView = [aStoryboard instantiateViewControllerWithIdentifier:@"UpdateProfileViewControllerSB"];
    profileView.title = @"    Profile";
    profileView.tabBarItem.tag = 2;
    
    tabbarController.viewControllers =  [NSArray arrayWithObjects:setScheduleView, appointmentsView, profileView, nil];
    [self addChildViewController:tabbarController];
    [self.view addSubview:tabbarController.view];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    SingletonClass *sharedObj = [SingletonClass shareManager];
    
    if([updatedProfile isEqualToString:@"YES"])
    {
        [tabbarController setSelectedIndex:2];
        updatedProfile = @"NO";
    }
    
    else if (sharedObj.appoinmentNotification == YES)
    {
        [tabbarController setSelectedIndex:1];
        updatedProfile = @"NO";
        [sharedObj setAppoinmentNotification:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
