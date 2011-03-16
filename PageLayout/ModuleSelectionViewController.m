//
//  ModuleSelectionViewController.m
//  PageLayout
//
//  Created by Andrew Pouliot on 3/15/11.
//  Copyright 2011 Darknoon. All rights reserved.
//

#import "ModuleSelectionViewController.h"

#import "StoryViewController.h"

NSString *SelectedModuleUserDefaultsKey = @"SelectedModule";

@implementation ModuleSelectionViewController

- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	if (!self) return nil;
	
	
	return self;
}


- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	
	if (!_issues) {
		
		NSMutableArray *array = [[NSMutableArray alloc] init];
		
		[array addObject: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Issues/Test"]];
		
		_issues = array;
		
	}
	
	NSString *selectedModule = [[NSUserDefaults standardUserDefaults] objectForKey:SelectedModuleUserDefaultsKey];
	if ([_issues containsObject:selectedModule]) {
		StoryViewController *detailViewController = [[[StoryViewController alloc] initWithModulePath:selectedModule] autorelease];
		[self.navigationController pushViewController:detailViewController animated:NO];
	}
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO; 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
	if (self.navigationController.viewControllers.count == 1) {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:SelectedModuleUserDefaultsKey];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _issues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.textLabel.text = [[_issues objectAtIndex:indexPath.row] lastPathComponent];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *module = [_issues objectAtIndex:indexPath.row];
	StoryViewController *detailViewController = [[[StoryViewController alloc] initWithModulePath:module] autorelease];
	[self.navigationController pushViewController:detailViewController animated:YES];
	[[NSUserDefaults standardUserDefaults] setObject:module forKey:SelectedModuleUserDefaultsKey];
}

@end
