//
//  MaintainViewController.m
//  Check Oil Price
//
//  Created by Sahaphon_mac on 1/30/18.
//  Copyright © 2018 rich_noname. All rights reserved.
//

#import "MaintainViewController.h"
#import "JTImageButton.h"
#import "ActionSheetPicker.h"
#import "AddTitleFixViewController.h"

@interface MaintainViewController ()
{
    NSMutableArray *myObject;
    NSMutableArray *myTitle;
    NSMutableArray *mySection;
    NSMutableArray *myary;

    NSDictionary *dict;
    NSString *docDIR;
    NSArray *dirPath;
}
@end

@implementation MaintainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor],
       NSFontAttributeName:[UIFont fontWithName:@"PSL Display" size:28]}];
    
    [_txtPrice setKeyboardType:UIKeyboardTypeDecimalPad]; //กดได้เฉพาะตัวเลข UIKeyboardTypeNumberPad
    myObject = [[NSMutableArray alloc]init];
    myTitle = [[NSMutableArray alloc]init];
    mySection = [[NSMutableArray alloc]init];
    
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docDIR = dirPath[0];
    
    //สร้าง part เชื่อมโยงไปยังฐานข้อมูล
    _databasePath = [[NSString alloc] initWithString:[docDIR stringByAppendingPathComponent:@"Oil.db"]];  //ย้ายมารวมไว้ใน consign
     //NSLog(@"PATH :%@", _databasePath);
    
    [self CreateDatabase];
    [self GetStringSection];
    [self ReloadData];
    [_myTable reloadData];
    
    //เลื่อนไปที่ last rocord
    [self performSelector:@selector(goToBottom) withObject:nil afterDelay:1.0];

    
    NSDate  *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSString *dateString = [dateFormat stringFromDate:today];
    _lblDate.text = dateString;
    
    _lblFixTitle.layer.borderColor = [UIColor blackColor].CGColor;
    _lblFixTitle.layer.borderWidth = 1.0;
    _lblFixTitle.layer.cornerRadius = 2.0;
    
    _lblDate.layer.borderColor = [UIColor blackColor].CGColor;
    _lblDate.layer.borderWidth = 1.0;
    _lblDate.layer.cornerRadius = 2.0;
    
    _txtCarNo.layer.borderColor = [UIColor blackColor].CGColor;
    _txtCarNo.layer.borderWidth = 1.0;
    _txtCarNo.layer.cornerRadius = 2.0;
    
    _txtView.layer.borderColor = [UIColor blackColor].CGColor;
    _txtView.layer.borderWidth = 1.0;
    _txtView.layer.cornerRadius = 2.0;
    
    //icons8-checked-20
    [self.btnSelcTitle createTitle:@"เลือก" withIcon:[UIImage imageNamed:@"icons8-checked-20"] font:[UIFont fontWithName:@"PSL Display" size:16] iconHeight:JTImageButtonIconHeightDefault iconOffsetY:JTImageButtonIconOffsetYNone];
    self.btnSelcTitle.titleColor = UIColor.blackColor;
    self.btnSelcTitle.iconColor =  UIColor.blueColor;
    self.btnSelcTitle.padding = JTImageButtonPaddingMedium;
    self.btnSelcTitle.cornerRadius = 2.0;
    self.btnSelcTitle.borderWidth = 1.0;
    self.btnSelcTitle.borderColor = UIColor.blueColor;
    self.btnSelcTitle.iconSide = JTImageButtonIconSideRight;
    
    
    [self.btnAddTitle createTitle:@"เพิ่ม" withIcon:[UIImage imageNamed:@"icons8-plus-20"] font:[UIFont fontWithName:@"PSL Display" size:16] iconHeight:JTImageButtonIconHeightDefault iconOffsetY:JTImageButtonIconOffsetYNone];
    self.btnAddTitle.titleColor = UIColor.blackColor;
    self.btnAddTitle.iconColor =  UIColor.blueColor;
    self.btnAddTitle.padding = JTImageButtonPaddingMedium;
    self.btnAddTitle.cornerRadius = 2.0;
    self.btnAddTitle.borderWidth = 1.0;
    self.btnAddTitle.borderColor = UIColor.blueColor;
    self.btnAddTitle.iconSide = JTImageButtonIconSideLeft;
    
    
    [self.btnSave createTitle:@"บันทึก" withIcon:[UIImage imageNamed:@"icons8-save-20"] font:[UIFont fontWithName:@"PSL Display" size:16] iconHeight:JTImageButtonIconHeightDefault iconOffsetY:JTImageButtonIconOffsetYNone];
    self.btnSave.titleColor = UIColor.blackColor;
    self.btnSave.iconColor =  UIColor.blueColor;
    self.btnSave.padding = JTImageButtonPaddingMedium;
    self.btnSave.cornerRadius = 2.0;
    self.btnSave.borderWidth = 1.0;
    self.btnSave.borderColor = UIColor.blueColor;
    self.btnSave.iconSide = JTImageButtonIconSideLeft;
    
    
    [self.btnCancel createTitle:@"ยกเลิก" withIcon:[UIImage imageNamed:@"icons8-cancel-20"] font:[UIFont fontWithName:@"PSL Display" size:16] iconHeight:JTImageButtonIconHeightDefault iconOffsetY:JTImageButtonIconOffsetYNone];
    self.btnCancel.titleColor = UIColor.blackColor;
    self.btnCancel.iconColor =  UIColor.blueColor;
    self.btnCancel.padding = JTImageButtonPaddingMedium;
    self.btnCancel.cornerRadius = 2.0;
    self.btnCancel.borderWidth = 1.0;
    self.btnCancel.borderColor = UIColor.blueColor;
    self.btnCancel.iconSide = JTImageButtonIconSideLeft;
    
    
    [self.btnDateSelc createTitle:nil withIcon:[UIImage imageNamed:@"icons8-calendar-20"] font:[UIFont fontWithName:@"PSL Display" size:16] iconHeight:JTImageButtonIconHeightDefault iconOffsetY:JTImageButtonIconOffsetYNone];
    self.btnDateSelc.titleColor = UIColor.blackColor;
    self.btnDateSelc.iconColor =  UIColor.blueColor;
    self.btnDateSelc.padding = JTImageButtonPaddingMedium;
    self.btnDateSelc.cornerRadius = 2.0;
    self.btnDateSelc.borderWidth = 1.0;
    self.btnDateSelc.borderColor = UIColor.blueColor;
    self.btnDateSelc.iconSide = JTImageButtonIconSideLeft;
}

