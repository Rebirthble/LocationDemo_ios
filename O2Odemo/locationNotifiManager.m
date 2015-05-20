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

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusDenied){
        //localNotificationを削除
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}

- (void)searchLocations:(NSString*)locationId{
    
    NCMBObject *location = [NCMBObject objectWithClassName:@"Location"];
    location.objectId = locationId;
    [location fetchInBackgroundWithBlock:^(NSError *error) {
        if (error){
            NSLog(@"error:%@", error);
            //TODO:エラー処理
        } else {
            
            //Geolocation Notification設定
            NCMBGeoPoint *point = [location objectForKey:@"geo"];
            [self updateLocation:point];
        }
    }];
}

- (void)updateLocation:(NCMBGeoPoint*)geoPoint{
    
    NSLog(@"latitude:%f, longitude:%f", geoPoint.latitude, geoPoint.longitude);
    
    self.mLocationManager = [[CLLocationManager alloc] init];
    self.mLocationManager.delegate = self;
    [self.mLocationManager requestWhenInUseAuthorization];
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.alertBody = [NSString stringWithFormat:@"近くでセール開催中！"];
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    
    if (geoPoint){
        CLCircularRegion *region = nil;
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
        if (CLLocationCoordinate2DIsValid(location)){
            region = [[CLCircularRegion alloc] initWithCenter:location
                                                                         radius:500.0
                                                                     identifier:@"salePoint"];
            region.notifyOnExit = NO;
            CLLocation *current = [self.mLocationManager location];
            if([region containsCoordinate:CLLocationCoordinate2DMake(current.coordinate.latitude, current.coordinate.longitude)]){
                NSLog(@"presentedNotification");
                [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
            } else {
                NSLog(@"scheduledNotification");
                localNotif.region = region;
                localNotif.regionTriggersOnce = YES;
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
            }
        } else {
            //TODO:エラー処理
            NSLog(@"geoPoint is null");
        }
        
    }
    
    
}

@end
