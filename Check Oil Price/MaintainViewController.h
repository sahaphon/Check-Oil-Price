//
//  MaintainViewController.h
//  Check Oil Price
//
//  Created by Sahaphon_mac on 1/30/18.
//  Copyright © 2018 rich_noname. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTImageButton.h"
#import "sqlite3.h"

@class AbstractActionSheetPicker;
@interface MaintainViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate>

@property(strong,nonatomic) NSString *databasePath;
@property(nonatomic) sqlite3 *db;

@property (nonatomic, strong) AbstractActionSheetPicker *actionSheetPicker;
@property (weak, nonatomic) IBOutlet JTImageButton *btnSelcTitle;
@property (weak, nonatomic) IBOutlet JTImageButton *btnAddTitle;
@property (weak, nonatomic) IBOutlet JTImageButton *btnDateSelc;
@property (weak, nonatomic) IBOutlet JTImageButton *btnSave;
@property (weak, nonatomic) IBOutlet JTImageButton *btnCancel;

@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UITextField *txtCarNo;
@property (weak, nonatomic) IBOutlet UILabel *lblFixTitle;
@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (weak, nonatomic) IBOutlet UITextField *txtPrice;
@property (weak, nonatomic) IBOutlet UITextView *txtView;
@property (nonatomic, strong) NSDate *selectedDate;

- (IBAction)btnDateSelc:(id)sender;
- (IBAction)btnSelcTitle:(id)sender;
- (IBAction)btnAddTitle:(id)sender;
- (IBAction)btnSave:(id)sender;
- (IBAction)btnCancel:(id)sender;

@end
