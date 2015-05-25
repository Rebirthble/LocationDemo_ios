//
//  locationNotifiManager.m
//  O2Odemo
//
//  Created by 大川雄生 on 2015/05/15.
//  Copyright (c) 2015年 大川雄生. All rights reserved.
//

#import "locationNotifiManager.h"

@interface locationNotifiManager ()

@property (nonatomic, strong) CLLocationManager *mLocationManager;

@end

@implementation locationNotifiManager

-(instancetype)init{
    //位置情報を使用する許可画面を表示
    self = [super init];
    self.mLocationManager = [[CLLocationManager alloc] init];
    self.mLocationManager.delegate = self;
    [self.mLocationManager requestWhenInUseAuthorization];
    
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusDenied){
        //localNotificationを削除
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}

- (void)searchLocations:(NSString*)locationId block:(void (^)(NSError *error))blk{
    
    NSLog(@"seachLocations");
    NCMBObject *location = [NCMBObject objectWithClassName:@"Location"];
    location.objectId = locationId;
    [location fetchInBackgroundWithBlock:^(NSError *localError) {
        if (localError){
            blk(localError);
        } else {
            
            //Location Notification設定
            NCMBGeoPoint *point = [location objectForKey:@"geo"];
            [self updateLocation:point block:^(NSError *error) {
                if (error){
                    blk(error);
                } else {
                    blk(nil);
                }
            }];
        }
    }];
}

- (void)updateLocation:(NCMBGeoPoint*)geoPoint block:(void (^)(NSError *error))blk{
    
    NSLog(@"updateLocation");
    //以前に登録されたNotificationを全てキャンセル
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    //Notificationを作成
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.alertBody = [NSString stringWithFormat:@"近くでセール開催中！"];
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    
    //引数の位置情報からCLLocationCoordinate2Dを作成
    CLCircularRegion *region = nil;
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    if (CLLocationCoordinate2DIsValid(location)){
        
        //リージョンを作成
        region = [[CLCircularRegion alloc] initWithCenter:location
                                                   radius:500.0
                                               identifier:@"salePoint"];
        region.notifyOnExit = NO;
        localNotif.region = region;
        localNotif.regionTriggersOnce = YES;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        blk(nil);
        /*
        CLLocation *current = [self.mLocationManager location];
        NSLog(@"latitude:%f, longitude:%f", current.coordinate.latitude, current.coordinate.longitude);
        if([region containsCoordinate:CLLocationCoordinate2DMake(current.coordinate.latitude, current.coordinate.longitude)]){
            
            NSLog(@"Presented Notification.");
            //現在地がregion内だった場合は、Local Notificationを即時に表示させる
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
        } else {
            
            NSLog(@"Scheduled Notification.");
            //現在地がregion外なので、Location Notificationをスケジューリングする
            localNotif.region = region;
            localNotif.regionTriggersOnce = YES;
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
            
            blk(nil);
        }
         */
    } else {
        NSError *error = [NSError errorWithDomain:@"InvalidCLLocationError"
                                             code:1999
                                         userInfo:@{NSLocalizedDescriptionKey:@"Invalid coordinate info."}];
        blk(error);
    }
}

@end
