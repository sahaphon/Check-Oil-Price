//
//  ViewController.m
//  Check Oil Price
//
//  Created by Sahaphon_mac on 1/19/18.
//  Copyright © 2018 rich_noname. All rights reserved.
//

#import "ViewController.h"
#import "sqlite3.h"
#import "SMXMLDocument.h"

@import GoogleMobileAds;
@interface ViewController ()  
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //เปลี่ยนสี Navigationbar
    [self.navigationController.navigationBar setBarTintColor : [UIColor whiteColor]];
    
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blueColor],
       NSFontAttributeName:[UIFont fontWithName:@"PSL Display" size:28]}];
    
    ///Create banner
    self.bannerView.delegate = self;
    self.bannerView.adUnitID = @"ca-app-pub-2924991065979368/1181945698";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    
    // In this case, we instantiate the banner with desired ad size.
    self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    [self addBannerViewToView:_bannerView];
    
    
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"sky.jpg"]];
    [self CreateDatabase];
    [self CallWebService];
    
   // timer ทุก 30 วินาที
   [NSTimer scheduledTimerWithTimeInterval: 30.0
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

-(void)LoadCustomFont
{
    for(UIView *subview in self.view.subviews){
        if ([subview isKindOfClass:[UILabel class]] == YES)
        {
            UILabel* _label = (UILabel*)subview;
            _label.font = [UIFont fontWithName:@"DS-DIGI.TTF" size:40];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)CallWebService
{
    //soap request โซฟ รีเควส
    [self.indicator startAnimating];
    
    NSString* soapMessage = NSLocalizedString(@"WS_SOAP_REQUEST", @"");
    NSString* _wsURLString = @"http://www.pttplc.com/webservice/pttinfo.asmx";
    NSString* _wsSoapAction = @"http://www.pttplc.com/ptt_webservice/CurrentOilPrice";
    
    NSURL *url = [NSURL URLWithString: _wsURLString];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%ld", [soapMessage length]];
    [theRequest addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: _wsSoapAction forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    //โหลด Asyncronus ในการทำ Thread เชื่อมต่อ แตกโปรแซส pararell
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:theRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        //Background Thread
        //you cannot update UI.
        
        //สร้าง MainThread สำหรับอัพเดท UI
        dispatch_async(dispatch_get_main_queue(), ^{
            // you can update UI - but recommend to do long taks
            [self handleResponseData:data];
        });
        
    }];
}

// stub เมทอดเปล่าๆ
-(void)handleResponseData:(NSData *) _responseData
{
    //NSString* _resultLog = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    
    [self.indicator stopAnimating];
    NSDate  *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy HH:mm:ss a"];
    NSString *dateString = [dateFormat stringFromDate:today];
    _lbldate.text = dateString;
    
    //แปลงอักขระ
    NSString *tmp = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
   //NSLog(@"%@", tmp);
    
    // verify xml
    NSError* error;
    SMXMLDocument *document = [SMXMLDocument documentWithData:[tmp dataUsingEncoding:NSUTF8StringEncoding] error:&error];
    SMXMLElement *res = [[[[document childNamed:@"Body"] childNamed:@"CurrentOilPriceResponse"] childNamed:@"CurrentOilPriceResult"] childNamed:@"PTT_DS"];
    self.mDataArray = [res children];
    //NSLog(@"%@", self.mDataArray.description);
    
    [self SaveCurrPrice];  // บันทึกข้อมูลราคา นม. ปัจจุบัน
    [self FindTomorrowPrice]; // หาราคา น้ำมันพรุ่งนี้
    
    for (SMXMLElement* _element in self.mDataArray)
    {
        NSString* _product = [_element valueWithPath:@"PRODUCT"];
        
        if ([_product isEqualToString:@"Blue Diesel"])
        {
            self.lblDiesale.text = [_element valueWithPath:@"PRICE"];
        }
        else if ([_product isEqualToString:@"Blue Gasoline 95"])
        {
            self.lbl95.text = [_element valueWithPath:@"PRICE"];
        }
        else if ([_product isEqualToString:@"Blue Gasohol 91"])
        {
            self.lbl91.text = [_element valueWithPath:@"PRICE"];
        }
        else if ([_product isEqualToString:@"Blue Gasohol E20"])
        {
            self.lblE20.text = [_element valueWithPath:@"PRICE"];
        }
        else if ([_product isEqualToString:@"Blue Gasohol 95"])
        {
            self.lblGas95.text = [_element valueWithPath:@"PRICE"];
        }
        else if ([_product isEqualToString:@"Blue Gasohol E85"])
        {
            self.lblE85.text = [_element valueWithPath:@"PRICE"];
        }
        else if ([_product isEqualToString:@"HyForce Premium Diesel"])
        {
            self.lblHfDiesel.text = [_element valueWithPath:@"PRICE"];
        }
        else if ([_product isEqualToString:@"เอ็นจีวี"])
        {
            self.lblNGV.text = [_element valueWithPath:@"PRICE"];
        }
    }
    
}

-(void)onTick:(NSTimer *)timer
{
    [self CallWebService];
}

-(void)CreateDatabase
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
        
        //const char *droptb = "DROP TABLE contrnd";
        const char *sqltb_contrand = "CREATE TABLE IF NOT EXISTS OilPrice (category TEXT, oilname TEXT, todPrice REAL, tomPrice REAL, lastdate DATE, lasttime TEXT)";
        
        if (sqlite3_exec(_db, sqltb_contrand, NULL, NULL, &errMsg) != SQLITE_OK)
        {
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Error!!"
                                         message:@"Failed to create the table Oilprice"
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
        else
        {
            // ล้างรายการเก่าก่อน
            NSString *sqlCmd = [NSString stringWithFormat:@"DELETE FROM OilPrice"];
            
            rc = sqlite3_exec(_db, [sqlCmd UTF8String] ,NULL,NULL,&errMsg);
            if(SQLITE_OK != rc)
            {
                NSLog(@"Failed to insert record table retdoc rc:%d, msg=%s",rc,errMsg);
            }
            
            
            //  เพิ่มข้อมูลรายชื่อน้ำมันพื้นฐาน
            NSString* oilname =@"";
            
            for (int i = 1; i <= 8; i++)
            {
                if (i == 1)
                {
                    oilname = @"Blue Diesel";
                }
                else if (i == 2)
                {
                    oilname = @"Blue Gasoline 95";
                }
                else if (i == 3 )
                {
                    oilname = @"Blue Gasohol 91";
                }
                else if (i == 4)
                {
                    oilname = @"Blue Gasohol 95";
                }
                else if (i == 5)
                {
                    oilname = @"Blue Gasohol E20";
                }
                else if (i == 6)
                {
                    oilname = @"Blue Gasohol E85";
                }
                else if (i == 7)
                {
                    oilname = @"HyForce Premium Diesel";
                }
                else if (i == 8)
                {
                    oilname = @"เอ็นจีวี";
                }
                
                
                // Insert Main Data
                NSString *sqlCmd2 = [NSString stringWithFormat:@"INSERT INTO OilPrice (category, oilname, todPrice, tomPrice, lastdate, lasttime) VALUES (\'%@\',\'%@\',\'%@\',\'%@\',\'%@\',\'%@\' )"
                                     , @"PTT"
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

-(void) SaveCurrPrice
{
    int rc= 0;
    
    sqlite3 *db;
    char * errMsg;
    const char *dbpath = [_databasePath UTF8String]; //กำหนดรูปเเบบเป็น UTF8
    
    if (sqlite3_open(dbpath, &db) == SQLITE_OK)
    {
        
        for (id element in _mDataArray)
        {
            
            NSString *sqlCmd2 = [NSString stringWithFormat:@"UPDATE OilPrice SET todPrice = \'%@\', tomPrice = 0 WHERE category = \'%@\' AND oilname LIKE '%@%%'", [element valueWithPath:@"PRICE"], @"PTT",[element valueWithPath:@"PRODUCT"]];
            
            
            //NSLog(@"%@",sqlCmd2);
            rc = sqlite3_exec(db, [sqlCmd2 UTF8String] ,NULL,NULL,&errMsg);
            if(SQLITE_OK != rc)
            {
                NSLog(@"Failed to Update record table Oilprice rc:%d, msg=%s",rc,errMsg);
            }
        }
    }
    
    sqlite3_close(db);
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

-(void)FindTomorrowPrice
{
    NSString *strDate = @"";
    NSString *strMonth = @"";
    NSString *strYear = @"";
    
    //วันที่ปัจจุบัน  yyyy-mm-dd
    NSDateFormatter *DateFormatter = [[NSDateFormatter alloc]init];
    [DateFormatter setDateFormat:@"dd-MM-yyyy"];

    // date add day บวกวันที่ล่วงหน้า 1 วัน
    NSDate *now = [NSDate date];
    int daysToAdd = 1;
    NSDate *newDate = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
    NSString *nowDate = [NSString stringWithFormat:@"%@",[DateFormatter stringFromDate:newDate]];
    
    nowDate = [self FunctionConvertEngYear:nowDate];
    //NSLog(@"วันที่ : %@", nowDate);
    

    strDate = [nowDate substringFromIndex:8];
    strMonth = [nowDate substringWithRange:NSMakeRange(5, 2)];
    strYear = [nowDate substringWithRange:NSMakeRange(0, 4)];
    
    //NSLog(@"%@ : %@ : %@ ",strDate, strMonth, strYear);
    
    NSString *soapMessage = [NSString stringWithFormat:
                                                       @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                                       "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                                       "<soap:Body>\n"
                                                       "<GetOilPrice xmlns=\"http://www.pttplc.com/ptt_webservice/\">\n"
                                                       "<Language>TH</Language>\n"
                                                       "<DD>%@</DD>\n"
                                                       "<MM>%@</MM>\n"
                                                       "<YYYY>%@</YYYY>\n"
                                                       "</GetOilPrice>\n"
                                                       "</soap:Body>\n"
                                                       "</soap:Envelope>\n"
                                                       ,strDate
                                                       ,strMonth
                                                       ,strYear
                                                       ];
    
    //NSLog(@"soapMessage: \n%@",soapMessage);;
    NSString* _wsURLString = @"http://www.pttplc.com/webservice/pttinfo.asmx";
    NSString* _wsSoapAction = @"http://www.pttplc.com/ptt_webservice/GetOilPrice";
    
    NSURL *url = [NSURL URLWithString: _wsURLString];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%ld", [soapMessage length]];
    [theRequest addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: _wsSoapAction forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    //โหลด Asyncronus ในการทำ Thread เชื่อมต่อ แตกโปรแซส pararell
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:theRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        //Background Thread
        //you cannot update UI.
        
        //สร้าง MainThread สำหรับอัพเดท UI
        dispatch_async(dispatch_get_main_queue(), ^{
            // you can update UI - but recommend to do long taks
            [self handleResponseData2:data];
        });
        
    }];
}

-(void)handleResponseData2:(NSData *) _responseData
{
    NSDate  *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy HH:mm:ss a"];
    NSString *dateString = [dateFormat stringFromDate:today];
    _lbldate.text = dateString;
    
    //แปลงอักขระ
    NSString *tmp = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    //NSLog(@"%@", tmp);
    
    // verify xml
    NSError* error;
    SMXMLDocument *document = [SMXMLDocument documentWithData:[tmp dataUsingEncoding:NSUTF8StringEncoding] error:&error];
    SMXMLElement *res = [[[[document childNamed:@"Body"] childNamed:@"GetOilPriceResponse"] childNamed:@"GetOilPriceResult"] childNamed:@"PTT_DS"];

    self.mDataArray2 = [res children];
    //NSLog(@"%@", self.mDataArray2.description);
    
    [self SaveTomorrowPrice]; // บันทึกราคาน้ำมัน พรุ่งนี้
    [self LoadAllData];
}

-(void) SaveTomorrowPrice
{
    int rc= 0;
    
    //วันที่ปัจจุบัน
    NSDateFormatter *DateFormatter = [[NSDateFormatter alloc]init];
    [DateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *nowDate = [NSString stringWithFormat:@"%@",[DateFormatter stringFromDate:[NSDate date]]];
    nowDate = [self FunctionConvertEngYear:nowDate];
    
    NSDateFormatter *dateFormat_time = [[NSDateFormatter alloc] init];
    [dateFormat_time setDateFormat:@"HH:mm:ss a"];
    NSString *nowTime = [NSString stringWithFormat:@"%@",[dateFormat_time stringFromDate:[NSDate date]]];
    
    sqlite3 *db;
    char * errMsg;
    const char *dbpath = [_databasePath UTF8String]; //กำหนดรูปเเบบเป็น UTF8
    
    if (sqlite3_open(dbpath, &db) == SQLITE_OK)
    {
        
        for (id element in _mDataArray2)
        {
            
            NSString *sqlCmd2 = [NSString stringWithFormat:@"UPDATE OilPrice SET tomPrice = \'%@\', lastdate = \'%@\', lasttime = \'%@\' WHERE category = \'%@\' AND oilname LIKE '%@%%'", [element valueWithPath:@"PRICE"], nowDate, nowTime, @"PTT", [element valueWithPath:@"PRODUCT"]];
            
            
            //NSLog(@"%@",sqlCmd2);
            rc = sqlite3_exec(db, [sqlCmd2 UTF8String] ,NULL,NULL,&errMsg);
            if(SQLITE_OK != rc)
            {
                NSLog(@"Failed to Update record table Oilprice rc:%d, msg=%s",rc,errMsg);
            }
        }
    }
    
    sqlite3_close(db);
}

-(void)LoadAllData
{
    double val1;
    double val2;
    
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String]; //กำหนดรูปเเบบเป็น UTF8
    
    if (sqlite3_open(dbpath, &_db) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM OilPrice WHERE category = \'%@\'",@"PTT"];
        const char *query_statment = [querySQL UTF8String]; //สั่งคิวรี่ข้อมูล fileSystemRepresentation
        
        if (sqlite3_prepare(_db, query_statment, -1, &statement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                val1 = 0;
                val2 = 0;
                
                if ([[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)] isEqualToString:@"Blue Diesel"])
                {
                    _lblDiesale.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 2)];
                    _lblDies_Tomorrow.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 3)];
                    
                    val1 = [_lblDiesale.text doubleValue];
                    val2 = [_lblDies_Tomorrow.text doubleValue];
                    
                    val2 = val2 - val1;
                    _lblDif_diesel.text = [NSString stringWithFormat:@"%.2lf", val2];
                    
                    if (val2 > 0)
                    {
                        _lblDif_diesel.text = [@"+" stringByAppendingString:_lblDif_diesel.text];
                    }
                    else if (val2 == 0)
                    {
                        _lblDif_diesel.text = @"-";
                    }
                    else if (val2 < 0)
                    {
                        _lblDif_diesel.text = _lblDif_diesel.text;
                    }
                    
                }
                else if ([[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)] isEqualToString:@"Blue Gasoline 95"])
                {
                    _lbl95.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 2)];
                    _lbl95_Tomorrow.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 3)];
                    
                    val1 = [_lbl95.text doubleValue];
                    val2 = [_lbl95_Tomorrow.text doubleValue];
                    
                    val2 = val2 - val1;
                    _lblDif_95.text = [NSString stringWithFormat:@"%.2lf", val2];
                    
                    if (val2 > 0)
                    {
                        _lblDif_95.text = [@"+" stringByAppendingString:_lblDif_95.text];
                    }
                    else if (val2 == 0)
                    {
                        _lblDif_95.text = @"-";
                    }
                    else if (val2 < 0)
                    {
                        _lblDif_95.text =  _lblDif_95.text;
                    }
                }
                else if ([[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)] isEqualToString:@"Blue Gasohol 91"])
                {
                    _lbl91.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 2)];
                    _lblGas91_Tomorrow.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 3)];
                    
                    val1 = [_lbl91.text doubleValue];
                    val2 = [_lblGas91_Tomorrow.text doubleValue];
                    
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
                else if ([[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)] isEqualToString:@"Blue Gasohol E20"])
                {
                    _lblE20.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 2)];
                    _lblE20_Tomorrow.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 3)];
                    
                    val1 = [_lblE20.text doubleValue];
                    val2 = [_lblE20_Tomorrow.text doubleValue];
                    
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
                        _lblDif_E20.text = _lblDif_E20.text;
                    }
                }
                else if ([[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)] isEqualToString:@"Blue Gasohol 95"])
                {
                    _lblGas95.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 2)];
                    _lblGas95_Tomorrow.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 3)];
                    
                    val1 = [_lblGas95.text doubleValue];
                    val2 = [_lblGas95_Tomorrow.text doubleValue];
                    
                    val2 = val2 - val1;
                    _lblDif_Gas95.text = [NSString stringWithFormat:@"%.2lf", val2];
                    
                    if (val2 > 0)
                    {
                        _lblDif_Gas95.text = [@"+" stringByAppendingString:_lblDif_Gas95.text];
                    }
                    else if (val2 == 0)
                    {
                        _lblDif_Gas95.text = @"-";
                    }
                    else if (val2 < 0)
                    {
                        _lblDif_Gas95.text = _lblDif_Gas95.text;
                    }
                }
                else if ([[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)] isEqualToString:@"Blue Gasohol E85"])
                {
                    _lblE85.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 2)];
                    _lblE85_Tomorrow.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 3)];
                    
                    val1 = [_lblE85.text doubleValue];
                    val2 = [_lblE85_Tomorrow.text doubleValue];
                    
                    val2 = val2 - val1;
                    self.lblDif_E85.text = [NSString stringWithFormat:@"%.2lf", val2];
                    
                    if (val2 > 0)
                    {
                        self.lblDif_E85.text = [@"+" stringByAppendingString:self.lblDif_E85.text];
                    }
                    else if (val2 == 0)
                    {
                        self.lblDif_E85.text = @"-";
                    }
                    else if (val2 < 0)
                    {
                        self.lblDif_E85.text = _lblDif_E85.text;
                    }
                }
                else if ([[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)] isEqualToString:@"HyForce Premium Diesel"])
                {
                    _lblHfDiesel.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 2)];
                    _lblHfDiesel_Tomorrow.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 3)];
                    
                    val1 = [_lblHfDiesel.text doubleValue];
                    val2 = [_lblHfDiesel_Tomorrow.text doubleValue];
                    
                    val2 = val2 - val1;
                    _lblDif_HfDiesel.text = [NSString stringWithFormat:@"%.2lf", val2];
                    
                    if (val2 > 0)
                    {
                        self.lblDif_HfDiesel.text = [@"+" stringByAppendingString:self.lblDif_HfDiesel.text];
                    }
                    else if (val2 == 0)
                    {
                        self.lblDif_HfDiesel.text = @"-";
                    }
                    else if (val2 < 0)
                    {
                        self.lblDif_HfDiesel.text = _lblDif_HfDiesel.text;
                    }
                }
                else if ([[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 1)] isEqualToString:@"เอ็นจีวี"])
                {
                    _lblNGV.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 2)];
                    _lblNGV_Tomorrow.text = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement, 3)];
                    
                    val1 = [_lblNGV.text doubleValue];
                    val2 = [_lblNGV_Tomorrow.text doubleValue];
                    
                    val2 = val2 - val1;
                    self.lblDif_NGV.text = [NSString stringWithFormat:@"%.2lf", val2];
                    
                    if (val2 > 0)
                    {
                        self.lblDif_NGV.text = [@"+" stringByAppendingString:self.lblDif_NGV.text];
                    }
                    else if (val2 == 0)
                    {
                        self.lblDif_NGV.text = @"-";
                    }
                    else if (val2 < 0)
                    {
                        self.lblDif_NGV.text =  _lblDif_NGV.text;
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

@end
