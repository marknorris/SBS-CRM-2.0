//
//  getDom.m
//  SBS CRM 2.0
//
//  Created by Tom Couchman on 26/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "getDom.h"
@interface getDom()
@property (nonatomic, retain) NSMutableData *receivedDomData;
@property (nonatomic, retain) NSURLRequest *urlRequest;
@property (nonatomic, retain) NSURLConnection *connection;

- (void)connectionClosed;
@end

//count of the currently active network connections, to determine visibility of network activity indicator.
static NSInteger networkActivityCount = 0;

@implementation getDom

@synthesize receivedDomData;
@synthesize urlRequest;
@synthesize connection;

@synthesize delegate;
@synthesize className;
@synthesize url;

- (id) initWithUrl:(NSURL *)URL delegate:(id)Delegate className:(NSString *)ClassName{
    if (self = [super init])
    {
        NSLog(@"url: %@", URL);
        url = URL;
        delegate = Delegate;
        className = ClassName;
    }
    return self;
}

- (BOOL)getDom:(NSString *)URLString{
    
    url = [NSURL URLWithString:URLString];
    return [self getDom];
}

-(BOOL)getDom{
    networkActivityCount++;
    NSLog(@"networkActivityCount++ : %d",networkActivityCount);
    
    UIApplication *app = [UIApplication sharedApplication];  
    [app setNetworkActivityIndicatorVisible:YES]; 
    
    urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
    receivedDomData = [[NSMutableData alloc] init];
    if(connection) return YES;
    else return NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // reset recievedData's lendth to 0 to get ready to recieve.
    [receivedDomData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    [receivedDomData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    
    NSLog(@"error: %@", error.description);
    UIApplication *app = [UIApplication sharedApplication];  
    [app setNetworkActivityIndicatorVisible:NO]; 
    
    if([delegate respondsToSelector:@selector(getDomError::)])
    {
        [delegate getDomError:@"Error fetching data from the server":self];
    }
    [self setConnection:nil];
    [self setReceivedDomData:nil];
    
    [self connectionClosed];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{

    
    NSError *error;
    // initialise a document
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:receivedDomData options:0 error:&error];
    
    //NSLog(@"%@", doc);
    
    if([delegate respondsToSelector:@selector(docRecieved::)] && !error)
    {
        //NSLog(@"classname: %@", className);
        NSMutableDictionary *docDic = [[NSMutableDictionary alloc] init];
        [docDic setValue:doc forKey:@"Document"];
        [docDic setValue:className forKey:@"ClassName"];
            //NSLog(@"classname from dic: %@", [docDic objectForKey:@"ClassName"]);
        [delegate docRecieved:docDic:self];
    }
    else if ([delegate respondsToSelector:@selector(getDomError::)]) 
    {
        NSLog(@"error: %@", error.description);
        [delegate getDomError:@"Error fetching data from the server":self];
    }
    
    [self setConnection:nil];
    [self setReceivedDomData:nil];
    
    [self connectionClosed];
}

- (void)cancel{

    if (connection) // if there is currently a connection, cancel it.
    {
        [connection cancel];

        [self setConnection:nil];
        [self setReceivedDomData:nil];
        
        [self connectionClosed];
    }
}

- (void)connectionClosed{
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