//กำหนด style section header
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(20, 8, 320, 20);
    myLabel.font =  [UIFont fontWithName: @"PSL Display" size: 18.0];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    myLabel.backgroundColor = [UIColor lightGrayColor];
    myLabel.textColor = [UIColor whiteColor];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [mySection count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [mySection objectAtIndex:section];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = 0;
    NSString *sectionTitle = [mySection objectAtIndex:section];
    num = [self GetRowsInSection:sectionTitle];
    
     if ([myObject count] == 0)
     {
         num = 1;
     }
     else
     {
        //หาจำนวน Rows ใน section
        num = [self GetRowsInSection:sectionTitle];
     }
    
    return num;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger nbCount = [myObject count];
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    }
    
    UILabel *lblNo = (UILabel *) [cell viewWithTag: 101];
    UILabel *lblDate2 = (UILabel *) [cell viewWithTag: 102];
    UILabel *lblCar = (UILabel *) [cell viewWithTag: 103];
    UILabel *lblTitle2 = (UILabel *) [cell viewWithTag: 104];
    UILabel *lblDetail = (UILabel *) [cell viewWithTag: 105];
    UILabel *lblPrice = (UILabel *) [cell viewWithTag: 106];
    
    if (nbCount > 0)
    {
        NSDictionary *currentItem = myObject [indexPath.row];
        
        
        NSString *sectionTitle = [mySection objectAtIndex:indexPath.section];
        if ([currentItem[@"Month"] isEqualToString:sectionTitle])
        {
            lblNo.text =   currentItem[@"no"];
            lblDate2.text = currentItem[@"Date"];
            lblCar.text = currentItem[@"Car"];
            lblTitle2.text = [@"***" stringByAppendingString: currentItem[@"Title"]];
            lblDetail.text = currentItem[@"Detail"];
            
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
            NSString *numberAsString = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:[currentItem[@"Price"] floatValue]]];
            
            lblPrice.text = numberAsString;
        }
    }
    else
    {
        lblNo.text = @"";
        lblDate2.text = @"";
        lblCar.text = @"";
        lblTitle2.text = @"";
        lblDetail.text = @"";
        lblPrice.text = @"";
    }

    return cell;
}

