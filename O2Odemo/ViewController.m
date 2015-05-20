//
//  ViewController.m
//  O2Odemo
//
//  Created by 大川雄生 on 2015/05/14.
//  Copyright (c) 2015年 大川雄生. All rights reserved.
//

#import "ViewController.h"

#import "locationNotifiManager.h"

@interface ViewController ()
- (IBAction)updateLocationTest:(id)sender;

@end

static locationNotifiManager *manager = nil;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    manager = [[locationNotifiManager alloc] init];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)updateLocationTest:(id)sender {
    
    NSError *error = nil;
    [manager searchLocations:@"dyn791WWeuD7Nrif" error:&error];
    if (error){
        NSLog(@"error:%@",error);
    }
}


@end
