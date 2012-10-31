//
//  fetchXML.m
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 26/03/2012.
//  Copyright (c) 2012 Shuttleworth Business Systems Limited. All rights reserved.
//

#import "FetchXML.h"

@interface FetchXML()

@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) NSString *className;
@property (nonatomic, retain) NSMutableData *receivedDomData;
@property (nonatomic, retain) NSURLRequest *urlRequest;
@property (nonatomic, retain) NSURLConnection *connection;

- (void)connectionClosed;

@end

//count of the currently active network connections, to determine visibility of network activity indicator.
static NSInteger networkActivityCount = 0;

@implementation FetchXML

@synthesize receivedDomData = _receivedDomData;
@synthesize urlRequest = _urlRequest;
@synthesize connection = _connection;
@synthesize delegate = _delegate;
@synthesize className = _className;
@synthesize url = _url;

- (id)initWithUrl:(NSURL *)URL delegate:(id)delegate className:(NSString *)className
{
    if (self = [super init]) {
        NSLog(@"url: %@", URL);
        self.url = URL;
        self.delegate = delegate;
        self.className = className;
    }
    return self;
}

- (BOOL)fetchXMLWithURL:(NSString *)urlString
{    
    self.url = [NSURL URLWithString:urlString];
    NSLog(@"url: %@", self.url);
    return [self fetchXML];
}

- (BOOL)fetchXML
{
    networkActivityCount++;
    NSLog(@"networkActivityCount++ : %d",networkActivityCount);
    
    UIApplication *app = [UIApplication sharedApplication];  
    [app setNetworkActivityIndicatorVisible:YES]; 
    
    self.urlRequest = [NSURLRequest requestWithURL:self.url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    self.connection = [[NSURLConnection alloc] initWithRequest:self.urlRequest delegate:self startImmediately:YES];
    self.receivedDomData = [[NSMutableData alloc] init];
    if (self.connection) 
        return YES;
    else 
        return NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // reset recievedData's lendth to 0 to get ready to recieve.
    [self.receivedDomData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    [self.receivedDomData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    NSLog(@"error: %@", error.description);
    UIApplication *app = [UIApplication sharedApplication];  
    [app setNetworkActivityIndicatorVisible:NO]; 
    
    if ([self.delegate respondsToSelector:@selector(fetchXMLError::)]) {
        [self.delegate fetchXMLError:@"Error fetching data from the server":self];
    }
    
    [self setConnection:nil];
    [self setReceivedDomData:nil];
    [self connectionClosed];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;
    // initialise a document
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:self.receivedDomData options:0 error:&error];
    
    //NSLog(@"%@", doc);
    
    if ([self.delegate respondsToSelector:@selector(docRecieved::)] && !error) {
        //NSLog(@"classname: %@", className);
        NSMutableDictionary *docDic = [[NSMutableDictionary alloc] init];
        [docDic setValue:doc forKey:@"Document"];
        [docDic setValue:self.className forKey:@"ClassName"];
        //NSLog(@"classname from dic: %@", [docDic objectForKey:@"ClassName"]);
        [self.delegate docRecieved:docDic:self];
    }
    else if ([self.delegate respondsToSelector:@selector(fetchXMLError::)]) {
        NSLog(@"error: %@", error.description);
        [self.delegate fetchXMLError:@"Error fetching data from the server":self];
    }
    
    [self setConnection:nil];
    [self setReceivedDomData:nil];
    [self connectionClosed];
}

- (void)cancel
{
    if (self.connection) { // if there is currently a connection, cancel it.
        [self.connection cancel];
        [self setConnection:nil];
        [self setReceivedDomData:nil];
        [self connectionClosed];
    }
}

- (void)connectionClosed
{
    networkActivityCount--;
    NSLog(@"networkActivityCount-- : %d",networkActivityCount);
    
    //when no connections remain, hide setNetworkActivityIndicator.
    if (networkActivityCount == 0)
    {
        UIApplication *app = [UIApplication sharedApplication];  
        [app setNetworkActivityIndicatorVisible:NO]; 
    }
}

@end
