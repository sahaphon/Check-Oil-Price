//
//  BangchakViewController.h
//  Check Oil Price
//
//  Created by Sahaphon_mac on 1/26/18.
//  Copyright © 2018 rich_noname. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMXMLDocument.h"
#import "sqlite3.h"

@import GoogleMobileAds;
@interface BangchakViewController : UIViewController <GADBannerViewDelegate>

@property(strong,nonatomic) NSString *databasePath;
@property(nonatomic) sqlite3 *db;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *Activity;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (retain, nonatomic) IBOutlet GADBannerView *bannerView;



@property (weak, nonatomic) IBOutlet UILabel *lblHiPreDiesel;
@property (weak, nonatomic) IBOutlet UILabel *lblDiesel;
@property (weak, nonatomic) IBOutlet UILabel *lblE85;
@property (weak, nonatomic) IBOutlet UILabel *lblE20;
@property (weak, nonatomic) IBOutlet UILabel *lbl91;
@property (weak, nonatomic) IBOutlet UILabel *lbl95;
@property (weak, nonatomic) IBOutlet UILabel *lblNgv;


@property (weak, nonatomic) IBOutlet UILabel *lblHiPreDiesel_tomorrow;
@property (weak, nonatomic) IBOutlet UILabel *lblDisel_tomorrow;
@property (weak, nonatomic) IBOutlet UILabel *lblE85_tomorrow;
@property (weak, nonatomic) IBOutlet UILabel *lblE20_tomorrow;
@property (weak, nonatomic) IBOutlet UILabel *lbl91_tomorrow;
@property (weak, nonatomic) IBOutlet UILabel *lbl95_tomorrow;
@property (weak, nonatomic) IBOutlet UILabel *lblNgv_tomorrow;


@property (weak, nonatomic) IBOutlet UILabel *lblDif_HiPreDiesel;
@property (weak, nonatomic) IBOutlet UILabel *lblDif_Hidiesel;
@property (weak, nonatomic) IBOutlet UILabel *lblDif_E85;
@property (weak, nonatomic) IBOutlet UILabel *lblDif_E20;
@property (weak, nonatomic) IBOutlet UILabel *lblDif_91;
@property (weak, nonatomic) IBOutlet UILabel *lblDif_95;
@property (weak, nonatomic) IBOutlet UILabel *lblDif_ngv;

@property (strong, nonatomic) NSArray* mDataArray;  // ตัวเเปรเก็บ arrar ตอนโหลดข้อมูลราคาน้ำมัน
@property (strong, nonatomic) NSArray* mDataArray2;  // ตัวแปรเก็บราคาน้ำมัน วันพรุ่งนี้

@end
