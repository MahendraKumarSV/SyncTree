//
//  RateViewController.m
//  ParlorMe
//

#import "RateViewController.h"
#import "UserAccount.h"

@interface RateViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *stylistImageView;
@property (weak, nonatomic) IBOutlet UIButton *tenPercentButton;
@property (weak, nonatomic) IBOutlet UIButton *fifteenPercentButton;
@property (weak, nonatomic) IBOutlet UIButton *twentyPercentButton;
@property (weak, nonatomic) IBOutlet UIButton *tipButton;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@end

@implementation RateViewController

#pragma mark -View Life Cycle Related Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // to hide nabvigation bar
    self.navigationController.navigationBarHidden = true;
    
    // to make imageview circular
    self.stylistImageView.layer.cornerRadius = self.stylistImageView.frame.size.width/2;
    self.stylistImageView.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.stylistImageView.layer.borderWidth = 2.0f;
    self.stylistImageView.clipsToBounds = YES;
    
    // to change UI of Tip Button
    self.tipButton.layer.cornerRadius = 5.0f;
    self.tipButton.layer.borderWidth = 1.0f;
    self.tipButton.layer.borderColor = [[UIColor colorWithRed:221/255.0f green:40/255.0f blue:48/255.0f alpha:1]CGColor ];
    
    //to change UI of Finish Button
    self.finishButton.layer.cornerRadius = 5.0f;
    self.finishButton.layer.borderWidth = 1.0f;
    self.finishButton.layer.borderColor = [[UIColor colorWithRed:242/255.0f green:93/255.0f blue:95/255.0f alpha:1]CGColor ];
    
    // to change UI of Skip button
    self.skipButton.layer.cornerRadius = 5.0f;
    self.skipButton.layer.borderWidth = 1.0f;
    self.skipButton.layer.borderColor = [[UIColor colorWithRed:242/255.0f green:93/255.0f blue:95/255.0f alpha:1]CGColor ];
    
    // to change UI of tenPercent button
    self.tenPercentButton.layer.borderWidth = 1.0f;
    self.tenPercentButton.layer.borderColor = [[UIColor colorWithRed:39/255.0f green:40/255.0f blue:41/255.0f alpha:1]CGColor ];
    
    // to change UI of fifteenPercent button
    self.fifteenPercentButton.layer.borderWidth = 1.0f;
    self.fifteenPercentButton.layer.borderColor = [[UIColor colorWithRed:39/255.0f green:40/255.0f blue:41/255.0f alpha:1]CGColor ];
    
    // to change UI of twentyPercent button
    self.twentyPercentButton.layer.borderWidth = 1.0f;
    self.twentyPercentButton.layer.borderColor = [[UIColor colorWithRed:39/255.0f green:40/255.0f blue:41/255.0f alpha:1]CGColor ];
    
    // To Change color of Status Bar
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
