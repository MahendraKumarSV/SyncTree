//
//  FavouritesTableViewCell.m
//  ParlorMe
//

#import "FavouritesTableViewCell.h"

@implementation FavouritesTableViewCell

- (void)awakeFromNib
{
    //UI Customization
    // Making imageview circular
    self.stylistImage.layer.cornerRadius = self.stylistImage.frame.size.width/2;
    self.stylistImage.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    self.stylistImage.layer.borderWidth = 1.0f;
    self.stylistImage.clipsToBounds = YES;
    
    // providing border to dollar button
    self.stylistFees.layer.borderColor = [[UIColor blackColor]CGColor];
    self.stylistFees.layer.borderWidth = 1.0f;
    self.stylistFees.layer.cornerRadius = 3.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
