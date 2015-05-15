//
//  locationNotifiManager.h
//  O2Odemo
//
//  Created by 大川雄生 on 2015/05/15.
//  Copyright (c) 2015年 大川雄生. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <NCMB/NCMB.h>

@interface locationNotifiManager : NSObject<CLLocationManagerDelegate>

- (void)searchLocations:(NSString*)locationId;

- (void)updateLocation:(NCMBGeoPoint*)geoPoint;

@end
