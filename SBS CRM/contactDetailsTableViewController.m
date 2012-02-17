//
//  contactDetailsTableViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 14/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "contactDetailsTableViewController.h"
#import "mapViewController.h"
#import "AppDelegate.h"
#import "Communication.h"
#import "communicationSearch.h"
#import "eventsListTableViewController.h"
#import "DDXML.h"

@implementation contactDetailsTableViewController



@synthesize context;

@synthesize contactDetail;
@synthesize company;

@synthesize isCoreData;

@synthesize contactNameOutlet;
@synthesize siteNameDescriptionOutlet;
@synthesize addressOutlet;
@synthesize eventsOutlet;
@synthesize addressCell;

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
    
}
    
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //company = [[CompanySearch alloc] init];

    //create a name string using all of the name data available for the contact  --  if informtion exists append it to the string
    fullName = [[NSString alloc] initWithString:@""];
    if ([contactDetail.conTitle length])
        fullName = [fullName stringByAppendingFormat:@"%@ ",contactDetail.conTitle];
    if ([contactDetail.conFirstName length])
        fullName = [fullName stringByAppendingFormat:@"%@ ",contactDetail.conFirstName];
    if ([contactDetail.conMiddleName length])
        fullName = [fullName stringByAppendingFormat:@"%@ ",contactDetail.conMiddleName];
    if ([contactDetail.conSurname length])
        fullName = [fullName stringByAppendingString:contactDetail.conSurname];
    contactNameOutlet.text = fullName;
    siteNameDescriptionOutlet.text = [company.cosSiteName stringByAppendingFormat:@" - %@",company.cosDescription];

    if (isCoreData)
    {
            //load other required data from core data
            if (context == nil) { context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; }
            
            //set the entity to communication
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Communication" inManagedObjectContext:context];
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entity];
            
            // use a predicate to select the communication methods for the contact and remove UserWebPassword from the results
            NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                      @"(contactID == %@) AND cotDescription != 'UserWebPassword'", contactDetail.contactID];
            [request setPredicate:predicate];
            
            //Sort acendingly by the communication type
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                                initWithKey:@"cotDescription" ascending:YES];
            [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            
            NSError *error = nil;
            // request the data
            communicationArray = [[NSMutableArray alloc] initWithArray:[context executeFetchRequest:request error:&error]];
        
        NSLog(@"site name: %@", company.cosSiteName);
            if (!company)
            {
                    //load the address from the company entity using companySiteID as a predicate
                    entity = [NSEntityDescription entityForName:@"Company" inManagedObjectContext:context];
                    request = [[NSFetchRequest alloc] init];
                    [request setEntity:entity];
                    predicate = [NSPredicate predicateWithFormat:
                                              @"companySiteID == %@", contactDetail.companySiteID];
                    [request setPredicate:predicate];
                    NSArray *companyArray = [context executeFetchRequest:request error:&error];
                    //if results are returned out put the full address
                    if([companyArray count] >0)
                        company = [companyArray objectAtIndex:0];
            }

    }
    else// if not core data retrieve data from the server
    {
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ 
        
                // get communication details from the server and save them into the communicationArray
                NSError *error;
                NSURL *url = [[NSURL alloc] initWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchCommunicationByContactID?contactID=%@",contactDetail.contactID]];
                
                //indicate data is being retrieved via internet
                UIApplication *app = [UIApplication sharedApplication];  
                [app setNetworkActivityIndicatorVisible:YES]; 
                
                NSString *xmlString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
                
                [app setNetworkActivityIndicatorVisible:NO]; 
                
                NSLog(@"xml: %@  end of xml", xmlString);
                //remove xmlns from the xml file 
                xmlString = [xmlString stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
                NSData *xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
                DDXMLDocument *communicationDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:&error];
                
                //if company has not been sent (user has clicked on "Our Contact") then retrieve from server
                DDXMLDocument *companiesDocument;
                
                
                if (!company)
                {
                    // show the network activity indicator again
                    company = [[CompanySearch alloc] init];
                    [app setNetworkActivityIndicatorVisible:YES]; 
                    url = [[NSURL alloc] initWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchCompaniesByCompanySiteID?companySiteID=%@",contactDetail.companySiteID]];
                    xmlString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
                    //remove xmlns from the xml file 
                    xmlString = [xmlString stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
                    NSLog(@"xml: %@  end of xml", xmlString);
                    xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
                    companiesDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:&error];
                    [app setNetworkActivityIndicatorVisible:NO]; 
                }
            
                        //when the data has been fetched display it (using main queue):
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            
                            
                            NSArray* nodes = nil;
                            nodes = [[communicationDocument rootElement] children];
                            
                            communicationArray = [[NSMutableArray alloc] init];
                            for (DDXMLElement *element in nodes)
                            { 
                                communicationSearch *communication = [[communicationSearch alloc] init];
                                DDXMLElement *contactID = [[element nodesForXPath:@"contactID" error:nil] objectAtIndex:0];
                                communication.contactID = contactID.stringValue;
                                DDXMLElement *communicationNumberID = [[element nodesForXPath:@"communicationNumberID" error:nil] objectAtIndex:0];
                                communication.communicationNumberID = communicationNumberID.stringValue;
                                DDXMLElement *cmnEmail = [[element nodesForXPath:@"cmnEmail" error:nil] objectAtIndex:0];
                                communication.cmnEmail = cmnEmail.stringValue;
                                DDXMLElement *cmnInternationalCode = [[element nodesForXPath:@"cmnInternationalCode" error:nil] objectAtIndex:0];
                                communication.cmnInternationalCode = cmnInternationalCode.stringValue;
                                DDXMLElement *cmnAreaCode = [[element nodesForXPath:@"cmnAreaCode" error:nil] objectAtIndex:0];
                                communication.cmnAreaCode = cmnAreaCode.stringValue;
                                DDXMLElement *cmnNumber = [[element nodesForXPath:@"cmnNumber" error:nil] objectAtIndex:0];
                                communication.cmnNumber = cmnNumber.stringValue;
                                DDXMLElement *cotDescription = [[element nodesForXPath:@"cotDescription" error:nil] objectAtIndex:0];
                                communication.cotDescription = cotDescription.stringValue;
                                NSLog(@" communication description: %@", communication.cotDescription);
                                
                                //if the communication is of type UserWebPassword, don't display it.
                                if (![communication.cotDescription isEqualToString:@"UserWebPassword"]) 
                                    [communicationArray addObject:communication];
                            }
                            
                            if (!company.companySiteID) //check again that company needs to be created and set it up
                            {
                                NSArray* nodes2 = nil;
                                nodes2 = [[companiesDocument rootElement] children];
                                
                                for (DDXMLElement *element in nodes2)
                                { 
                                    company = [[CompanySearch alloc] init];
                                    DDXMLElement *companySiteID = [[element nodesForXPath:@"companySiteID" error:nil] objectAtIndex:0];
                                    company.companySiteID = companySiteID.stringValue;
                                    DDXMLElement *coaCompanyName = [[element nodesForXPath:@"coaCompanyName" error:nil] objectAtIndex:0];
                                    company.coaCompanyName = coaCompanyName.stringValue;
                                    DDXMLElement *cosSiteName = [[element nodesForXPath:@"cosSiteName" error:nil] objectAtIndex:0];
                                    company.cosSiteName = cosSiteName.stringValue;     
                                    DDXMLElement *cosDescription = [[element nodesForXPath:@"cosDescription" error:nil] objectAtIndex:0];
                                    company.cosDescription = cosDescription.stringValue;  
                                    DDXMLElement *addStreetAddress = [[element nodesForXPath:@"addStreetAddress" error:nil] objectAtIndex:0];
                                    company.addStreetAddress = addStreetAddress.stringValue; 
                                    DDXMLElement *addStreetAddress2 = [[element nodesForXPath:@"addStreetAddress2" error:nil] objectAtIndex:0];
                                    company.addStreetAddress2 = addStreetAddress2.stringValue; 
                                    DDXMLElement *addStreetAddress3 = [[element nodesForXPath:@"addStreetAddress3" error:nil] objectAtIndex:0];
                                    company.addStreetAddress3 = addStreetAddress3.stringValue; 
                                    DDXMLElement *addTown = [[element nodesForXPath:@"addTown" error:nil] objectAtIndex:0];
                                    company.addTown = addTown.stringValue;  
                                    DDXMLElement *addCounty = [[element nodesForXPath:@"addCounty" error:nil] objectAtIndex:0];
                                    company.addCounty = addCounty.stringValue; 
                                    DDXMLElement *addPostCode = [[element nodesForXPath:@"addPostCode" error:nil] objectAtIndex:0];
                                    company.addPostCode = addPostCode.stringValue; 
                                    DDXMLElement *couCountryName = [[element nodesForXPath:@"couCountryName" error:nil] objectAtIndex:0];
                                    company.couCountryName = couCountryName.stringValue; 
                                }
                            }
                            NSLog(@"company.cosSiteName: %@",company.cosSiteName);
                            siteNameDescriptionOutlet.text = [company.cosSiteName stringByAppendingFormat:@" - %@",company.cosDescription];
                            //ensure the data is displayed.
                            [self.tableView reloadData];
                        });
        });
                
    }
    
        

        
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView reloadData];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    if (section == 0) 
        return [communicationArray count];
    else
        return 1;
    
    
}

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0)
    {
        cell.hidden = YES;

    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 0)
    {
        tableView.sectionHeaderHeight = 0;
        return (CGFloat)0.0;
    }
    return 30;
}*/





- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";

    
    switch (indexPath.section)
    {
    case 0:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            }
            
            if ([communicationArray count] > indexPath.row)
            {
                communicationSearch *communication = [[communicationSearch alloc] init];
                communication = [communicationArray objectAtIndex:indexPath.row];
                NSLog(@"desction:%@",communication.cotDescription);
                //label the cell according to the data inside (cannot use objcetive c switch statement with strings).
                if ([communication.cotDescription isEqualToString:@"Email"])
                    cell.detailTextLabel.text = communication.cmnEmail;
                if ([communication.cotDescription isEqualToString:@"Fax"] || [communication.cotDescription isEqualToString:@"Telephone"])
                    cell.detailTextLabel.text = [communication.cmnInternationalCode stringByAppendingFormat:@"%@%@",communication.cmnAreaCode,communication.cmnNumber];
                if ([communication.cotDescription isEqualToString:@"Mobile"])
                    cell.detailTextLabel.text = [communication.cmnInternationalCode stringByAppendingFormat:@"%@%@",communication.cmnAreaCode,communication.cmnNumber];
                cell.textLabel.text = communication.cotDescription;
            }
            return cell;
        }
    case 1:
        {
            
            //concatenate the full address and display - could append them all into one string then replace "\n\n" with "\n" but would need to be done multiple times in case there are 3 or more new lines together.
            fullAddress = [[NSString alloc] initWithString:@""];
            if ([company.addStreetAddress length])
                fullAddress = [fullAddress stringByAppendingFormat:@"%@\n",company.addStreetAddress];
            if ([company.addStreetAddress2 length])
                fullAddress = [fullAddress stringByAppendingFormat:@"%@\n",company.addStreetAddress2];
            if ([company.addStreetAddress3 length])
                fullAddress = [fullAddress stringByAppendingFormat:@"%@\n",company.addStreetAddress3];
            if ([company.addCounty length])
                fullAddress = [fullAddress stringByAppendingFormat:@"%@\n",company.addCounty];
            if ([company.addTown length])
                fullAddress = [fullAddress stringByAppendingFormat:@"%@\n",company.addTown];
            if ([company.couCountryName length])
                fullAddress = [fullAddress stringByAppendingFormat:@"%@\n",company.couCountryName];
            if ([company.addPostCode length])
                fullAddress = [fullAddress stringByAppendingFormat:@"%@",company.addPostCode];
            addressOutlet.text = fullAddress;
            return addressCell;
        }
   case 2: // events cell
        {
            return eventsOutlet;
        }
    }

    
    //NSLog(@"%@", indexPath.section);

}
 

