//
//  AddTitleFixViewController.m
//  Check Oil Price
//
//  Created by Sahaphon_mac on 1/31/18.
//  Copyright © 2018 rich_noname. All rights reserved.
//

#import "AddTitleFixViewController.h"

@interface AddTitleFixViewController ()
{
    NSMutableArray *myObject;
    NSDictionary *dict;
    NSString *docDIR;
    NSArray *dirPath;
}

@end

@implementation AddTitleFixViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    myObject = [[NSMutableArray alloc]init];
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docDIR = dirPath[0];
    
    //สร้าง part เชื่อมโยงไปยังฐานข้อมูล
    _databasePath = [[NSString alloc] initWithString:[docDIR stringByAppendingPathComponent:@"Oil.db"]];  //ย้ายมารวมไว้ใน consign
    [self CreateDatabase];
    [self ReloadData];
    [_myTable reloadData];
    
    _txtName.text = @"";  //Clear Data
    
    [self.btnAdd createTitle:@"บันทึก" withIcon:[UIImage imageNamed:@"icons8-save-20"] font:[UIFont fontWithName:@"PSL Display" size:18] iconHeight:JTImageButtonIconHeightDefault iconOffsetY:JTImageButtonIconOffsetYNone];
    self.btnAdd.titleColor = UIColor.blackColor;
    self.btnAdd.iconColor =  UIColor.blackColor;
    self.btnAdd.padding = JTImageButtonPaddingMedium;
    self.btnAdd.cornerRadius = 2.0;
    self.btnAdd.borderWidth = 1.6;
    self.btnAdd.borderColor = UIColor.blackColor;
    self.btnAdd.iconSide = JTImageButtonIconSideRight;
    
    
    [self.btnDel createTitle:@"ลบ" withIcon:[UIImage imageNamed:@"icons8-cancel-20"] font:[UIFont fontWithName:@"PSL Display" size:18] iconHeight:JTImageButtonIconHeightDefault iconOffsetY:JTImageButtonIconOffsetYNone];
    self.btnDel.titleColor = UIColor.blackColor;
    self.btnDel.iconColor =  UIColor.blackColor;
    self.btnDel.padding = JTImageButtonPaddingMedium;
    self.btnDel.cornerRadius = 2.5;
    self.btnDel.borderWidth = 2.0;
    self.btnDel.borderColor = UIColor.blackColor;
    self.btnDel.iconSide = JTImageButtonIconSideRight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"หัวข้อการซ่อม";
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger nbCount = [myObject count];
    if (nbCount == 0)
    {
        return 1;
    }
    else
    {
        return [myObject count];
    }
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
    
    //กำหนด font cell
    cell.textLabel.font  = [ UIFont fontWithName: @"PSL Display" size: 20.0 ];
    
    if (nbCount > 0)
    {
        NSDictionary *currentItem = myObject [indexPath.row];
        
        cell.textLabel.textColor = [UIColor blueColor];
        cell.textLabel.text = currentItem[@"Title"];
    }
    else
    {
        cell.textLabel.text = @"";
    }
    
    return cell;
}

//กำหนด style section header
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(20, 8, 320, 20);
    myLabel.font = [UIFont boldSystemFontOfSize:14];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
}

- (IBAction)btnAdd:(id)sender
{
    if ([_txtName.text length] > 0)
    {
        [self InsertTitleData];
        _txtName.text = @"";
        [self ReloadData];
        [_myTable reloadData];
    }
    else
    {
        //ใช้แทน AlertView
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Error!!"
                                     message:@"โปรดกรอกข้อมูลให้ครบถ้วน"
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

- (IBAction)btnDel:(id)sender
{
    _txtName.text = @"";
}

-(void)ReloadData
{
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];  //กำหนดรูปเเบบเป็น UTF8
    
    if (sqlite3_open(dbpath, &_db) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM document"];
        const char *query_statment = [querySQL UTF8String]; //สั่งคิวรี่ข้อมูล fileSystemRepresentation
        
        if (sqlite3_prepare(_db, query_statment, -1, &statement, NULL) == SQLITE_OK)
        {
            [myObject removeAllObjects];  //Clear all data
            
             while(sqlite3_step(statement) == SQLITE_ROW)
             {

                 dict = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 0)], @"Title",
                         nil];
                 
                 [myObject addObject:dict];
                 
             }
            
            sqlite3_finalize(statement);
        }
        
         sqlite3_close(_db);
    }
}

-(void)InsertTitleData
{
    int rc= 0;
    const char *dbpath = [_databasePath UTF8String];
    
    //วันที่ปัจจุบัน
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    
    if (sqlite3_open(dbpath, &_db) == SQLITE_OK)
    {
        char *errMsg;
        
        NSString *sqlCmd2 = [NSString stringWithFormat:@"INSERT INTO document(title, lastdate) VALUES (\'%@\',\'%@\')"
                             , _txtName.text
                             , dateString];
        
        //NSLog(@"เพิ่มรายการคืนสินค้า : %@",sqlCmd2);
        rc = sqlite3_exec(_db, [sqlCmd2 UTF8String] ,NULL,NULL,&errMsg);
        if(SQLITE_OK != rc)
        {
            NSLog(@"Failed to insert record table document rc:%d, msg=%s",rc,errMsg);
        }
        
        sqlite3_close(_db);
    }
}

     //[self dismissViewControllerAnimated:YES completion:nil];

-(void)CreateDatabase
{
    const char *dbpath = [_databasePath UTF8String];
    
     if (sqlite3_open(dbpath, &_db) == SQLITE_OK)
     {
         char *errMsg;
         const char *sqltb_contrand = "CREATE TABLE IF NOT EXISTS document(title TEXT, lastdate DATE)";
         
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
         
          sqlite3_close(_db);
     }
}

//เมื่อ Touch นอก TextField
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([_txtName isFirstResponder] && [touch view] != _txtName)
    {
        [_txtName resignFirstResponder];
    }
    
    [super touchesBegan:touches withEvent:event];
}

-(BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound )
    {
        return YES;
    }
    
    [txtView resignFirstResponder];
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([myObject count] > 0)
    {
        NSDictionary *currentItem = myObject[indexPath.row];
        NSString *strTitle = [NSString stringWithFormat:@"%@",currentItem[@"Title"]];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ยืนยันลบข้อมูล"
                                                                       message:strTitle
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"ลบ"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  [self DeleteData:strTitle];
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

-(void)DeleteData:(NSString *)strName
{
    int rc= 0;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_db) == SQLITE_OK)
    {
        char *errMsg;
        NSString *SQL = [NSString stringWithFormat:@"DELETE FROM document WHERE title = \'%@\'", strName];
        
        //NSLog(@"ลบข้อมูล : %@", SQL);
        rc = sqlite3_exec(_db, [SQL UTF8String] ,NULL,NULL,&errMsg);
        if(SQLITE_OK != rc)
        {
            NSLog(@"Failed to insert record table document rc:%d, msg=%s",rc,errMsg);
        }
        
        sqlite3_close(_db);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
