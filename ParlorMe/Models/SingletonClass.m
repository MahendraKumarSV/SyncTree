//
//  SingletonClass.m
//  ParlorMe
//

#import "SingletonClass.h"
#import "Constants.h"

@implementation SingletonClass
@synthesize dropDownBoolValue, appoinmentNotification, getPartnerScheduleResponse, updateScheduleStatusCode, tempRepeatedDaysArray, fetchServicesFromResponse, productAdded, directSignUp;

+(SingletonClass*)shareManager
{
    static SingletonClass *sharedInstance = nil;
    static dispatch_once_t  oncePredecate;
    
    dispatch_once(&oncePredecate,^{
        sharedInstance = [[SingletonClass alloc] init];
        
    });
    
    return sharedInstance;
}

-(void)showBackBtn:(UIViewController *)vc
{
    curentVC = vc;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnImg = [UIImage imageNamed:@"backArrow"];
    [btn setImage:btnImg forState:UIControlStateNormal];
    [btn setImage:btnImg forState:UIControlStateSelected];
    
    btn.frame = CGRectMake(-20, 0, 30, 22);
    [btn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];    
    vc.navigationController.navigationBarHidden = NO;
    vc.navigationController.navigationItem.hidesBackButton = YES;
}

- (void)goBack
{
    [curentVC.navigationController popViewControllerAnimated:NO];
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        //Strings
        productAdded = [[NSString alloc]init];
        
        //Dictionaries
        getPartnerScheduleResponse = [[NSDictionary alloc]init];
        
        //Arrays
        fetchServicesFromResponse = [[NSMutableArray alloc]init];
    }
    
    return self;
}

@end
