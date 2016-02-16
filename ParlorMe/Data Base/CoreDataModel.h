//
//  CoreDataModel.h

#import <Foundation/Foundation.h>
#import "User.h"
#import "Services.h"
#import "MainCategories.h"
#import "Address.h"

@interface CoreDataModel : NSObject

+(CoreDataModel *)sharedCoreDataModel;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (BOOL)isManagedObjectContextNil;

#pragma mark Custom Methods
- (NSArray *)arrayOfRecordsForEntity :(NSString *)entityName andPredicate: (NSPredicate *)predicate andSortDescriptor :(NSSortDescriptor *)sort forContext: (NSManagedObjectContext *)context;
-(NSEntityDescription*)newEntityWithName: (NSString *)entityName forContext : (NSManagedObjectContext *)context;

-(NSManagedObjectContext *)getNewManagedObjectContext;
-(void)deleteEntityObject: (NSManagedObject*)object withContext:(NSManagedObjectContext *)context;

@end
