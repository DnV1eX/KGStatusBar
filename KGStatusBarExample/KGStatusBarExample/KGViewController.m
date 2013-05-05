//
//  KGViewController.m
//  KGStatusBarExample
//
//  Created by Kevin Gibbon on 3/3/13.
//  Copyright (c) 2013 Kevin Gibbon. All rights reserved.
//

#import "KGViewController.h"

@interface KGViewController ()

- (IBAction)successButtonPressed:(id)sender;
- (IBAction)errorButtonPressed:(id)sender;
- (IBAction)statusButtonPressed:(id)sender;
- (IBAction)dismissButtonPressed:(id)sender;


@end

@implementation KGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[[NSNotificationCenter defaultCenter] addObserverForName:KGStatusBarTapNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status Bar has been tapped" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 200, self.view.bounds.size.width, self.view.bounds.size.height - 200) style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)successButtonPressed:(id)sender {
    [KGStatusBar showSuccessWithStatus:@"Successfully synced"];
}

- (IBAction)errorButtonPressed:(id)sender {
    [KGStatusBar showErrorWithStatus:@"Error syncing files"];
}

- (IBAction)statusButtonPressed:(id)sender {
    [KGStatusBar showLoadingWithStatus:@"Loading..."];
}

- (IBAction)dismissButtonPressed:(id)sender {
    [KGStatusBar dismiss];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Scroll to Top";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.textLabel.text = @(indexPath.row).stringValue;
    return cell;
}

@end
