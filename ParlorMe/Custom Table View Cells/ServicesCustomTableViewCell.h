//
//  ServicesCustomTableViewCell.h
//  ParlorMe
//

#import <UIKit/UIKit.h>

@interface ServicesCustomTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *subCategoryBtn1;
@property (weak, nonatomic) IBOutlet UIButton *subCategoryBtn2;
@property (weak, nonatomic) IBOutlet UIButton *subCategoryBtn3;
@property (weak, nonatomic) IBOutlet UIButton *subCategoryBtn4;

@property (weak, nonatomic) IBOutlet UILabel *subCategoryLbl1;
@property (weak, nonatomic) IBOutlet UILabel *subCategoryLbl2;
@property (weak, nonatomic) IBOutlet UILabel *subCategoryLbl3;
@property (weak, nonatomic) IBOutlet UILabel *subCategoryLbl4;

@property (weak, nonatomic) IBOutlet UIButton *checkCategoryBtn1;
@property (weak, nonatomic) IBOutlet UIButton *checkCategoryBtn2;
@property (weak, nonatomic) IBOutlet UIButton *checkCategoryBtn3;
@property (weak, nonatomic) IBOutlet UIButton *checkCategoryBtn4;

@property (weak, nonatomic) IBOutlet UIButton *findBtn;
@property (weak, nonatomic) IBOutlet UIButton *servicesBtn;


- (IBAction)subCategoryBtnTapped:(id)sender;

@end
