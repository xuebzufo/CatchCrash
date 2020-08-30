//
//  ViewController.m
//  CatchCrash
//
//  Created by Sem on 2020/8/28.
//  Copyright © 2020 SEM. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSArray *dd =@[@"1",@"2"];
       NSString *z =dd[3];
       NSLog(@"~~~~~%@",z);
}
@end
