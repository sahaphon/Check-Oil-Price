//
//  BangchakViewController.m
//  Check Oil Price
//
//  Created by Sahaphon_mac on 1/26/18.
//  Copyright © 2018 rich_noname. All rights reserved.
//

#import "BangchakViewController.h"
#import "HTMLNode.h"
#import "HTMLParser.h"

@import GoogleMobileAds;
@interface BangchakViewController ()
@end

@implementation BangchakViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //เปลี่ยนสี Navigationbar
    [self.navigationController.navigationBar setBarTintColor : [UIColor greenColor]];
    
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor],
       NSFontAttributeName:[UIFont fontWithName:@"PSL Display" size:28]}];
    
    ///Create banner
    self.bannerView.delegate = self;
    self.bannerView.adUnitID = @"ca-app-pub-2924991065979368/1181945698";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    
    // In this case, we instantiate the banner with desired ad size.
    self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    [self addBannerViewToView:_bannerView];
    
    
    [self InsertDefaltData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
         [self CallWebService];
    });
   
    // timer ทุก 2 นาที
    [NSTimer scheduledTimerWithTimeInterval: 120.0
                                     target: self
                                   selector:@selector(onTick:)
                                   userInfo: nil repeats:YES];
}

- (void)addBannerViewToView:(UIView *)bannerView {
    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bannerView];
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:bannerView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.bottomLayoutGuide
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:bannerView
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1
                                                              constant:0]
                                ]];
}


-(void)onTick:(NSTimer *)timer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // you can update UI - but recommend to do long taks
        self.Activity.hidden = NO;
        [self.Activity startAnimating];
        [self CallWebService];
    });

}

-(void)InsertDefaltData
{
    int rc= 0;
    
    NSString *docDIR;
    NSArray *dirPath;
    
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docDIR = dirPath[0];
    
    //สร้าง part เชื่อมโยงไปยังฐานข้อมูล
    _databasePath = [[NSString alloc] initWithString:[docDIR stringByAppendingPathComponent:@"Oil.db"]];  //ย้ายมารวมไว้ใน consign
    
    //NSLog(@"PATH :%@", _databasePath);
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_db) == SQLITE_OK)
    {
        char *errMsg;
    
            //  เพิ่มข้อมูลรายชื่อน้ำมันพื้นฐาน
            NSString* oilname =@"";
            
            for (int i = 1; i <= 7; i++)
            {
                if (i == 1)
                {
                    oilname = @"Hi Premium Diesel S";
                }
                else if (i == 2)
                {
                    oilname = @"Diesel S";
                }
                else if (i == 3 )
                {
                    oilname = @"Gasohol E85 S";
                }
                else if (i == 4)
                {
                    oilname = @"Gasohol E20 S";
                }
                else if (i == 5)
                {
                    oilname = @"Gasohol 91 S";
                }
                else if (i == 6)
                {
                    oilname = @"Gasohol 95 S";
                }
                else if (i == 7)
                {
                    oilname = @"NGV";
                }
                
                
                // Insert Main Data
                NSString *sqlCmd2 = [NSString stringWithFormat:@"INSERT INTO OilPrice (category, oilname, todPrice, tomPrice, lastdate, lasttime) VALUES (\'%@\',\'%@\',\'%@\',\'%@\',\'%@\',\'%@\' )"
                                     , @"BCP"
                                     , oilname
                                     , @"0.00"
                                     , @"0.00"
                                     , @"2018-01-01"
                                     , @"00:00"];
                
                
                //NSLog(@"เพิ่มรายการคืนสินค้า : %@",sqlCmd2);
                rc = sqlite3_exec(_db, [sqlCmd2 UTF8String] ,NULL,NULL,&errMsg);
                if(SQLITE_OK != rc)
                {
                    NSLog(@"Failed to insert record table retdoc rc:%d, msg=%s",rc,errMsg);
                }
            }
        
        sqlite3_close(_db);
    }
    else
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Error!!"
                                     message:@"Failed  to open/create the table"
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

