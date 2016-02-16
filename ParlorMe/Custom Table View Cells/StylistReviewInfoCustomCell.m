//
//  StylistReviewInfoCustomCell.m
//  ParlorMe
//

#import "StylistReviewInfoCustomCell.h"

@implementation StylistReviewInfoCustomCell

- (void)awakeFromNib
{
    //UI Customization  
    self.imageViewBtn.layer.borderColor = [[UIColor blackColor]CGColor];
    self.imageViewBtn.layer.borderWidth = 1.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
