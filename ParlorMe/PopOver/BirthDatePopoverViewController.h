//
//  BirthDatePopoverViewController.h
//  ParlorMe
//

#import <UIKit/UIKit.h>

@protocol BirthdatePopOverDelegate <NSObject>

- (void)dismissPopOverView:(NSString *)dateOfBirth;

@end

@interface BirthDatePopoverViewController: UIViewController

@property (weak, nonatomic) IBOutlet UIDatePicker *birthDatePicker;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property(nonatomic,retain)id delegate;

@end
