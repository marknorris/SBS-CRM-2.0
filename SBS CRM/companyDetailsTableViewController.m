//
//  companyDetailsTableViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 14/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "companyDetailsTableViewController.h"
#import "mapViewController.h"
#import "eventsListTableViewController.h"
#import "contactListTableViewController.h"


@implementation companyDetailsTableViewController

@synthesize txtAddress;
@synthesize lblSiteName;
@synthesize lblDescription;

@synthesize companyDetail;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
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
    
    
    lblSiteName.text = companyDetail.cosSiteName;
    lblDescription.text = companyDetail.cosDescription;

    fullAddress = [[NSString alloc] initWithString:@""];
    if ([companyDetail.addStreetAddress length])
        fullAddress = [fullAddress stringByAppendingFormat:@"%@\n",companyDetail.addStreetAddress];
    if ([companyDetail.addStreetAddress2 length])
        fullAddress = [fullAddress stringByAppendingFormat:@"%@\n",companyDetail.addStreetAddress2];
    if ([companyDetail.addStreetAddress3 length])
        fullAddress = [fullAddress stringByAppendingFormat:@"%@\n",companyDetail.addStreetAddress3];
    if ([companyDetail.addCounty length])
        fullAddress = [fullAddress stringByAppendingFormat:@"%@\n",companyDetail.addCounty];
    if ([companyDetail.addTown length])
        fullAddress = [fullAddress stringByAppendingFormat:@"%@\n",companyDetail.addTown];
    if ([companyDetail.couCountryName length])
        fullAddress = [fullAddress stringByAppendingFormat:@"%@\n",companyDetail.couCountryName];
    if ([companyDetail.addPostCode length])
        fullAddress = [fullAddress stringByAppendingFormat:@"%@",companyDetail.addPostCode];
    // TODO could append all with newlines then remove multiple occurances of \n but could be 2,3 or more in a row...
    // fullAddress = [fullAddress stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
    txtAddress.text = fullAddress;
        
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{


    [self setLblDescription:nil];
    [self setLblSiteName:nil];
    [self setTxtAddress:nil];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //if the segue is to the details screen
    if ([segue.identifier isEqualToString:@"toMap"])
    {
        //set up the required data in the Map View controller        
        mapViewController *mapController = segue.destinationViewController;
        mapController.address = fullAddress;
        mapController.companyName = companyDetail.cosSiteName;
        
    }
    else if ([segue.identifier isEqualToString:@"toEventsList"])
    {
        // create list view controller, set the required variables.     
        eventsListTableViewController *listViewController = segue.destinationViewController;
        listViewController.company = companyDetail;
        //send site name for view title
        listViewController.viewTitle = companyDetail.cosSiteName;
    }
    else if ([segue.identifier isEqualToString:@"toContactList"])
    {
        // create list view controller, set the required variables.     
        contactListTableViewController *listViewController = segue.destinationViewController;
        listViewController.company = [[CompanySearch alloc] init];
        listViewController.company = companyDetail;
    }
}

@end