- (IBAction)btnDateSelc:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIDatePicker *picker = [[UIDatePicker alloc] init];
    [picker setDatePickerMode:UIDatePickerModeDate];
    [alertController.view addSubview:picker];
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //NSDate  *today = [NSDate date];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"dd-MM-yyyy"];
            NSString *dateString = [dateFormat stringFromDate:picker.date];
            _lblDate.text = dateString;
        }];
        action;
    })];
    UIPopoverPresentationController *popoverController = alertController.popoverPresentationController;
    popoverController.sourceView = sender;
    popoverController.sourceRect = [sender bounds];
    [self presentViewController:alertController  animated:YES completion:nil];
}

- (IBAction)btnSelcTitle:(id)sender
{
    [self GetTitleVale];
    
    NSArray *array = [NSArray arrayWithArray:myTitle];
    
    [ActionSheetStringPicker showPickerWithTitle:@"กรุณาเลือกหัวข้อการซ่อม"
                                            rows:array
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           _lblFixTitle.text = [selectedValue description];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         _lblFixTitle.text = @"";
                                         //NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
}

-(void)GetTitleVale
{
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];  //กำหนดรูปเเบบเป็น UTF8
    
    if (sqlite3_open(dbpath, &_db) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT title FROM document"];
        const char *query_statment = [querySQL UTF8String]; //สั่งคิวรี่ข้อมูล fileSystemRepresentation
        
        if (sqlite3_prepare(_db, query_statment, -1, &statement, NULL) == SQLITE_OK)
        {
            [myTitle removeAllObjects];  //Clear all data
            
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                [myTitle addObject:[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)]];
                
            }
            
            sqlite3_finalize(statement);
        }
        
        sqlite3_close(_db);
    }
}

- (IBAction)btnAddTitle:(id)sender
{
     [self performSegueWithIdentifier:@"push" sender:self];
}

- (IBAction)btnSave:(id)sender
{
    if ([_txtCarNo.text length] > 0 && [_lblFixTitle.text length] > 0)
    {
        [self SaveData];
        _txtCarNo.text = @"";
        _lblFixTitle.text = @"";
        _txtView.text = @"";
        _txtPrice.text = @"";
        
        [self ReloadData];
        [_myTable reloadData];
        //เลื่อนไปที่ last rocord
        [self performSelector:@selector(goToBottom) withObject:nil afterDelay:1.0];
    }
    else
    {
        //ใช้แทน AlertView
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"เกิดข้อผิดพลาด!!"
                                     message:@"โปรดกรอกข้อมูลให้ครบ แล้วลองใหม่อีกครั้ง!"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"ตกลง"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                    }];
        
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

/*
-(void)ReloadData
{
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];  //กำหนดรูปเเบบเป็น UTF8
    
    if (sqlite3_open(dbpath, &_db) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT no, carno, title, detail, amt, fix_date, month FROM ma GROUP BY month ORDER BY month DESC"];
        const char *query_statment = [querySQL UTF8String]; //สั่งคิวรี่ข้อมูล fileSystemRepresentation
        
        if (sqlite3_prepare(_db, query_statment, -1, &statement, NULL) == SQLITE_OK)
        {
            [myObject removeAllObjects];  //Clear all data
            
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                  dict = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)], @"no",
                         [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)], @"Car",
                         [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 2)], @"Title",
                         [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 3)], @"Detail",
                         [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 4)], @"Price",
                         [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 5)], @"Date",
                         [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 6)], @"Month",
                        nil];
                
                  [myObject addObject:dict];
            }
            
            for (id x in myObject)
            {
                NSLog(@"%@", [x description]);
            }
            
            sqlite3_finalize(statement);
        }
        
        sqlite3_close(_db);
    }
}
*/

