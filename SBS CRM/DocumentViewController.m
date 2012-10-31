//
//  documentViewController.m
//  SBS CRM
//
//  Created by Tom Couchman on 29/02/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "DocumentViewController.h"
#import "DDXML.h"
#import "AppDelegate.h"
#import "LoadingSavingView.h"

@interface DocumentViewController() {
    float fileSize;
    int currentFileSize;
    BOOL retry;
    LoadingSavingView *loadingView;
    NSURLConnection *con;
}

- (void)loadDocument:(NSString*)documentName inView:(UIWebView*)webView;

@end

@implementation DocumentViewController

@synthesize progressBar = _progressBar;
@synthesize webView = _webView;
@synthesize eventID = _eventID;
@synthesize attOriginalFilename = _attOriginalFilename;
@synthesize attachmentID = _attachmentID;
@synthesize atyMnemonic = _atyMnemonic;
@synthesize toolbar = _toolbar;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //[webData setLength:0]; 
    fileSize = response.expectedContentLength;
    
    //NSInteger httpStatusCode = (NSHTTPURLResponse *)response.statusCode;
    
    //get the http response, if it is a 404 display an error and clear the webview
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    int status = [httpResponse statusCode];
    NSLog(@"status code: %d", status);
    
    if (status >= 400 && status < 600) { //if 404, either look for the file in the old directory, or if this has been done, display an error
        
        if (!retry) {
            retry = YES;
            NSLog(@"attachment: %@",[NSString stringWithFormat:@"%@/CRM/%@%@.%@", appURL, @"mis", self.attachmentID, [self.attOriginalFilename pathExtension]]);
            [self loadDocument:[NSString stringWithFormat:@"%@/CRM/%@%@.%@", appURL, @"mis", self.attachmentID, [self.attOriginalFilename pathExtension]] inView:self.webView];
            //NSLog(@"File: %@", [attOriginalFilename pathExtension]);
        }
        else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Problem downloading the file" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            [self hideProgressIndicators];
            //display a blank html page.
            [self.webView loadHTMLString:@"<html><head></head><body></body></html>" baseURL:nil];
        }
        
    }
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //[webData appendData:data];
    currentFileSize += data.length;
    self.progressBar.progress = currentFileSize / fileSize;
    //NSLog(@"progress: %f", currentFileSize / fileSize);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    if (!retry) {
        retry = YES;
        NSLog(@"attachment: %@",[NSString stringWithFormat:@"%@/CRM/%@%@.%@", appURL, @"mis", self.attachmentID, [self.attOriginalFilename pathExtension]]);
        [self loadDocument:[NSString stringWithFormat:@"%@/CRM/%@%@.%@", appURL, @"mis", self.attachmentID, [self.attOriginalFilename pathExtension]] inView:self.webView];
        //NSLog(@"File: %@", [attOriginalFilename pathExtension]);
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Problem downloading the file" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        [self hideProgressIndicators];
        //display a blank html page.
        [self.webView loadHTMLString:@"<html><head></head><body></body></html>" baseURL:nil];
    }
    
}

-(void)hideProgressIndicators
{
    [loadingView removeFromSuperview];
    
    [UIView beginAnimations:@"hideProgressIndicators" context:nil];
    [UIView setAnimationDuration:0.7];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.toolbar cache:YES];
    self.toolbar.frame = CGRectMake(self.toolbar.frame.origin.x, self.toolbar.frame.origin.y + self.toolbar.frame.size.height, self.toolbar.frame.size.width, self.toolbar.frame.size.height);
    [UIView commitAnimations];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //show the full progress bar
    //progressBar.progress = 1;
    //pause for 0.5 seconds so that the progress bar does not flash on the screen
    [self performSelector:NSSelectorFromString(@"hideProgressIndicators") withObject:nil afterDelay:0.5];
}

-(void)loadDocument:(NSString*)documentName inView:(UIWebView*)webView
{
    //remove cached content
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    //ensure the progress bar has been set back to zero
    self.progressBar.progress = 0;
    
    //create a url out of the document name string
    NSURL *url = [NSURL URLWithString:[documentName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //NSLog(@"url: %@",url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    con = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (con) // if the connection was successful, get the file and display it in the webview
        [self.webView loadRequest:request];
    else
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Problem downloading the file" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    
    /*
     NSError *error;
     //TODO this needs to be the actual server ID eventually
     NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/Service1.asmx/getAttachment?eventID=%@&attOriginalFilename=%@",appURL,eventID,attOriginalFilename]];
     NSLog(@"url: %@", url);
     NSString *xmlString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
     //remove xmlns from the xml file 
     xmlString = [xmlString stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
     NSData *xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
     DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:&error];
     if (error)
     NSLog(@"%@", error);
     
     NSArray* nodes = nil;
     nodes = [[doc rootElement] children];
     NSString *dataString;
     
     for (DDXMLElement *element in nodes)
     {
     dataString = element.stringValue;
     }
     
     
     
     // convert from Base64
     NSData *data = [Base64 decode:dataString];
     
     //test path:
     //attOriginalFilename = @"hi\\there\\does\\this\\work\\Doc1.docx";
     
     
     //get the basepath
     NSArray *basepath =
     NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     //create the path for the document from that, using the file name from att description.
     //must first change back slashes to forward then use 'last path component' to remove the original path
     NSString *path = [[basepath objectAtIndex:0] stringByAppendingPathComponent:attOriginalFilename];
     
     NSLog(@"path: %@", path);
     
     //save the file
     [data writeToFile:path atomically:YES];
     
     //if the file exists, load it into the webview
     if ([[NSFileManager defaultManager] fileExistsAtPath:path])
     {
     NSURL *targetURL = [NSURL fileURLWithPath:path];
     NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
     [self.webView loadRequest:request];
     }
     else
     {
     [[[UIAlertView alloc] initWithTitle:@"File cannot be displayed" message:@"There was a problem saving the file" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
     }*/
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
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

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    loadingView  = [[LoadingSavingView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 80, self.view.frame.size.height / 2 - 60, 250, 30) withMessage:@"Loading..."];
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.webView addSubview:loadingView];
    
    //set retry to false to indicate that this is the first attempt to retrieve the file
    retry = NO;
    NSLog(@"attachment: %@",[NSString stringWithFormat:@"%@/CRM/EVE/%@/%@", appURL, self.eventID, self.attOriginalFilename]);
    [self loadDocument:[NSString stringWithFormat:@"%@/CRM/EVE/%@/%@", appURL, self.eventID, self.attOriginalFilename] inView:self.webView];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setProgressBar:nil];
    [self setToolbar:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (IBAction)clickDone:(id)sender {
    [con cancel]; // on leaving the view cancel the NSURLConnection.
    [self dismissModalViewControllerAnimated:YES];
}

@end
