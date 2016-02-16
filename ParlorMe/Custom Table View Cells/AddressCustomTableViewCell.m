//
//  AddressCustomTableViewCell.m
//  ParlorMe
//

#import "AddressCustomTableViewCell.h"

@implementation AddressCustomTableViewCell

- (void)awakeFromNib
{
    //UI Customization
    _primaryAddressButton.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    _primaryAddressButton.layer.borderWidth = 1.0f;
    _secondaryAddressButton.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    _secondaryAddressButton.layer.borderWidth = 1.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
