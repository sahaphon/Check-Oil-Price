//
//  ViewController.h
//  Check Oil Price
//
//  Created by Sahaphon_mac on 1/19/18.
//  Copyright © 2018 rich_noname. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMXMLDocument.h"
#import "sqlite3.h"

@import GoogleMobileAds;
@interface ViewController : UIViewController <GADBannerViewDelegate>

@property(strong,nonatomic) NSString *databasePath;
@property(nonatomic) sqlite3 *db;
@property (retain, nonatomic) IBOutlet GADBannerView *bannerView;

@property (weak, nonatomic) IBOutlet UILabel *lbldate;
@property (weak, nonatomic) IBOutlet UILabel *lblDiesale;
@property (weak, nonatomic) IBOutlet UILabel *lbl95;
@property (weak, nonatomic) IBOutlet UILabel *lbl91;
@property (weak, nonatomic) IBOutlet UILabel *lblE20;
@property (weak, nonatomic) IBOutlet UILabel *lblGas95;
@property (weak, nonatomic) IBOutlet UILabel *lblE85;
@property (weak, nonatomic) IBOutlet UILabel *lblHfDiesel;
@property (weak, nonatomic) IBOutlet UILabel *lblNGV;

@property (weak, nonatomic) IBOutlet UILabel *lblHfDiesel_Tomorrow;
@property (weak, nonatomic) IBOutlet UILabel *lblDies_Tomorrow;
@property (weak, nonatomic) IBOutlet UILabel *lbl95_Tomorrow;
@property (weak, nonatomic) IBOutlet UILabel *lblGas91_Tomorrow;
@property (weak, nonatomic) IBOutlet UILabel *lblE20_Tomorrow;
@property (weak, nonatomic) IBOutlet UILabel *lblGas95_Tomorrow;
@property (weak, nonatomic) IBOutlet UILabel *lblE85_Tomorrow;
@property (weak, nonatomic) IBOutlet UILabel *lblNGV_Tomorrow;


@property (weak, nonatomic) IBOutlet UILabel *lblDif_HfDiesel;
@property (weak, nonatomic) IBOutlet UILabel *lblDif_diesel;
@property (weak, nonatomic) IBOutlet UILabel *lblDif_95;
@property (weak, nonatomic) IBOutlet UILabel *lblDif_91;
@property (weak, nonatomic) IBOutlet UILabel *lblDif_E20;
@property (weak, nonatomic) IBOutlet UILabel *lblDif_Gas95;
@property (weak, nonatomic) IBOutlet UILabel *lblDif_E85;
@property (weak, nonatomic) IBOutlet UILabel *lblDif_NGV;


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) NSArray* mDataArray;  // ตัวเเปรเก็บ arrar ตอนโหลดข้อมูลราคาน้ำมัน
@property (strong, nonatomic) NSArray* mDataArray2;  // ตัวแปรเก็บราคาน้ำมัน วันพรุ่งนี้

-(void)CallWebService;
-(void)handleResponseData:(NSData *) _responseData;

@end