-(void)CallWebService
{
    int rc= 0;
    
    sqlite3 *db;
    char * errMsg;
    const char *dbpath = [_databasePath UTF8String]; //กำหนดรูปเเบบเป็น UTF8
    NSError *error = nil;
    NSString *html3;
    
    //วันที่ปัจจุบัน
    NSDate *currDay = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSString *dateString = [dateFormat stringFromDate:currDay];
    _lblDate.text = dateString;
    
    
    NSDateFormatter *DateFormatter = [[NSDateFormatter alloc]init];
    [DateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *nowDate = [NSString stringWithFormat:@"%@",[DateFormatter stringFromDate:[NSDate date]]];
    nowDate = [self FunctionConvertEngYear:nowDate];

    
    NSDateFormatter *dateFormat_time = [[NSDateFormatter alloc] init];
    [dateFormat_time setDateFormat:@"HH:mm:ss a"];
    NSString *nowTime = [NSString stringWithFormat:@"%@",[dateFormat_time stringFromDate:[NSDate date]]];
    
    self.Activity.hidden = NO;  //hide Indicator
    [self.Activity startAnimating];
    
    html3 = [self convertHTML:@"https://crmmobile.bangchak.co.th/webservice/oil_price.aspx"];
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html3 error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
        return;
    }
    
    HTMLNode *bodyNode = [parser body];
    
    NSArray *type = [bodyNode findChildTags:@"type"];
    NSArray *today = [bodyNode findChildTags:@"today"];
    NSArray *tomorrow = [bodyNode findChildTags:@"tomorrow"];
    
    int x =0;
    int i =0;
    int i2 =0;
    
    NSString *strType;
    NSString *strToday;
    NSString *strTomorrow;
    
    for (HTMLNode *val1 in type)
    {
        strType = [val1 rawContents];
        strType = [strType stringByReplacingOccurrencesOfString:@"<type>" withString:@""];
        strType = [strType stringByReplacingOccurrencesOfString:@"</type>" withString:@""];
        //NSLog(@"%@", strType);
        
        
        for (HTMLNode *val2 in today)
        {
            
            if (i == x)
            {
                strToday = [val2 rawContents];
                strToday = [strToday stringByReplacingOccurrencesOfString:@"<today>" withString:@""];
                strToday = [strToday stringByReplacingOccurrencesOfString:@"</today>" withString:@""];
                //NSLog(@"%@", strToday);
            }
            
            
            i = i+1;
            //break;
        }
        
        for (HTMLNode *val3 in tomorrow)
        {
            
            if (i2 == x)
            {
                strTomorrow = [val3 rawContents];
                strTomorrow = [strTomorrow stringByReplacingOccurrencesOfString:@"<tomorrow>" withString:@""];
                strTomorrow = [strTomorrow stringByReplacingOccurrencesOfString:@"</tomorrow>" withString:@""];
                //NSLog(@"%@", strToday);
            }
            
            
            i2 = i2+1;
            //break;
        }
        
    
        //Update Oilprice
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            
            NSString *sqlCmd2 = [NSString stringWithFormat:@"UPDATE OilPrice SET todPrice = \'%@\', tomPrice = \'%@\', lastdate = \'%@\', lasttime = \'%@\' WHERE category = \'%@\' AND oilname LIKE '%@%%'", strToday, strTomorrow, nowDate, nowTime, @"BCP", strType];
                
                
           //NSLog(@"%@",sqlCmd2);
           rc = sqlite3_exec(db, [sqlCmd2 UTF8String] ,NULL,NULL,&errMsg);
           if(SQLITE_OK != rc)
           {
              NSLog(@"Failed to Update record table Oilprice rc:%d, msg=%s",rc,errMsg);
           }
        }
        
        sqlite3_close(db);
        
        
        i = 0;  //clear value
        i2 = 0; //clear value
        
        x = x+1;
    }
    
    self.Activity.hidden = YES;  //hide Indicator
    [self.Activity stopAnimating];
    [self LoadAllData];
  
}