-(void)ReloadData
{
    sqlite3_stmt *statement, *statement2;
    const char *dbpath = [_databasePath UTF8String];  //กำหนดรูปเเบบเป็น UTF8
    NSString *str;
    
    if (sqlite3_open(dbpath, &_db) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT month FROM ma GROUP BY month ORDER BY month DESC"];
        const char *query_statment = [querySQL UTF8String]; //สั่งคิวรี่ข้อมูล fileSystemRepresentation
        
        if (sqlite3_prepare(_db, query_statment, -1, &statement, NULL) == SQLITE_OK)
        {
            [myObject removeAllObjects];  //Clear all data
            
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                str = @"";
                str = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
                
            
                //หารายการที่อยู่ในเดือน
                NSString *querySQL2 = [NSString stringWithFormat:@"SELECT no, carno, title, detail, amt, fix_date, month FROM ma WHERE month = /'%@/'", str];
                const char *query_statment2 = [querySQL2 UTF8String]; //สั่งคิวรี่ข้อมูล fileSystemRepresentation
                
                 if (sqlite3_prepare(_db, query_statment2, -1, &statement2, NULL) == SQLITE_OK)
                 {
                     while(sqlite3_step(statement2) == SQLITE_ROW)
                     {
                         for (int i = 1; i <= 10; i++)
                         {
                             NSLog(@"%d", i);
                         }
                         
                         [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)], @"no",
                         [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)], @"Car",
                         [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 2)], @"Title",
                         [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 3)], @"Detail",
                         [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 4)], @"Price",
                         [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 5)], @"Date",
                         [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 6)], @"Month";
                     }
                 }
            }
            
            for (id x in myObject)
            {
                NSLog(@"%@", [x description]);
            }
            
            sqlite3_finalize(statement);
        }
        
        sqlite3_close(_db);
    }
}
-(NSInteger)GetRowsInSection:(NSString *)str
{
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];  //กำหนดรูปเเบบเป็น UTF8
    NSInteger rows = 0;
    
    if (sqlite3_open(dbpath, &_db) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT month, COUNT(*) FROM ma WHERE month = \'%@\' GROUP BY month", str];
        const char *query_statment = [querySQL UTF8String]; //สั่งคิวรี่ข้อมูล fileSystemRepresentation
        //NSLog(@"%@", querySQL);
        
        if (sqlite3_prepare(_db, query_statment, -1, &statement, NULL) == SQLITE_OK)
        {
            [mySection removeAllObjects];  //Clear all data
            
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
               rows =  [[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)] integerValue];
            }
            
            sqlite3_finalize(statement);
        }
        
        sqlite3_close(_db);
    }
    
    return rows;
}

-(void)GetStringSection
{
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];  //กำหนดรูปเเบบเป็น UTF8
    
    if (sqlite3_open(dbpath, &_db) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT month, COUNT(*) FROM ma GROUP BY month"];
        const char *query_statment = [querySQL UTF8String]; //สั่งคิวรี่ข้อมูล fileSystemRepresentation
        
        if (sqlite3_prepare(_db, query_statment, -1, &statement, NULL) == SQLITE_OK)
        {
            [mySection removeAllObjects];  //Clear all data
            
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                [mySection addObject: [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)]];
            }
            
            sqlite3_finalize(statement);
        }
        
        sqlite3_close(_db);
    }
}
    