- (void)viewDidUnload
{
    [self setContactNameOutlet:nil];
    [self setSiteNameDescriptionOutlet:nil];
    [self setAddressOutlet:nil];
    [self setEventsOutlet:nil];
    [self setAddressCell:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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






#pragma mark - Table view data source

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
    //if the user has clicked on a contact methods cell
    if (indexPath.section == 0)
    {
        if([[[communicationArray objectAtIndex:indexPath.row] cotDescription] isEqualToString:@"Telephone"])                                   
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat: @"tel://%@%@%@",[[communicationArray objectAtIndex:indexPath.row] cmnInternationalCode],[[communicationArray objectAtIndex:indexPath.row] cmnAreaCode],[[communicationArray objectAtIndex:indexPath.row] cmnNumber]]]];
        else if([[[communicationArray objectAtIndex:indexPath.row] cotDescription] isEqualToString:@"Mobile"])                                   
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat: @"tel://%@%@%@",[[communicationArray objectAtIndex:indexPath.row] cmnInternationalCode],[[communicationArray objectAtIndex:indexPath.row] cmnAreaCode],[[communicationArray objectAtIndex:indexPath.row] cmnNumber]]]];
        else if ([[[communicationArray objectAtIndex:indexPath.row] cotDescription] isEqualToString:@"Email"])                                   
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat: @"mailto://%@", [[communicationArray objectAtIndex:indexPath.row] cmnEmail]]]];
    }
  

    /*
    
    
    NSLog(@"desction:%@",communication.cotDescription);
    //label the cell according to the data inside (cannot use objcetive c switch statement with strings).
    if ([communication.cotDescription isEqualToString:@"Email"])
        cell.detailTextLabel.text = communication.cmnEmail;
    if ([communication.cotDescription isEqualToString:@"Fax"] || [communication.cotDescription isEqualToString:@"Telephone"])
        cell.detailTextLabel.text = [communication.cmnInternationalCode stringByAppendingFormat:@"%@%@",communication.cmnAreaCode,communication.cmnNumber];
    if ([communication.cotDescription isEqualToString:@"Mobile"])
        cell.detailTextLabel.text = [communication.cmnInternationalCode stringByAppendingFormat:@"%@%@",communication.cmnAreaCode,communication.cmnNumber];
    cell.textLabel.text = communication.cotDescription;
}
*/
        
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
    if ([segue.identifier isEqualToString:@"toMap"])
    {
        //set up the required data in the Map View controller        
        mapViewController *mapController = segue.destinationViewController;
        mapController.address = fullAddress;
        mapController.companyName = contactDetail.cosSiteName;
    }
    else if ([segue.identifier isEqualToString:@"toEventsList"])
    {
        // create list view controller, set the required variables.       
        eventsListTableViewController *listViewController = segue.destinationViewController;
        listViewController.contact = contactDetail;
        listViewController.company = company;
        //send full name for view title;
        listViewController.viewTitle = fullName;
    }
}


@end
