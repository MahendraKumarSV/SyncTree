//
//  AppDelegate.m
//  ParlorMe
//

#import "AppDelegate.h"
#import <Braintree/Braintree.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "CoreDataModel.h"
#import "UserAccount.h"
#import "StylistAccount.h"
#import "ScheduleViewController.h"
#import "SingletonClass.h"
#import "StylistLoginViewController.h"
#import <HockeySDK/HockeySDK.h>
#import "LoginViewController.h"

@interface AppDelegate ()<BITHockeyManagerDelegate>

@end

@implementation AppDelegate

+ (void)initialize
{
    // Nib files require the type to have been loaded before they can do the wireup successfully.
    [FBSDKLoginButton class];
    [FBSDKProfilePictureView class];
    [FBSDKSendButton class];
    [FBSDKShareButton class];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // To delete Guest user Details if present in DB
    //[self deleteGuestUser];
    
    /*[[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"488dc584bc4f4a0d8588acc0aed33c3c"];
    [[BITHockeyManager sharedHockeyManager] setDelegate: self];

    // Do some additional configuration if needed here
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation]; // This line is obsolete in the crash only builds
    [[BITHockeyManager sharedHockeyManager].crashManager setCrashManagerStatus: BITCrashManagerStatusAutoSend];
    [[BITHockeyManager sharedHockeyManager].crashManager setEnableMachExceptionHandler: YES];
    [[BITHockeyManager sharedHockeyManager] startManager];*/
    
    // To set URL scheme
    [Braintree setReturnURLScheme:@"com.dreamorbit.ParlorMe.payments"];
    
    // To set URL scheme
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    
    /*if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"notf"] != nil)
    {
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults]objectForKey:@"notf"];
        NSLog(@"dict: %@",dict);
                
        StylistAccount *stylistAccount = [StylistAccount sharedInstance];
        stylistAccount.stylistAppointmentNotificationDictionary = dict;
    }*/
    
    //[[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithRed:229/255.0 green:199/255.0 blue:194/255.0 alpha:1]];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor lightGrayColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:@"Lato-Bold" size:20]}];
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // Check if the url seheme belongs to Facebook Application
    if ([[url scheme] isEqualToString:@"fb1606518322957172"])
    {
        // open Facebook URL
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
    }
    // Check if the url seheme belongs to Braintree Application
    else
    {
        // Open Braintree URL
        return [Braintree handleOpenURL:url sourceApplication:sourceApplication];
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    if (notificationSettings.types != UIUserNotificationTypeNone)
    {
        //NSLog(@"didRegisterUser");
        [application registerForRemoteNotifications];
    }
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    StylistAccount *stylistAccount = [StylistAccount sharedInstance];
    stylistAccount.stylistAppointmentNotificationDictionary = userInfo;
    
    [[NSUserDefaults standardUserDefaults]setObject:userInfo forKey:@"notf"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    SingletonClass *sharedObj = [SingletonClass shareManager];
    [sharedObj setAppoinmentNotification:YES];
    
    StylistAccount *stylistAC = [StylistAccount sharedInstance];
    
    if(stylistAC.accessToken.length > 0)
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ScheduleViewController *scheduleViewController = [storyBoard  instantiateViewControllerWithIdentifier:@"ScheduleViewControllerSB"];
        [(UINavigationController *)self.window.rootViewController pushViewController:scheduleViewController animated:NO];
    }
    
    else if (stylistAC.accessToken == nil || stylistAC.accessToken.length == 0)
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        StylistLoginViewController *stylistLoginViewController = [storyBoard  instantiateViewControllerWithIdentifier:@"StylistLoginSB"];
        [(UINavigationController *)self.window.rootViewController pushViewController:stylistLoginViewController animated:NO];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    UserAccount *userAccount = [UserAccount sharedInstance];
    userAccount.deviceToken = token;
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    //NSLog(@"Error: %@",error.localizedDescription);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// To delete data of Guest User from Data Base
- (void)deleteGuestUser
{
    //check for Guest User and delete from DB, each time when app launches
    NSArray *firstLoad= [[CoreDataModel sharedCoreDataModel] arrayOfRecordsForEntity:@"User" andPredicate:[NSPredicate predicateWithFormat:@"userId == %@", @"Guest"] andSortDescriptor:nil forContext:nil];
    
    if( [firstLoad count] > 0 )
    {
        [[CoreDataModel sharedCoreDataModel]deleteEntityObject:[firstLoad objectAtIndex:0] withContext:nil];
    }
    [[CoreDataModel sharedCoreDataModel]saveContext];
}

@end
