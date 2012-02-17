//
//  syncData.m
//  SBS CRM
//
//  Created by Tom Couchman on 09/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "syncData.h"


@implementation syncData

@synthesize appDelegate;

- (BOOL)doSync{
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    UIApplication *app = [UIApplication sharedApplication];  
    [app setNetworkActivityIndicatorVisible:YES]; 
    
    BOOL retrieved = [self getDom];
    
    [app setNetworkActivityIndicatorVisible:NO];  
    
    if (!retrieved)
        return NO;
    
    BOOL dataSaved = [self reloadEvents];
    
    if (!dataSaved)
        return NO;
    
    dataSaved = [self reloadCompanies];
    
    if (!dataSaved)
        return NO;
    
    dataSaved = [self reloadContacts];
    
    if (!dataSaved)
        return NO;
    
    dataSaved = [self reloadCommunication];
    
    if (!dataSaved)
        return NO;
    
    dataSaved = [self reloadAttachments];
    
    if (!dataSaved)
        return NO;
    
    return YES;
}

- (BOOL)getDom{
    

    NSError* error = nil;

    
    url = [[NSURL alloc] initWithString:[appURL stringByAppendingFormat:@"/service1.asmx/syncEvents?userID=%d",appUserID]];
    
    xmlString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    //remove xmlns from the xml file 
    xmlString = [xmlString stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
    xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    eventsDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    if (error)
        return NO;

    url = [[NSURL alloc] initWithString:[appURL stringByAppendingFormat:@"/service1.asmx/syncCompanies?userID=%d",appUserID]];
    xmlString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    //remove xmlns from the xml file 
    xmlString = [xmlString stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
    xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    companiesDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    if (error)
        return NO;
    
    url = [[NSURL alloc] initWithString:[appURL stringByAppendingFormat:@"/service1.asmx/syncContacts?userID=%d",appUserID]];
    xmlString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    //remove xmlns from the xml file 
    xmlString = [xmlString stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
    xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    contactsDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    if (error)
        return NO;
    
    url = [[NSURL alloc] initWithString:[appURL stringByAppendingFormat:@"/service1.asmx/syncCommunication?userID=%d",appUserID]];
    xmlString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    //remove xmlns from the xml file 
    xmlString = [xmlString stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
    xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    communicationDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    if (error)
        return NO;

    url = [[NSURL alloc] initWithString:[appURL stringByAppendingFormat:@"/service1.asmx/syncAttachments?userID=%d",appUserID]];
    xmlString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    //remove xmlns from the xml file 
    xmlString = [xmlString stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
    xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    attachmentsDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:&error];
    if (error)
        return NO;
    
    return YES;
    /*
    NSLog(@"%@", [xmlDoc XMLStringWithOptions:DDXMLNodePrettyPrint]);
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    }
    else
    {
        DDXMLElement* element = nil;
        element = [xmlDoc rootElement];
        NSLog(@"userid: %@",element.stringValue);
        userID = element.stringValue;
    }*/
    
    
}

- (BOOL)reloadEvents{
    
    
    NSError *error;
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    // fetch saved events from coredata and delete them
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Events" inManagedObjectContext:context];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
   
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items){
        [context deleteObject:managedObject];
    }
    if (![context save:&error]){
        return NO;
    }
    
    
    // save newly retrieved events to coredata
    NSArray* nodes = nil;
    nodes = [[eventsDocument rootElement] children];
    
    for (DDXMLElement *element in nodes)
    { 
        Events *eventToSave = (Events *)[NSEntityDescription insertNewObjectForEntityForName:@"Events" inManagedObjectContext:context]; 
        DDXMLElement *eveNumber = [[element nodesForXPath:@"eveNumber" error:nil] objectAtIndex:0];
        eventToSave.eveNumber = eveNumber.stringValue;
        DDXMLElement *eveStatus = [[element nodesForXPath:@"eveStatus" error:nil] objectAtIndex:0];
        eventToSave.eveStatus = eveStatus.stringValue;
        DDXMLElement *eveTitle = [[element nodesForXPath:@"eveTitle" error:nil] objectAtIndex:0];
        eventToSave.eveTitle = eveTitle.stringValue;
        DDXMLElement *ourContactID = [[element nodesForXPath:@"ourContactID" error:nil] objectAtIndex:0];
        eventToSave.ourContactID = ourContactID.stringValue;
        DDXMLElement *eventType = [[element nodesForXPath:@"eventType" error:nil] objectAtIndex:0];
        eventToSave.eventType = eventType.stringValue;
        DDXMLElement *eventType2 = [[element nodesForXPath:@"eventType2" error:nil] objectAtIndex:0];
        eventToSave.eventType2 = eventType2.stringValue;
        DDXMLElement *eventPriority = [[element nodesForXPath:@"eventPriority" error:nil] objectAtIndex:0];
        eventToSave.eventPriority = eventPriority.stringValue;
        DDXMLElement *companySiteID = [[element nodesForXPath:@"companySiteID" error:nil] objectAtIndex:0];
        eventToSave.companySiteID = companySiteID.stringValue;
        DDXMLElement *eventID = [[element nodesForXPath:@"eventID" error:nil] objectAtIndex:0];
        eventToSave.eventID = eventID.stringValue;
        DDXMLElement *contactID = [[element nodesForXPath:@"contactID" error:nil] objectAtIndex:0];
        eventToSave.contactID = contactID.stringValue;
        DDXMLElement *eveComments = [[element nodesForXPath:@"eveComments" error:nil] objectAtIndex:0];
        eventToSave.eveComments = eveComments.stringValue;
        DDXMLElement *eveCreatedDate = [[element nodesForXPath:@"eveCreatedDate" error:nil] objectAtIndex:0];
        eventToSave.eveCreatedDate = eveCreatedDate.stringValue;
        DDXMLElement *eveCreatedTime = [[element nodesForXPath:@"eveCreatedTime" error:nil] objectAtIndex:0];
        eventToSave.eveCreatedTime = eveCreatedTime.stringValue;        
        DDXMLElement *eveDueDate = [[element nodesForXPath:@"eveDueDate" error:nil] objectAtIndex:0];
        eventToSave.eveDueDate = [self formatDate:eveDueDate.stringValue];
        DDXMLElement *eveDueTime = [[element nodesForXPath:@"eveDueTime" error:nil] objectAtIndex:0];
        eventToSave.eveDueTime = eveDueTime.stringValue;
        DDXMLElement *eveEndDate = [[element nodesForXPath:@"eveEndDate" error:nil] objectAtIndex:0];
        eventToSave.eveEndDate = eveEndDate.stringValue;
        DDXMLElement *eveEndTime = [[element nodesForXPath:@"eveEndTime" error:nil] objectAtIndex:0];
        eventToSave.eveEndTime = eveEndTime.stringValue;
        DDXMLElement *eveCreatedBy = [[element nodesForXPath:@"eveCreatedBy" error:nil] objectAtIndex:0];
        eventToSave.eveCreatedBy = eveCreatedBy.stringValue;
    }

    if(![context save:&error]){
        return NO;
    }
    return YES;
}

- (BOOL)reloadCompanies{
    
    NSError *error;
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    // fetch saved events from coredata and delete them
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Company" inManagedObjectContext:context];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items){
        [context deleteObject:managedObject];
    }
    if (![context save:&error]){
        return NO;
    }
    
    
    // save newly retrieved events to coredata
    NSArray* nodes = nil;
    nodes = [[companiesDocument rootElement] children];
    
    for (DDXMLElement *element in nodes)
    { 
        Company *companyToSave = (Company *)[NSEntityDescription insertNewObjectForEntityForName:@"Company" inManagedObjectContext:context]; 
        DDXMLElement *companySiteID = [[element nodesForXPath:@"companySiteID" error:nil] objectAtIndex:0];
        companyToSave.companySiteID = companySiteID.stringValue;
        DDXMLElement *coaCompanyName = [[element nodesForXPath:@"coaCompanyName" error:nil] objectAtIndex:0];
        companyToSave.coaCompanyName = coaCompanyName.stringValue;
        DDXMLElement *cosSiteName = [[element nodesForXPath:@"cosSiteName" error:nil] objectAtIndex:0];
        companyToSave.cosSiteName = cosSiteName.stringValue;     
        DDXMLElement *cosDescription = [[element nodesForXPath:@"cosDescription" error:nil] objectAtIndex:0];
        companyToSave.cosDescription = cosDescription.stringValue;  
        DDXMLElement *addStreetAddress = [[element nodesForXPath:@"addStreetAddress" error:nil] objectAtIndex:0];
        companyToSave.addStreetAddress = addStreetAddress.stringValue; 
        DDXMLElement *addStreetAddress2 = [[element nodesForXPath:@"addStreetAddress2" error:nil] objectAtIndex:0];
        companyToSave.addStreetAddress2 = addStreetAddress2.stringValue; 
        DDXMLElement *addStreetAddress3 = [[element nodesForXPath:@"addStreetAddress3" error:nil] objectAtIndex:0];
        companyToSave.addStreetAddress3 = addStreetAddress3.stringValue; 
        DDXMLElement *addTown = [[element nodesForXPath:@"addTown" error:nil] objectAtIndex:0];
        companyToSave.addTown = addTown.stringValue;  
        DDXMLElement *addCounty = [[element nodesForXPath:@"addCounty" error:nil] objectAtIndex:0];
        companyToSave.addCounty = addCounty.stringValue; 
        DDXMLElement *addPostCode = [[element nodesForXPath:@"addPostCode" error:nil] objectAtIndex:0];
        companyToSave.addPostCode = addPostCode.stringValue; 
        DDXMLElement *couCountryName = [[element nodesForXPath:@"couCountryName" error:nil] objectAtIndex:0];
        companyToSave.couCountryName = couCountryName.stringValue; 
    }
    
    if(![context save:&error]){
        return NO;
    }
    return YES;
}

- (BOOL)reloadContacts{
    
    NSError *error;
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    // fetch saved events from coredata and delete them
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:context];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items){
        [context deleteObject:managedObject];
    }
    if (![context save:&error]){
        return NO;
    }
    
    
    // save newly retrieved events to coredata
    NSArray* nodes = nil;
    nodes = [[contactsDocument rootElement] children];
    
    for (DDXMLElement *element in nodes)
    { 
        Contact *contactToSave = (Contact *)[NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context]; 
        DDXMLElement *contactID = [[element nodesForXPath:@"contactID" error:nil] objectAtIndex:0];
        contactToSave.contactID = contactID.stringValue;
        DDXMLElement *conTitle = [[element nodesForXPath:@"conTitle" error:nil] objectAtIndex:0];
        contactToSave.conTitle = conTitle.stringValue;
        DDXMLElement *conFirstName = [[element nodesForXPath:@"conFirstName" error:nil] objectAtIndex:0];
        contactToSave.conFirstName = conFirstName.stringValue;
        DDXMLElement *conMiddleName = [[element nodesForXPath:@"conMiddleName" error:nil] objectAtIndex:0];
        contactToSave.conMiddleName = conMiddleName.stringValue;
        DDXMLElement *conSurname = [[element nodesForXPath:@"conSurname" error:nil] objectAtIndex:0];
        contactToSave.conSurname = conSurname.stringValue;
        
        DDXMLElement *companySiteID = [[element nodesForXPath:@"companySiteID" error:nil] objectAtIndex:0];
        contactToSave.companySiteID = companySiteID.stringValue;
        DDXMLElement *cosDescription = [[element nodesForXPath:@"cosDescription" error:nil] objectAtIndex:0];
        contactToSave.cosDescription = cosDescription.stringValue;
        DDXMLElement *cosSiteName = [[element nodesForXPath:@"cosSiteName" error:nil] objectAtIndex:0];
        contactToSave.cosSiteName = cosSiteName.stringValue;
    }
    
    if(![context save:&error]){
        return NO;
    }
    return YES;
}

