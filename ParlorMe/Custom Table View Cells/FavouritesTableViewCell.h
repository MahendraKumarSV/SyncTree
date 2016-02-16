//
//  FavouritesTableViewCell.h
//  ParlorMe
//

#import <UIKit/UIKit.h>
#import <AsyncImageView/AsyncImageView.h>

@interface FavouritesTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet AsyncImageView *stylistImage;
@property (strong, nonatomic) IBOutlet UILabel *stylistLocation;
@property (strong, nonatomic) IBOutlet UILabel *stylistExperience;
@property (strong, nonatomic) IBOutlet UILabel *stylistName;
@property (strong, nonatomic) IBOutlet UIButton *stylistFees;
@property (strong, nonatomic) IBOutlet UIButton *favoritiesImage;
@property (strong, nonatomic) IBOutlet UIButton *gotoStylistProfileButton;
@property (strong, nonatomic) IBOutlet UIButton *favoritiesTransBtn;

@end
