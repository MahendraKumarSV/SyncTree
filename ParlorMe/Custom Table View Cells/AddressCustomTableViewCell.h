//
//  AddressCustomTableViewCell.h
//  ParlorMe
//

#import <UIKit/UIKit.h>

@interface AddressCustomTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *noAddressMsgLabel;
@property (strong, nonatomic) IBOutlet UIButton *primaryAddressButton;
@property (strong, nonatomic) IBOutlet UIButton *secondaryAddressButton;

@end