- (BOOL)reloadCommunication{
    
    NSError *error;
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    // fetch saved events from coredata and delete them
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Communication" inManagedObjectContext:context];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items){
        [context deleteObject:managedObject];
    }
    if (![context save:&error]){
        return NO;
    }
    
    
    // save newly retrieved events to coredata
    NSArray* nodes = nil;
    nodes = [[communicationDocument rootElement] children];
    
    for (DDXMLElement *element in nodes)
    { 
        Communication *communicationToSave = (Communication *)[NSEntityDescription insertNewObjectForEntityForName:@"Communication" inManagedObjectContext:context]; 
        DDXMLElement *contactID = [[element nodesForXPath:@"contactID" error:nil] objectAtIndex:0];
        communicationToSave.contactID = contactID.stringValue;
        DDXMLElement *communicationNumberID = [[element nodesForXPath:@"communicationNumberID" error:nil] objectAtIndex:0];
        communicationToSave.communicationNumberID = communicationNumberID.stringValue;
        DDXMLElement *cmnEmail = [[element nodesForXPath:@"cmnEmail" error:nil] objectAtIndex:0];
        communicationToSave.cmnEmail = cmnEmail.stringValue;
        DDXMLElement *cmnInternationalCode = [[element nodesForXPath:@"cmnInternationalCode" error:nil] objectAtIndex:0];
        communicationToSave.cmnInternationalCode = cmnInternationalCode.stringValue;
        DDXMLElement *cmnAreaCode = [[element nodesForXPath:@"cmnAreaCode" error:nil] objectAtIndex:0];
        communicationToSave.cmnAreaCode = cmnAreaCode.stringValue;
        DDXMLElement *cmnNumber = [[element nodesForXPath:@"cmnNumber" error:nil] objectAtIndex:0];
        communicationToSave.cmnNumber = cmnNumber.stringValue;
        DDXMLElement *cotDescription = [[element nodesForXPath:@"cotDescription" error:nil] objectAtIndex:0];
        communicationToSave.cotDescription = cotDescription.stringValue;
    }
    
    if(![context save:&error]){
        return NO;
    }
    return YES;
}

