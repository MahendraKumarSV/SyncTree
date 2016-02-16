
//  CoreDataModel.m

#import "CoreDataModel.h"

#define SQLITENAME @"ParlorMeAppDB.sqlite"

@interface CoreDataModel ()
{
    NSFetchRequest *fetchRequest;
}

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation CoreDataModel
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
static CoreDataModel* sharedModel = nil;

#pragma mark Singleton Intialization
//Singleton initialization of the Core Data model
+(CoreDataModel *)sharedCoreDataModel{
    @synchronized (sharedModel){
        if(sharedModel == nil)
            sharedModel = [[CoreDataModel alloc] init];
    }
    return sharedModel;
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

-(BOOL)isManagedObjectContextNil{
    if(_managedObjectContext)
        return FALSE;
    else
        return TRUE;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ParlorMeDataBaseModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:SQLITENAME];
    //NSLog(@"======%@",storeURL);
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES],   NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES],  NSInferMappingModelAutomaticallyOption, nil];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        //NSLog(@"Persistent fail");
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        // DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }
    return _persistentStoreCoordinator;
}

- (void)saveContext
{
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext =  [self managedObjectContext];
    if (managedObjectContext != nil && _persistentStoreCoordinator != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            // DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
    }
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma  mark Custom Methods
-(NSEntityDescription*)newEntityWithName: (NSString *)entityName forContext : (NSManagedObjectContext *)context{
    if(!context)
        context =  [self managedObjectContext]; //self.managedObjectContext;
    NSEntityDescription *entity = (NSEntityDescription*)[NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    //NSLog(@"+++++++++++++++++++++++++ adding entity %@",entity);
    return entity;
}

- (NSArray *)arrayOfRecordsForEntity :(NSString *)entityName andPredicate: (NSPredicate *)predicate andSortDescriptor :
(NSSortDescriptor *)sort forContext: (NSManagedObjectContext *)context{
    if(!context)
        context =   [self managedObjectContext];
    NSError *error = nil;
    
    //removig dead store error
    if(!fetchRequest)
        fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:context]];
    if(predicate)
        [fetchRequest setPredicate:predicate];
    if(sort)
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    //removing dead store error
    NSArray *records = [context executeFetchRequest:fetchRequest error:&error];
    fetchRequest = nil;
    //if(error)
    //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    return  records;
    
}

-(NSManagedObjectContext *)getNewManagedObjectContext{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    [context setUndoManager:nil];
    return  context;
    //Every thread should have its own context and they should merge on main thread
}

-(void)deleteEntityObject: (NSManagedObject*)object withContext:(NSManagedObjectContext *)context{
    if(!context)
        context =   [self managedObjectContext];
    //NSLog(@"------------------------ deleting object with id: %@",object.objectID);
    [context deleteObject:object];
}

@end
