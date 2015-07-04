
import Foundation
import CoreData

class CoreDataManager: NSObject {
    
    let storeName="dev-swiftmi03.sqlite"
    let dataModelName="Model"
    
    var _managedObjectContext:NSManagedObjectContext?=nil
    var _managedObjectModel:NSManagedObjectModel?=nil
    var _persistentStoreCoordinator:NSPersistentStoreCoordinator?=nil
    
    class var shared:CoreDataManager{
        get{
            struct Static{
                static var instance:CoreDataManager?=nil
                static var token:dispatch_once_t = 0

            }
            
            dispatch_once(&Static.token){
                Static.instance=CoreDataManager()
            }
            return Static.instance!
         }
    }
    
    var managedObjectContext:NSManagedObjectContext{
        if NSThread.isMainThread()
        {
            if !(_managedObjectContext != nil){
                 let coordinator = self.persistentStoreCoordinator
                 if coordinator != NSNull() {
                    _managedObjectContext=NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
                    _managedObjectContext!.persistentStoreCoordinator=coordinator
                }
                return _managedObjectContext!
            }
            
        }else{
            var threadContext:NSManagedObjectContext?=NSThread.currentThread().threadDictionary["NSManagedObjectContext"] as? NSManagedObjectContext;
            if threadContext==nil{
                
                threadContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
                threadContext!.parentContext = _managedObjectContext
                threadContext!.name=NSThread.currentThread().description
                NSThread.currentThread().threadDictionary["NSManagedObjectContext"] = threadContext
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "contextWillSave", name: NSManagedObjectContextWillSaveNotification, object: threadContext)
                

            }
            else{
                 println("using old context")
            }
            return threadContext!;

            
        }
        return _managedObjectContext!
    }
    
    // Returns the managed object model for the application.
    // If the model doesn't already exist, it is created from the application's model.
    var managedObjectModel:NSManagedObjectModel{
    
       if !(_managedObjectModel != nil){
           let modelURL=NSBundle.mainBundle().URLForResource(dataModelName, withExtension: "momd")
            _managedObjectModel=NSManagedObjectModel(contentsOfURL: modelURL!)
        }
        return _managedObjectModel!
    }
    
    
    var persistentStoreCoordinator:NSPersistentStoreCoordinator{
    
    if !(_persistentStoreCoordinator != nil){
          let storeURL=self.applicationDocumentsDirectory.URLByAppendingPathComponent(storeName)
        var error:NSError?=nil
        _persistentStoreCoordinator=NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        if _persistentStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: self.databaseOptions(), error:&error)==nil {
            abort()
        }
        
        
        
        }
        return _persistentStoreCoordinator!;
    }
    
    
     // #pragma mark - fetches
    
    func executeFetchRequest(request:NSFetchRequest)->Array<AnyObject>?{
        var results:Array<AnyObject>?
        self.managedObjectContext.performBlockAndWait{
             var fetchError:NSError?
            
            results=self.managedObjectContext.executeFetchRequest(request, error: &fetchError);
            if let error=fetchError{
                println("Warning!! \(error.description)")
            }
        }
        return results;
    }
    
    func executeFetchRequest(request:NSFetchRequest,completionHandler:(results:Array<AnyObject>?) -> Void){
        
        self.managedObjectContext.performBlock(){
            var fetchError:NSError?
            var results:Array<AnyObject>?
            
            results=self.managedObjectContext.executeFetchRequest(request, error: &fetchError)
            if let error=fetchError {
                 println("Warning!! \(error.description)")
            }
            
            completionHandler(results: results)
            
        }
    }
    
    func save(){
        var context:NSManagedObjectContext = self.managedObjectContext
        if context.hasChanges {
            context.performBlock{
                
                var saveError:NSError?
                let saved=context.save(&saveError);
                if !saved {
                    if let error = saveError{
                        println("Warning!! Saving error \(error.description)")
                    }
                }
                
                if (context.parentContext != nil) {
                    context.parentContext!.performBlockAndWait{
                        var saveError:NSError?
                        let saved = context.parentContext!.save(&saveError)
                        
                        if !saved{
                            if let error = saveError{
                                println("Warning!! Saving parent error \(error.description)")
                            }
                        }
                    }
                }
                
            }
        }
        
    }
    
    
    func contextWillSave(notification:NSNotification){
        let context : NSManagedObjectContext! = notification.object as! NSManagedObjectContext
        var insertedObjects:NSSet = context.insertedObjects;
        
        if insertedObjects.count != 0 {
             var obtainError:NSError?
            
            context.obtainPermanentIDsForObjects(insertedObjects.allObjects, error: &obtainError)
            
            if let error = obtainError {
                println("Warning!! obtaining ids error \(error.description)")
            }
        }
    }
    
    func deleteEntity(object:NSManagedObject){
        
    
        object.managedObjectContext?.deleteObject(object)
    }
    
    func deleteTable(tableName:String){
        var managedObjectContext=self.managedObjectContext;
        var entity=NSEntityDescription.entityForName(tableName, inManagedObjectContext: managedObjectContext)
        var request=NSFetchRequest()
        request.includesPropertyValues=false;
        request.entity=entity;
        
        var items=self.executeFetchRequest(request);
        if (items != nil&&items!.count>0) {
            for obj in items! {
                var item = obj as! NSManagedObject;
               self.deleteEntity(item)
            }
            
            self.save()
        }
    }
    
   
    
    
    
    // #pragma mark - Application's Documents directory
    
    // Returns the URL to the application's Documents directory.
    var applicationDocumentsDirectory: NSURL {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
      //  println(urls[urls.endIndex-1] as NSURL)
        
        return urls[urls.endIndex-1] as! NSURL
    }
    
    func databaseOptions() -> Dictionary <String,Bool> {
        var options =  Dictionary<String,Bool>()
        options[NSMigratePersistentStoresAutomaticallyOption] = true
        options[NSInferMappingModelAutomaticallyOption] = true
        return options
    }

    
}