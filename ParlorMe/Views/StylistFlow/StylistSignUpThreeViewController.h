//
//  StylistSignUpViewController.h
//  ParlorMe
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol StylistSignUpThreeViewControllerDelegate <NSObject>

- (void)changeImage:(UIImage *)stylistLicense andImage:(UIImage *)driverLicense;
- (void)changeSSN:(NSString *)ssnFrontStr andSSNMiddle:(NSString *)ssnMiddleStr  andSSNLast:(NSString *)ssnLastStr  andZipCode:(NSString *)zipCodeStr;

@end

@interface StylistSignUpThreeViewController : UIViewController

@property (strong, nonatomic)  NSMutableArray *basicInfoList;
@property (strong,nonatomic)   UIImage *stylistDriverLicensephoto;
@property (strong,nonatomic)   UIImage *stylistLicensephoto;
@property (strong, nonatomic)  NSString *zipCode;
@property (strong, nonatomic)  NSString *ssnFront;
@property (strong, nonatomic)  NSString *ssnMiddle;
@property (strong, nonatomic)  NSString *ssnLast;

@property (nonatomic, weak) id delegate;

@end
