/*
 Copyright (c) 2011, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "RootViewController.h"
#import "LibraryAPI.h"

#import "SFRestAPI.h"
#import "SFRestRequest.h"
#import "Account.h"
#import "Contact.h"
@interface RootViewController()
@property (nonatomic, strong) NSArray *contacts;
@end
@implementation RootViewController

@synthesize dataRows;

#pragma mark Misc

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    self.dataRows = nil;
}


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Mobile SDK Sample App";
//    Class class = NSClassFromString(@"Account");
//    NSObject *object = [[class alloc] init];
//    object_setInstanceVariable(object, [@"name" UTF8String], @"yes");
//    NSString *outputValue;
//    object_getInstanceVariable(object, [@"name" UTF8String], &outputValue);
//    Account *acc = (Account *)object;
//    NSLog(@"value %@",outputValue);

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReceived:) name:@"DATA_RECEIVED_NOTIFICATION" object:nil];
    //Here we use a query that should work on either Force.com or Database.com
//    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:@"SELECT Name FROM User LIMIT 10"];    
//    [[SFRestAPI sharedInstance] send:request delegate:self];
    [[LibraryAPI sharedInstane] startSync];
}

- (void)dataReceived:(NSNotification *)notification{
   self.dataRows = [[[LibraryAPI sharedInstane] modelObjects] objectForKey:@"Account"];
    _contacts = [[[LibraryAPI sharedInstane] modelObjects] objectForKey:@"Contact"];
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataRows count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   static NSString *CellIdentifier = @"CellIdentifier";

   // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];

    }
	//if you want to add an image to your cell, here's how
	UIImage *image = [UIImage imageNamed:@"icon.png"];
	cell.imageView.image = image;

	// Configure the cell to show the data.
	Account *obj = (Account *)[dataRows objectAtIndex:indexPath.row];
//    NSString *value;
//    object_getInstanceVariable(obj,[@"name" UTF8String], &value);
	cell.textLabel.text =  obj.name;
    
    NSArray *children = [_contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"account.id = %@",obj.id]];
	//this adds the arrow to the right hand side.
    if (children.count) {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    } else {
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

	return cell;

}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}
@end