- (BOOL)reloadAttachments{
    
    NSError *error;
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    // fetch saved events from coredata and delete them
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Attachment" inManagedObjectContext:context];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items){
        [context deleteObject:managedObject];
    }
    if (![context save:&error]){
        return NO;
    }
    
    
    // save newly retrieved events to coredata
    NSArray* nodes = nil;
    nodes = [[attachmentsDocument rootElement] children];
    
    for (DDXMLElement *element in nodes)
    { 
        Attachment *attachmentToSave = (Attachment *)[NSEntityDescription insertNewObjectForEntityForName:@"Attachment" inManagedObjectContext:context]; 
        DDXMLElement *eventID = [[element nodesForXPath:@"eventID" error:nil] objectAtIndex:0];
        attachmentToSave.eventID = eventID.stringValue;
        DDXMLElement *attachmentID = [[element nodesForXPath:@"attachmentID" error:nil] objectAtIndex:0];
        attachmentToSave.attachmentID = attachmentID.stringValue;
        DDXMLElement *attDescription = [[element nodesForXPath:@"attDescription" error:nil] objectAtIndex:0];
        attachmentToSave.attDescription = attDescription.stringValue;
        DDXMLElement *atyMnemonic = [[element nodesForXPath:@"atyMnemonic" error:nil] objectAtIndex:0];
        attachmentToSave.atyMnemonic = atyMnemonic.stringValue;

    }
    
    if(![context save:&error]){
        return NO;
    }
    return YES;
}

- (NSDate *)formatDate:(NSString *)date{
    if ([date isEqualToString:@""])
        date = @"01/01/9999 00:00:00";
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSDate *returnDate = [df dateFromString:date];

    return returnDate;
}

@end
