//
//  eventDetailsTableViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 15/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "eventDetailsTableViewController.h"
#import "textViewController.h"
#import "companyDetailsTableViewController.h"
#import "contactDetailsTableViewController.h"
#import "AppDelegate.h"
#import "Attachment.h"
#import "DDXML.h"

@implementation eventDetailsTableViewController

@synthesize isCoreData;

@synthesize eventDetails;
@synthesize company;
@synthesize contact;
@synthesize ourContact;

@synthesize lblTitle;
@synthesize lblType;
@synthesize lblCustomer;
@synthesize lblDueDateTime;
@synthesize lblEndDateTime;
@synthesize cellLblSite;
@synthesize cellLblContact;
@synthesize txtComments;
@synthesize cellLblCreateByName;
@synthesize cellLblCreateByDateTime;
@synthesize cellLblOurContact;
@synthesize cellComments;
@synthesize cellCommentLink;

@synthesize context;

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
    
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    attachmentArray = [[NSMutableArray alloc] init];
    NSURL *url;
    NSString *xmlString;
    NSData *xmlData;      
    NSError *error;
    
    
    //if the required event details is stored within core data
    if (isCoreData)
    {
            if (context == nil) { context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; }
            NSError *error = nil;
        
            // Get the details of the event from core data
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Events" inManagedObjectContext:context];
            NSFetchRequest *request = [[NSFetchRequest alloc] init];

            [request setEntity:entity];

            NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                      @"eventID == %@", eventDetails.eventID];
            [request setPredicate:predicate];
        
            NSArray *eventsArray = [context executeFetchRequest:request error:&error];
            if ([eventsArray count] > 0)
            {
                eventDetails = [eventsArray objectAtIndex:0];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"No event data" message:@"Can't display event details" delegate:self cancelButtonTitle:@"No" otherButtonTitles:nil, nil] show];
                return;
                //stop loading the page
            }
            
            //get company data
            entity = [NSEntityDescription entityForName:@"Company" inManagedObjectContext:context];
            [request setEntity:entity];
            predicate = [NSPredicate predicateWithFormat:
                         @"companySiteID == %@", eventDetails.companySiteID];
        
            [request setPredicate:predicate];
            
            NSArray *companyArray = [context executeFetchRequest:request error:&error];
            if ([companyArray count] > 0) // check that there is a company in the array before accessing it
                company = [companyArray objectAtIndex:0];
            else
            {
                company.cosSiteName = @"No company";
                company.cosDescription = @"Can't display details.";
            }
            
            //get contact data
            entity = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:context];
            [request setEntity:entity];
        
            predicate = [NSPredicate predicateWithFormat:
                         @"contactID == %@ AND companySiteID == %@", eventDetails.contactID, eventDetails.companySiteID];
            [request setPredicate:predicate];
            
            NSArray *contactArray = [context executeFetchRequest:request error:&error];
            if ([contactArray count] >0)
                contact = [contactArray objectAtIndex:0];
            
            //get attachment data
            entity = [NSEntityDescription entityForName:@"Attachment" inManagedObjectContext:context];
            request = [[NSFetchRequest alloc] init];
            [request setEntity:entity];
            
            predicate = [NSPredicate predicateWithFormat:
                                      @"eventID == %@", eventDetails.eventID];
            [request setPredicate:predicate];
            
            [attachmentArray addObjectsFromArray:[context executeFetchRequest:request error:&error]];
            
            if (error)
            {
                [[[UIAlertView alloc] initWithTitle:@"Core Data" message:@"Cannot load event from core data" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
            
    }
    else // load the data from the web
    {
     
        // TODO
        // load from the web here
        // need: (contact), attachments
        
 
        // get the attchacment from the server
        url = [[NSURL alloc] initWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchAttachmentsByEventID?eventID=%@",eventDetails.eventID]];
        xmlString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];

        //remove xmlns from the xml file 
        xmlString = [xmlString stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
        xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
        DDXMLDocument *attachmentsDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:&error];
        
        if (context == nil) { context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; }

        // save newly retrieved events to coredata
        NSArray* nodes = nil;
        nodes = [[attachmentsDocument rootElement] children];
        
        for (DDXMLElement *element in nodes)
        { 
            Attachment *attachment = (Attachment *)[NSEntityDescription insertNewObjectForEntityForName:@"Attachment" inManagedObjectContext:context]; 
            DDXMLElement *eventID = [[element nodesForXPath:@"eventID" error:nil] objectAtIndex:0];
            attachment.eventID = eventID.stringValue;
            DDXMLElement *attachmentID = [[element nodesForXPath:@"attachmentID" error:nil] objectAtIndex:0];
            attachment.attachmentID = attachmentID.stringValue;
            DDXMLElement *attDescription = [[element nodesForXPath:@"attDescription" error:nil] objectAtIndex:0];
            attachment.attDescription = attDescription.stringValue;
            DDXMLElement *atyMnemonic = [[element nodesForXPath:@"atyMnemonic" error:nil] objectAtIndex:0];
            attachment.atyMnemonic = atyMnemonic.stringValue;
            
            [attachmentArray addObject:attachment];
        }
    
        
        if (!contact)
        {
            contact = [[contactSearch alloc] init];
            //get contact from server
            url = [[NSURL alloc] initWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchContactsByContactID?searchContactID=%@",eventDetails.contactID]];
            xmlString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
            //remove xmlns from the xml file 
            xmlString = [xmlString stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
            NSLog(@" xml string: %@ end of xml string",xmlString);
            NSLog(@"contact id: %@",eventDetails.contactID);
            xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
            DDXMLDocument *contactsDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:&error];
            
            NSArray* nodes = nil;
            nodes = [[contactsDocument rootElement] children];
            NSLog(@"contact name: %d",[nodes count]);
            for (DDXMLElement *element in nodes)
            { 
                DDXMLElement *contactID = [[element nodesForXPath:@"contactID" error:nil] objectAtIndex:0];
                contact.contactID = contactID.stringValue;
                DDXMLElement *conTitle = [[element nodesForXPath:@"conTitle" error:nil] objectAtIndex:0];
                contact.conTitle = conTitle.stringValue;
                DDXMLElement *conFirstName = [[element nodesForXPath:@"conFirstName" error:nil] objectAtIndex:0];
                contact.conFirstName = conFirstName.stringValue;
                DDXMLElement *conMiddleName = [[element nodesForXPath:@"conMiddleName" error:nil] objectAtIndex:0];
                contact.conMiddleName = conMiddleName.stringValue;
                DDXMLElement *conSurname = [[element nodesForXPath:@"conSurname" error:nil] objectAtIndex:0];
                contact.conSurname = conSurname.stringValue;
                
                DDXMLElement *companySiteID = [[element nodesForXPath:@"companySiteID" error:nil] objectAtIndex:0];
                contact.companySiteID = companySiteID.stringValue;
                DDXMLElement *cosDescription = [[element nodesForXPath:@"cosDescription" error:nil] objectAtIndex:0];
                contact.cosDescription = cosDescription.stringValue;
                DDXMLElement *cosSiteName = [[element nodesForXPath:@"cosSiteName" error:nil] objectAtIndex:0];
                contact.cosSiteName = cosSiteName.stringValue;
                NSLog(@"contact name: %@",contact.conFirstName);
            }
            
            
            
        }
        
    }
    
    
    // display the data in the cells.
    lblTitle.text = eventDetails.eveTitle;
    lblType.text = [eventDetails.eventType stringByAppendingFormat:@" - %@", eventDetails.eventType2];
    
    if (contact.contactID)
    {
        // create a full name string from the available components
        NSString *fullName = [[NSString alloc] initWithString:@""];
        if ([contact.conTitle length])
            fullName = [fullName stringByAppendingFormat:@"%@ ",contact.conTitle];
        if ([contact.conFirstName length])
            fullName = [fullName stringByAppendingFormat:@"%@ ",contact.conFirstName];
        if ([contact.conMiddleName length])
            fullName = [fullName stringByAppendingFormat:@"%@ ",contact.conMiddleName];
        if ([contact.conSurname length])
            fullName = [fullName stringByAppendingString:contact.conSurname];
        lblCustomer.text = fullName;
    }
    else
        lblCustomer.text = @"No contact";
    
    
    //Format the dates and times
    NSDateFormatter *dfToString = [[NSDateFormatter alloc] init];
    [dfToString setDateStyle:NSDateFormatterMediumStyle];
    NSDateFormatter *dfToDate = [[NSDateFormatter alloc] init];
    [dfToDate setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    int hours;
    int minutes;
    
    //if string is present and is not set to '0' and is not the first of jan 9999 (our default for no date set)
    if ([[dfToString stringFromDate:eventDetails.eveDueDate] length] > 1 && ![[dfToString stringFromDate:eventDetails.eveDueDate] isEqualToString:@"Jan 1, 9999"])
    {
        hours = [eventDetails.eveDueTime integerValue] / 3600;
        minutes = ([eventDetails.eveDueTime integerValue] / 60) % 60;
        lblDueDateTime.text = [[dfToString stringFromDate:eventDetails.eveDueDate] stringByAppendingFormat:@" - %@",[NSString stringWithFormat:@"%02d:%02d",hours,minutes]];
    }
    else
        lblDueDateTime.text = @"No Due Date";
    
    // if the end date is present and is not set to '0'
    if ([eventDetails.eveEndDate length] > 1 ){
        // format string to include both date and time. For the date convert it to a date and then convert it back to get the required formatting
        hours = [eventDetails.eveEndTime integerValue] / 3600;
        minutes = ([eventDetails.eveEndTime integerValue] / 60) % 60;
        lblEndDateTime.text = [[dfToString stringFromDate:[dfToDate dateFromString:eventDetails.eveEndDate]] stringByAppendingFormat:@" - %@",[NSString stringWithFormat:@"%02d:%02d",hours,minutes]];
    }
    else
        lblEndDateTime.text = @"No End Date";
    
    if ([eventDetails.eveCreatedTime length] > 0)
    {
        // format string to include both date and time. For the date convert it to a date and then convert it back to get the required formatting
        hours = [eventDetails.eveCreatedTime integerValue] / 3600;
        minutes = ([eventDetails.eveCreatedTime integerValue] / 60) % 60;
        cellLblCreateByDateTime.textLabel.text = [[dfToString stringFromDate:[dfToDate dateFromString:eventDetails.eveCreatedDate]] stringByAppendingFormat:@" - %@",[NSString stringWithFormat:@"%02d:%02d",hours,minutes]];
    }
    
    cellLblCreateByName.textLabel.text = eventDetails.eveCreatedBy;
 

    cellLblSite.detailTextLabel.text = [company.cosSiteName stringByAppendingFormat:@" - %@",company.cosDescription];
    cellLblContact.detailTextLabel.text = lblCustomer.text;
    
    txtComments.text = eventDetails.eveComments;
    

    
    //get contact data from the server server asynchronously
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{  
            NSURL *url;
            NSString *xmlString;
            NSData *xmlData;      
            NSError *error;
            // retrieve our contact from the server:
            ourContact = [[contactSearch alloc] init];
            //get contact from server
            url = [[NSURL alloc] initWithString:[appURL stringByAppendingFormat:@"/service1.asmx/searchContactsByContactID?searchContactID=%@",eventDetails.ourContactID]];
        NSLog(@"our contact ID: %@", eventDetails.ourContactID);
            //turn on the network activity indicator while the data is being retrieved from the server
            UIApplication *app = [UIApplication sharedApplication];  
            [app setNetworkActivityIndicatorVisible:YES]; 
        
            UIActivityIndicatorView *refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            refreshSpinner.frame = CGRectMake(cellLblOurContact.frame.size.width / 2 - 10, cellLblOurContact.frame.size.height / 2 - 10, 20, 20);
            refreshSpinner.hidesWhenStopped = YES;
            [cellLblOurContact addSubview:refreshSpinner];
            [refreshSpinner startAnimating];
        
            xmlString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        
            [app setNetworkActivityIndicatorVisible:NO]; 
            [refreshSpinner stopAnimating];
        
            //remove xmlns from the xml file 
            xmlString = [xmlString stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
            NSLog(@" xml string: %@ end of xml string",xmlString);
            NSLog(@"contact id: %@",eventDetails.contactID);
            xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
            DDXMLDocument *ourContactsDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:&error];
        
            NSArray* nodes = nil;
            nodes = [[ourContactsDocument rootElement] children];
            NSLog(@"contact name: %d",[nodes count]);
            for (DDXMLElement *element in nodes)
            { 
                DDXMLElement *contactID = [[element nodesForXPath:@"contactID" error:nil] objectAtIndex:0];
                ourContact.contactID = contactID.stringValue;
                DDXMLElement *conTitle = [[element nodesForXPath:@"conTitle" error:nil] objectAtIndex:0];
                ourContact.conTitle = conTitle.stringValue;
                DDXMLElement *conFirstName = [[element nodesForXPath:@"conFirstName" error:nil] objectAtIndex:0];
                ourContact.conFirstName = conFirstName.stringValue;
                DDXMLElement *conMiddleName = [[element nodesForXPath:@"conMiddleName" error:nil] objectAtIndex:0];
                ourContact.conMiddleName = conMiddleName.stringValue;
                DDXMLElement *conSurname = [[element nodesForXPath:@"conSurname" error:nil] objectAtIndex:0];
                ourContact.conSurname = conSurname.stringValue;
                
                DDXMLElement *companySiteID = [[element nodesForXPath:@"companySiteID" error:nil] objectAtIndex:0];
                ourContact.companySiteID = companySiteID.stringValue;
                DDXMLElement *cosDescription = [[element nodesForXPath:@"cosDescription" error:nil] objectAtIndex:0];
                ourContact.cosDescription = cosDescription.stringValue;
                DDXMLElement *cosSiteName = [[element nodesForXPath:@"cosSiteName" error:nil] objectAtIndex:0];
                ourContact.cosSiteName = cosSiteName.stringValue;
                NSLog(@"our contact name: %@",ourContact.conFirstName);
            }
        dispatch_sync(dispatch_get_main_queue(), ^{
            // if the data was not retrieved display an error
            if (error)
            {
                [[[UIAlertView alloc] initWithTitle:@"Data Fetch" message:@"Could not retrieve our contact details data from server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
            
            //put the data into the cell.
            NSString *ourContactFullName = [[NSString alloc] initWithString:@""];
            if ([ourContact.conTitle length])
                ourContactFullName = [ourContactFullName stringByAppendingFormat:@"%@ ",ourContact.conTitle];
            if ([ourContact.conFirstName length])
                ourContactFullName = [ourContactFullName stringByAppendingFormat:@"%@ ",ourContact.conFirstName];
            if ([ourContact.conMiddleName length])
                ourContactFullName = [ourContactFullName stringByAppendingFormat:@"%@ ",ourContact.conMiddleName];
            if ([ourContact.conSurname length])
                ourContactFullName = [ourContactFullName stringByAppendingString:ourContact.conSurname];
            cellLblOurContact.textLabel.text = ourContactFullName;
            
            //needed?
            //[self.tableView reloadData];
        });
    });


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setLblCustomer:nil];
    [self setLblDueDateTime:nil];
    [self setLblEndDateTime:nil];
    [self setCellLblSite:nil];
    [self setCellLblContact:nil];
    [self setTxtComments:nil];
    [self setCellLblCreateByName:nil];
    [self setCellLblCreateByDateTime:nil];
    [self setCellLblOurContact:nil];
    [self setCellComments:nil];
    [self setCellCommentLink:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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






#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([attachmentArray count] > 0)
        return 5;
    else
        return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 2;
            break;
        case 4:
            NSLog(@"count of attachments: %d", [attachmentArray count]);
            return [attachmentArray count];
            break;
        default:
            return 1;
            break;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    switch (indexPath.section)
    {
        case 0:
        {
            if (indexPath.row == 0)
                return cellLblSite;
            else
                return cellLblContact;
            break;
        }
        case 1:
        {
            if (indexPath.row == 0)
                return cellComments;
            else
                return cellCommentLink;
            break;
        }
        case 2: // events cell
        {
            return cellLblOurContact;
            break;
        }
        case 3: // events cell
        {
            if (indexPath.row == 0)
                return cellLblCreateByName;
            else
                return cellLblCreateByDateTime;
            break;
        }
        case 4: // events cell
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            if ([attachmentArray count] >= indexPath.row) // ensure that the attachment exists
            {
                Attachment *attachment = [attachmentArray objectAtIndex:indexPath.row];
                if([attachment.atyMnemonic isEqualToString:@"xls"])
                    cell.imageView.image = [UIImage imageNamed:@"Excel2007.PNG"];
                if([attachment.atyMnemonic isEqualToString:@"doc"])
                    cell.imageView.image = [UIImage imageNamed:@"233px-Microsoft_Word_Icon.svg.png"];
                cell.textLabel.text = attachment.attDescription;
                return cell;
            }
            else
                return nil;
            break;
        }
        default:
            return cellLblSite;
            break;
    }
    
    
    //NSLog(@"%@", indexPath.section);
    
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
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        if (company.companySiteID)
        [self performSegueWithIdentifier:@"toCompanyDetails" sender:self];
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"No Company" message:@"Can't display company details" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
    }
    
    
    if (indexPath.section == 0 && indexPath.row == 1)
    {
        if (contact.contactID)
            [self performSegueWithIdentifier:@"toContactDetails" sender:self];
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"No Contact" message:@"Can't display contact details" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
    }
    
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
    if ([segue.identifier isEqualToString:@"toComments"])
    {
        textViewController *textViewController = segue.destinationViewController;
        textViewController.text= eventDetails.eveComments;
    }
    else if([segue.identifier isEqualToString:@"toCompanyDetails"])
    {
            companyDetailsTableViewController *detailsViewController = segue.destinationViewController;
            detailsViewController.companyDetail = company;
    }
    else if([segue.identifier isEqualToString:@"toContactDetails"])
    {
        contactDetailsTableViewController *detailsViewController = segue.destinationViewController;
        detailsViewController.contactDetail = contact;
        detailsViewController.company = company;
        detailsViewController.isCoreData = isCoreData;
    }
    else if([segue.identifier isEqualToString:@"toOurContactDetails"])
    {
        contactDetailsTableViewController *detailsViewController = segue.destinationViewController;
        NSLog(@"first name: %@",ourContact.conFirstName);
        detailsViewController.contactDetail = ourContact;
        detailsViewController.isCoreData = NO;
    }
}
@end