-(void)SaveData
{
    char *errMessage;
    const char *dbpath = [_databasePath UTF8String];
    NSString *strDocno =  [self GetIdNo];
    
    //วันที่ปัจจุบัน
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSString *nowDate = [dateFormat stringFromDate:[NSDate date]];
    
    if ([_txtPrice.text isEqualToString:@""])
    {
        _txtPrice.text = @"";
    }
    else
    {
        _txtPrice.text = [NSString stringWithFormat:@"%.2f",[_txtPrice.text floatValue]];
    }
    
    NSString *month = [_lblDate.text substringWithRange:NSMakeRange(3, 2)];
    NSString *syear = [_lblDate.text substringWithRange:NSMakeRange(6, 4)];
    
    if ([month isEqualToString:@"01"])
    {
        month = @"มกราคม ";
    }
    else if ([month isEqualToString:@"02"])
    {
        month = @"กุมภาพันธ์ ";
    }
    else if ([month isEqualToString:@"03"])
    {
        month = @"มีนาคม ";
    }
    else if ([month isEqualToString:@"04"])
    {
        month = @"เมษายน ";
    }
    else if ([month isEqualToString:@"05"])
    {
        month =@"พฤษภาคม ";
    }
    else if ([month isEqualToString:@"06"])
    {
        month = @"มิถุนายน ";
    }
    else if ([month isEqualToString:@"07"])
    {
        month = @"กรกฎาคม ";
    }
    else if ([month isEqualToString:@"08"])
    {
        month = @"สิงหาคม ";
    }
    else if ([month isEqualToString:@"09"])
    {
        month = @"กันยายน ";
    }
    else if ([month isEqualToString:@"10"])
    {
        month = @"ตุลาคม ";
    }
    else if ([month isEqualToString:@"11"])
    {
        month =@"พฤศจิกายน ";
    }
    else
    {
        month = @"ธันวาคม ";
    }
    
    month = [month stringByAppendingString:syear]; //เก็บเดือน ปี
    
    if (sqlite3_open(dbpath, &_db) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO ma(no, carno, title, detail, amt, fix_date, month, predate) VALUES (\'%@\',\'%@\',\'%@\',\'%@\',\'%@\',\'%@\',\'%@\',\'%@\')"
                                               , strDocno
                                               , _txtCarNo.text
                                               , _lblFixTitle.text
                                               , _txtView.text
                                               , _txtPrice.text
                                               , _lblDate.text
                                               , month
                                               , nowDate];
        
        //NSLog(@"INSERT : %@", insertSQL);
        const char *query_statment = [insertSQL UTF8String];

        if (sqlite3_exec(_db, query_statment,NULL,NULL, &errMessage) != SQLITE_OK)  //sqlite3_exec เป็นคำสั่ง Execute stringsql
        {
            //ใช้แทน AlertView
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"เกิดข้อผิดพลาด!!"
                                         message:@"ไม่สามารถบันทึกข้อมูลได้ โปรดลองใหม่อีกครั้ง!"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"ตกลง"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle your yes please button action here
                                        }];
            
            [alert addAction:yesButton];
            [self presentViewController:alert animated:YES completion:nil];
        }

        sqlite3_close(_db);
    }
}

- (IBAction)btnCancel:(id)sender
{
    _txtCarNo.text = @"";
    _txtPrice.text = @"";
    _lblFixTitle.text = @"";
    _txtView.text = @"";
}

- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element
{
    self.selectedDate = selectedDate;
    self.lblDate.text = [self.selectedDate description];
}

-(void)CreateDatabase
{
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_db) == SQLITE_OK)
    {
        char *errMsg;
        const char *dt = "DROP TABLE maintain";
        const char *sqltb_contrand = "CREATE TABLE IF NOT EXISTS ma(no TEXT, carno TEXT, title TEXT, detail TEXT, amt REAL, fix_date DATE, month TEXT, predate DATE)";
        
        
        if (sqlite3_exec(_db, sqltb_contrand, NULL, NULL, &errMsg) != SQLITE_OK)
        {
            //ใช้แทน AlertView
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"เกิดข้อผิดพลาด!!"
                                         message:@"ไม่สามารถสร้างตาราง document ได้ โปรดลองใหม่อีกครั้ง!"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"ตกลง"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle your yes please button action here
                                        }];
            
            [alert addAction:yesButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
         if (sqlite3_exec(_db, dt, NULL, NULL, &errMsg) != SQLITE_OK)
         {
             //comment
         }
        
        sqlite3_close(_db);
    }
}

