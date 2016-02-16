//
//  ServicesCustomTableViewCell.m
//  ParlorMe
//

#import "ServicesCustomTableViewCell.h"

@implementation ServicesCustomTableViewCell

- (void)awakeFromNib
{
    //UI Customization
    _subCategoryBtn1.hidden = NO;
    _subCategoryBtn2.hidden = NO;
    _subCategoryBtn3.hidden = NO;
    _subCategoryBtn4.hidden = NO;
    
    _subCategoryLbl1.hidden = NO;
    _subCategoryLbl2.hidden = NO;
    _subCategoryLbl3.hidden = NO;
    _subCategoryLbl4.hidden = NO;
    
    _checkCategoryBtn1.hidden = NO;
    _checkCategoryBtn2.hidden = NO;
    _checkCategoryBtn3.hidden = NO;
    _checkCategoryBtn4.hidden = NO;
    
    _subCategoryLbl1.adjustsFontSizeToFitWidth = YES;
    _subCategoryLbl2.adjustsFontSizeToFitWidth = YES;
    _subCategoryLbl3.adjustsFontSizeToFitWidth = YES;
    _subCategoryLbl4.adjustsFontSizeToFitWidth = YES;
    
    _findBtn.hidden = NO;
    _servicesBtn.hidden = NO;
    
    _subCategoryLbl1.numberOfLines = 2;
    _subCategoryLbl2.numberOfLines = 2;
    _subCategoryLbl3.numberOfLines = 2;
    _subCategoryLbl4.numberOfLines = 2;
    
    _subCategoryBtn1.backgroundColor = [UIColor clearColor];
    _subCategoryBtn2.backgroundColor = [UIColor clearColor];
    _subCategoryBtn3.backgroundColor = [UIColor clearColor];
    _subCategoryBtn4.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (IBAction)subCategoryBtnTapped:(id)sender
{
    
}

@end
