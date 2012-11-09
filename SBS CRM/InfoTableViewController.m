//
//  InfoTableViewController.m
//  SBS CRM 2.0
//
//  Created by Mark Norris on 04/11/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "InfoTableViewController.h"

@interface InfoTableViewController ()

@property (strong, nonatomic) NSArray *versions;

@end

@implementation InfoTableViewController

@synthesize versions = _versions;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [Version configureEntity];
    [Version loadObjectsWithDelegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.versions.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Versions";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Version";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    Version *version = [self.versions objectAtIndex:indexPath.row];
    cell.textLabel.text = version.name;
    cell.detailTextLabel.text = version.version;
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (IBAction)done:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - RKObjectLoaderDelegate

//@required

/**
 * Sent when an object loaded failed to load the collection due to an error
 */
- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"objectLoader: %@ error: %@", objectLoader, error);
}

//@optional

/**
 When implemented, sent to the delegate when the object laoder has completed successfully
 and loaded a collection of objects. All objects mapped from the remote payload will be returned
 as a single array.
 */
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"objectLoader: %@ objects: %@ object count: %d", objectLoader, objects, objects.count);
    NSLog(@"%@", [objectLoader response]);
    self.versions = objects;
    [self.tableView reloadData];
}

/**
 When implemented, sent to the delegate when the object loader has completed succesfully.
 If the load resulted in a collection of objects being mapped, only the first object
 in the collection will be sent with this delegate method. This method simplifies things
 when you know you are working with a single object reference.
 */
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object
{
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"objectLoader: %@ object: %@", objectLoader, object);
}

/**
 When implemented, sent to the delegate when an object loader has completed successfully. The
 dictionary will be expressed as pairs of keyPaths and objects mapped from the payload. This
 method is useful when you have multiple root objects and want to differentiate them by keyPath.
 */
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjectDictionary:(NSDictionary *)dictionary
{
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"objectLoader: %@ dictionary: %@", objectLoader, dictionary);
}

/**
 Invoked when the object loader has finished loading
 */
- (void)objectLoaderDidFinishLoading:(RKObjectLoader *)objectLoader
{
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"objectLoader: %@", objectLoader);
}

/**
 Informs the delegate that the object loader has serialized the source object into a serializable representation
 for sending to the remote system. The serialization can be modified to allow customization of the request payload independent of mapping.
 
 @param objectLoader The object loader performing the serialization.
 @param sourceObject The object that was serialized.
 @param serialization The serialization of sourceObject to be sent to the remote backend for processing.
 */
- (void)objectLoader:(RKObjectLoader *)objectLoader didSerializeSourceObject:(id)sourceObject toSerialization:(inout id<RKRequestSerializable> *)serialization
{
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"objectLoader: %@ sourceObject: %@ serialization: %@", objectLoader, sourceObject, serialization);
}

/**
 Sent when an object loader encounters a response status code or MIME Type that RestKit does not know how to handle.
 
 Response codes in the 2xx, 4xx, and 5xx range are all handled as you would expect. 2xx (successful) response codes
 are considered a successful content load and object mapping will be attempted. 4xx and 5xx are interpretted as
 errors and RestKit will attempt to object map an error out of the payload (provided the MIME Type is mappable)
 and will invoke objectLoader:didFailWithError: after constructing an NSError. Any other status code is considered
 unexpected and will cause objectLoaderDidLoadUnexpectedResponse: to be invoked provided that you have provided
 an implementation in your delegate class.
 
 RestKit will also invoke objectLoaderDidLoadUnexpectedResponse: in the event that content is loaded, but there
 is not a parser registered to handle the MIME Type of the payload. This often happens when the remote backend
 system RestKit is talking to generates an HTML error page on failure. If your remote system returns content
 in a MIME Type other than application/json or application/xml, you must register the MIME Type and an appropriate
 parser with the [RKParserRegistry sharedParser] instance.
 
 Also note that in the event RestKit encounters an unexpected status code or MIME Type response an error will be
 constructed and sent to the delegate via objectLoader:didFailsWithError: unless your delegate provides an
 implementation of objectLoaderDidLoadUnexpectedResponse:. It is recommended that you provide an implementation
 and attempt to handle common unexpected MIME types (particularly text/html and text/plain).
 
 @optional
 */
- (void)objectLoaderDidLoadUnexpectedResponse:(RKObjectLoader *)objectLoader
{
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"objectLoader: %@", objectLoader);
    NSString *errorMessage = [NSString stringWithFormat:@"An error occurred while loading data from the server\r\r%@", objectLoader.URLRequest.URL];
    
    if (!objectLoader.response.isOK) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    
}

/**
 Invoked just after parsing has completed, but before object mapping begins. This can be helpful
 to extract data from the parsed payload that is not object mapped, but is interesting for one
 reason or another. The mappableData will be made mutable via mutableCopy before the delegate
 method is invoked.
 
 Note that the mappable data is a pointer to a pointer to allow you to replace the mappable data
 with a new object to be mapped. You must dereference it to access the value.
 */
- (void)objectLoader:(RKObjectLoader *)loader willMapData:(inout id *)mappableData
{
    NSLog(@"%s", __FUNCTION__);
}

/**
 Sent when a request has finished loading
 
 @param request The RKRequest object that was handling the loading.
 @param response The RKResponse object containing the result of the request.
 */
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response
{
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"%@", [request URL]);
    NSLog(@"response: %@", response);
    NSLog(@"Response code: %d", [response statusCode]);
    NSLog(@"Response MIME type: %@", [response MIMEType]);
    NSLog(@"Response body: %@", [response bodyAsString]);
}

@end