-(NSString *)GetIdNo
{
    //F6040001
    NSString *strID = @"";
    NSString *strFirst = @"";
    NSString *strCheck = @"";

    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];  //กำหนดรูปเเบบเป็น UTF8
    
    //วันที่ปัจจุบัน
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yy"]; //18
    NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    
    if (sqlite3_open(dbpath, &_db) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT no FROM ma ORDER BY no DESC LIMIT 1"];
        const char *query_statment = [querySQL UTF8String]; //สั่งคิวรี่ข้อมูล fileSystemRepresentation
        
        if (sqlite3_prepare(_db, query_statment, -1, &statement, NULL) == SQLITE_OK)
        {
            
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                strID = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)];
            }
            
            //ถ้าไม่มีข้อมูล
            strFirst = [@"F" stringByAppendingString:dateString]; //ตัดเอาปี F60...
            if ([strID isEqualToString:@""])
            {
                strID = [strFirst stringByAppendingString:@"0001"];
            }
            else
            {
                strCheck = [strID substringWithRange:NSMakeRange(1, 2)]; //ตัดปีมาเทียบ
                strID = [strID substringFromIndex:3];
                
                if ([dateString isEqualToString:strCheck])  //ปีเดียวกันกับใน db
                {
                    strID = [NSString stringWithFormat:@"%04d", [strID intValue] +1];
                    strID = [strFirst stringByAppendingString:strID];
                }
                else  //ถ้าปีไม่ตรงกัน หรือเริ่มปีใหม่ให้นับ 1 ใหม่
                {
                    strID = [strFirst stringByAppendingString:@"0001"];
                }

            }
            
            sqlite3_finalize(statement);
        }
        
        sqlite3_close(_db);
    }
    
    return strID;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([myObject count] > 0)
    {
        NSDictionary *currentItem = myObject[indexPath.row];
        NSString *no = [NSString stringWithFormat:@"%@",currentItem[@"no"]];
        NSString *str_title = [NSString stringWithFormat:@"%@",currentItem[@"Title"]];
        NSString *str_carno = [[NSString stringWithFormat:@"%@",currentItem[@"Car"]] stringByAppendingString:@" "];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ยืนยันลบข้อมูล"
                                                                       message:[str_carno stringByAppendingString: str_title]
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"ลบ"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  [self DeleteData:no];
                                                                  [self ReloadData];
                                                                  [_myTable reloadData];
                                                              }];
        UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"ยกเลิก"
                                                               style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                   NSLog(@"ยกเลิก");
                                                               }];
        
        [alert addAction:firstAction]; // 4
        [alert addAction:secondAction]; // 5
        
        [self presentViewController:alert animated:YES completion:nil]; // 6
    }
}

-(void)DeleteData:(NSString *)str
{
    int rc= 0;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_db) == SQLITE_OK)
    {
        char *errMsg;
        NSString *SQL = [NSString stringWithFormat:@"DELETE FROM ma WHERE no = \'%@\'", str];
        
        //NSLog(@"ลบข้อมูล : %@", SQL);
        rc = sqlite3_exec(_db, [SQL UTF8String] ,NULL,NULL,&errMsg);
        if(SQLITE_OK != rc)
        {
            NSLog(@"Failed to insert record table ma rc:%d, msg=%s",rc,errMsg);
        }
        
        sqlite3_close(_db);
    }
}

-(void)goToBottom
{
    NSIndexPath *lastIndexPath = [self lastIndexPath];
    [_myTable scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(NSIndexPath *)lastIndexPath
{
    NSInteger lastSectionIndex = MAX(0, [_myTable numberOfSections] - 1);
    NSInteger lastRowIndex = MAX(0, [_myTable numberOfRowsInSection:lastSectionIndex] - 1);
    return [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([_txtCarNo isFirstResponder] && [touch view] != _txtCarNo)
    {
        [_txtCarNo resignFirstResponder];
    }
    else if ([_txtView isFirstResponder] && [touch view] != _txtView)
    {
        [_txtView resignFirstResponder];
    }
    else
    {
         [_txtPrice resignFirstResponder];
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
