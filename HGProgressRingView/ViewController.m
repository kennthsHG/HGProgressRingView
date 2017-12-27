//
//  ViewController.m
//  HGProgressRingView
//
//  Created by gang on 2017/12/14.
//  Copyright © 2017年 gang. All rights reserved.
//

#import "ViewController.h"

#import "HGProgressRingView.h"

#define kDeviceWidth                [UIScreen mainScreen].bounds.size.width
#define KDeviceHeight               [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
@property (strong,nonatomic)HGProgressRingView * pview;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pview = [[HGProgressRingView alloc]initWithFrame:CGRectMake(0, 100, kDeviceWidth / 2, kDeviceWidth / 2) ProgressDetailsArray:@[@"30",@"40",@"100",@"30",@"40",@"40"] ProgressColorArray:@[] type:HGProgressRingTypePie clockwise:NO];
    self.pview.progressLineWidth = 25.f;
    self.pview.showPercentage = YES;
    self.pview.NumColor = [UIColor redColor];
    [self.view addSubview:self.pview];
    
    [self.pview startProgress:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