-(NSString *)convertHTML:(NSString *)html
{
    NSString *myURLString = html;
    NSURL *myURL = [NSURL URLWithString:myURLString];
    
    NSError *error = nil;
    html = [NSString stringWithContentsOfURL:myURL encoding: NSUTF8StringEncoding error:&error];
    
    return html;
}

-(NSString *)FunctionConvertEngYear:(NSString *)inputYear
{
    //Convert EngYear  ต้องรับเข้ามาเป็น 01-01-255x  คืนค่า 2015-XX-XX
    NSString *tmp = [inputYear substringFromIndex:6];
    NSInteger engYear;
    
    //เช็คตัั้งค่ามือถือเป็นปี คศ
    if ([tmp integerValue] > 2500)
    {
        engYear = [tmp integerValue] - 543;
    }
    else
    {
        engYear = [tmp integerValue];
    }
    
    NSString *strYear = [NSString stringWithFormat:@"%ld",(long)engYear];
    NSString *stMonth = [inputYear substringWithRange:NSMakeRange(2, 4)];
    NSString *strDay = [inputYear substringWithRange:NSMakeRange(0, 2)];
    
    inputYear = [strYear stringByAppendingString:stMonth];
    strYear = [inputYear stringByAppendingString:strDay];
    
    return strYear;  //eng year
}

