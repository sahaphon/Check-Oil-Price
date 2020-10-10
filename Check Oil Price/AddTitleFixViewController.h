//
//  AddTitleFixViewController.h
//  Check Oil Price
//
//  Created by Sahaphon_mac on 1/31/18.
//  Copyright © 2018 rich_noname. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTImageButton.h"
#import "sqlite3.h"

@interface AddTitleFixViewController : UIViewController <UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate>

@property(strong,nonatomic) NSString *databasePath;
@property(nonatomic) sqlite3 *db;
@property (weak, nonatomic) IBOutlet JTImageButton *btnAdd;
@property (weak, nonatomic) IBOutlet JTImageButton *btnDel;


@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (weak, nonatomic) IBOutlet UITextField *txtName;


- (IBAction)btnAdd:(id)sender;
- (IBAction)btnDel:(id)sender;

@end
