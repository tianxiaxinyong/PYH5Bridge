//
//  PYViewController.m
//  PYH5Bridge
//
//  Created by persistnoabandon@gmail.com on 01/11/2018.
//  Copyright (c) 2018 persistnoabandon@gmail.com. All rights reserved.
//

#import "PYViewController.h"
#import "ShowByWKWebViewController.h"

@interface PYViewController ()
- (IBAction)H5TouchUpInside:(id)sender;

@end

@implementation PYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)H5TouchUpInside:(id)sender {
    ShowByWKWebViewController *contrl = [[ShowByWKWebViewController alloc] init];
    [self.navigationController pushViewController:contrl animated:YES];
}
@end