-(void)LoadAllData
{
    double val1;
    double val2;
    
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String]; //กำหนดรูปเเบบเป็น UTF8
    
    if (sqlite3_open(dbpath, &_db) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM OilPrice WHERE category = \'%@\'", @"BCP"];
        const char *query_statment = [querySQL UTF8String]; //สั่งคิวรี่ข้อมูล fileSystemRepresentation
        
        if (sqlite3_prepare(_db, query_statment, -1, &statement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                val1 = 0;
                val2 = 0;
                
                if ([[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)] isEqualToString:@"Hi Premium Diesel S"])
                {
                    _lblHiPreDiesel.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 2)];
                    _lblHiPreDiesel_tomorrow.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 3)];
                    
                    val1 = [_lblHiPreDiesel.text doubleValue];
                    val2 = [_lblHiPreDiesel_tomorrow.text doubleValue];
                    
                    val2 = val2 - val1;
                    _lblDif_HiPreDiesel.text = [NSString stringWithFormat:@"%.2lf", val2];
                    
                    if (val2 > 0)
                    {
                        _lblDif_HiPreDiesel.text = [@"+" stringByAppendingString:_lblDif_HiPreDiesel.text];
                    }
                    else if (val2 == 0)
                    {
                        _lblDif_HiPreDiesel.text = @"-";
                    }
                    else if (val2 < 0)
                    {
                        _lblDif_HiPreDiesel.text =  _lblDif_HiPreDiesel.text;
                    }
                    
                }
                else if ([[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)] isEqualToString:@"Diesel S"])
                {
                    _lblDiesel.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 2)];
                    _lblDisel_tomorrow.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 3)];
                    
                    val1 = [_lblDiesel.text doubleValue];
                    val2 = [_lblDisel_tomorrow.text doubleValue];
                    
                    val2 = val2 - val1;
                    _lblDif_Hidiesel.text = [NSString stringWithFormat:@"%.2lf", val2];
                    
                    if (val2 > 0)
                    {
                        _lblDif_Hidiesel.text = [@"+" stringByAppendingString:_lblDif_Hidiesel.text];
                    }
                    else if (val2 == 0)
                    {
                        _lblDif_Hidiesel.text = @"-";
                    }
                    else if (val2 < 0)
                    {
                        _lblDif_Hidiesel.text =  _lblDif_Hidiesel.text;
                    }
                }
                else if ([[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)] isEqualToString:@"Gasohol E85 S"])
                {
                    _lblE85.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 2)];
                    _lblE85_tomorrow.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 3)];
                    
                    val1 = [_lblE85.text doubleValue];
                    val2 = [_lblE85_tomorrow.text doubleValue];
                    
                    val2 = val2 - val1;
                    _lblDif_E85.text = [NSString stringWithFormat:@"%.2lf", val2];
                    
                    if (val2 > 0)
                    {
                        _lblDif_E85.text = [@"+" stringByAppendingString:_lblDif_E85.text];
                    }
                    else if (val2 == 0)
                    {
                        _lblDif_E85.text = @"-";
                    }
                    else if (val2 < 0)
                    {
                        _lblDif_E85.text =  _lblDif_E85.text;
                    }
                }
                else if ([[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)] isEqualToString:@"Gasohol E20 S"])
                {
                    _lblE20.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 2)];
                    _lblE20_tomorrow.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 3)];
                    
                    val1 = [_lblE20.text doubleValue];
                    val2 = [_lblE20_tomorrow.text doubleValue];
                    
                    val2 = val2 - val1;
                    _lblDif_E20.text = [NSString stringWithFormat:@"%.2lf", val2];
                    
                    if (val2 > 0)
                    {
                        _lblDif_E20.text = [@"+" stringByAppendingString:_lblDif_E20.text];
                    }
                    else if (val2 == 0)
                    {
                        _lblDif_E20.text = @"-";
                    }
                    else if (val2 < 0)
                    {
                        _lblDif_E20.text =  _lblDif_E20.text;
                    }
                }
                else if ([[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)] isEqualToString:@"Gasohol 91 S"])
                {
                    _lbl91.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 2)];
                    _lbl91_tomorrow.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 3)];
                    
                    val1 = [_lbl91.text doubleValue];
                    val2 = [_lbl91_tomorrow.text doubleValue];
                    
                    val2 = val2 - val1;
                    _lblDif_91.text = [NSString stringWithFormat:@"%.2lf", val2];
                    
                    if (val2 > 0)
                    {
                        _lblDif_91.text = [@"+" stringByAppendingString:_lblDif_91.text];
                    }
                    else if (val2 == 0)
                    {
                        _lblDif_91.text = @"-";
                    }
                    else if (val2 < 0)
                    {
                        _lblDif_91.text = _lblDif_91.text;
                    }
                }
                else if ([[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)] isEqualToString:@"Gasohol 95 S"])
                {
                    _lbl95.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 2)];
                    _lbl95_tomorrow.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 3)];
                    
                    val1 = [_lbl95.text doubleValue];
                    val2 = [_lbl95_tomorrow.text doubleValue];
                    
                    val2 = val2 - val1;
                    self.lblDif_95.text = [NSString stringWithFormat:@"%.2lf", val2];
                    
                    if (val2 > 0)
                    {
                        self.lblDif_95.text = [@"+" stringByAppendingString:self.lblDif_95.text];
                    }
                    else if (val2 == 0)
                    {
                        self.lblDif_95.text = @"-";
                    }
                    else if (val2 < 0)
                    {
                        self.lblDif_95.text = _lblDif_95.text;
                    }
                }
                else if ([[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)] isEqualToString:@"NGV"])
                {
                    _lblNgv.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 2)];
                    _lblNgv_tomorrow.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 3)];
                    
                    val1 = [_lblNgv.text doubleValue];
                    val2 = [_lblNgv_tomorrow.text doubleValue];
                    
                    val2 = val2 - val1;
                    _lblDif_ngv.text = [NSString stringWithFormat:@"%.2lf", val2];
                    
                    if (val2 > 0)
                    {
                        _lblDif_ngv.text = [@"+" stringByAppendingString:_lblDif_ngv.text];
                    }
                    else if (val2 == 0)
                    {
                        _lblDif_ngv.text = @"-";
                    }
                    else if (val2 < 0)
                    {
                        _lblDif_ngv.text = _lblDif_ngv.text;
                    }
                }
               
            }
        }
        
        sqlite3_finalize(statement);
    }
    else
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Error!!"
                                     message:@"เปิด Database ไม่ได้"
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
