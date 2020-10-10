//
//  AppDelegate.m
//  Check Oil Price
//
//  Created by Sahaphon_mac on 1/19/18.
//  Copyright © 2018 rich_noname. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //Set the application badge number  ใส่ตัวเลขแจ้งเตือนไอคอน app
    /*
    UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    */
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)ShowAlert:(NSString *)str
{
    UIWindow* topWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    topWindow.rootViewController = [UIViewController new];
    topWindow.windowLevel = UIWindowLevelAlert + 1;
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"แจ้งเตือน" message:str
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"confirm") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // continue your work
        
        // important to hide the window after work completed.
        // this also keeps a reference to the window until the action is invoked.
        topWindow.hidden = YES;
    }]];
    
    [topWindow makeKeyAndVisible];
    [topWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

-(void)onTick:(NSTimer *)timer
{
    //Sync webservice เมื่อสามารถเข้าถึง internet
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Set the blocks
    reach.reachableBlock = ^(Reachability*reach)
    {
        // keep in mind this is called on a background thread
        // and if you are updating the UI it needs to happen
        // on the main thread, like this:
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self ShowAlert:@"เชื่อมต่อ"];
            NSLog(@"REACHABLE!");
        });
    };
    
    reach.unreachableBlock = ^(Reachability*reach)
    {
        NSLog(@"UNREACHABLE!");
    };
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [reach startNotifier];
}


@end
