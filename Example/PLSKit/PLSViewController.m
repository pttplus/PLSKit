//
//  PLSViewController.m
//  PLSKit
//
//  Created by wani on 05/02/2016.
//  Copyright (c) 2016 wani. All rights reserved.
//

#import "PLSViewController.h"

#import "PLSBannerDemoViewController.h"

@interface PLSViewController ()
@property (strong, nonatomic) NSArray *demoViewControllers;
@end

@implementation PLSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.demoViewControllers = @[@{@"name": @"PLSBanner", @"class": [PLSBannerDemoViewController class]}];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id demoViewController = self.demoViewControllers[indexPath.row];
    
    id viewController = [demoViewController[@"class"] new];

    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id demoViewController = self.demoViewControllers[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = demoViewController[@"name"];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.demoViewControllers.count;
}

@end
