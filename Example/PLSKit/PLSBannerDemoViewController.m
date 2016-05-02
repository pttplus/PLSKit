//
//  PLSBannerDemoViewController.m
//  PLSKit
//
//  Created by CBLUE on 5/2/16.
//  Copyright © 2016 wani. All rights reserved.
//

#import "PLSBannerDemoViewController.h"
#import <PLSKit/PLSBanner.h>

@interface PLSBannerDemoViewController ()

@end

@implementation PLSBannerDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
    UIButton *buttonShowBanner = [UIButton new];
    [buttonShowBanner setTitle:@"Show Banner" forState:UIControlStateNormal];
    buttonShowBanner.translatesAutoresizingMaskIntoConstraints = NO;
    buttonShowBanner.backgroundColor = [UIColor lightGrayColor];
    [buttonShowBanner addTarget:self action:@selector(actionShowBanner:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonShowBanner];
    
    id views = NSDictionaryOfVariableBindings(buttonShowBanner);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-132-[buttonShowBanner]" options:0 metrics:nil views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-22-[buttonShowBanner]" options:0 metrics:nil views:views]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[PLSBanner bannersOnView:self.navigationController.view] enumerateObjectsUsingBlock:^(PLSBanner * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj hide];
    }];
}

- (IBAction)actionShowBanner:(id)sender {
    PLSBanner *banner = [[PLSBanner alloc] initWithNavigationViewController:self.navigationController];
    [banner show];
}

@end
