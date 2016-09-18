
import Foundation
import CoreData

class CoreDataManager: NSObject {
    
    let storeName="dev-swiftmi06.sqlite"
    let dataModelName="Model"
    
    var _managedObjectContext:NSManagedObjectContext?=nil
    var _managedObjectModel:NSManagedObjectModel?=nil
    var _persistentStoreCoordinator:NSPersistentStoreCoordinator?=nil
    
    static let shared:CoreDataManager = {
        let instance = CoreDataManager()
        return instance
    }()
    
    var managedObjectContext:NSManagedObjectContext{
        if Thread.isMainThread
        {
            if !(_managedObjectContext != nil){
                 let coordinator = self.persistentStoreCoordinator
                 if coordinator != NSNull() {
                    _managedObjectContext=NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
                    _managedObjectContext!.persistentStoreCoordinator=coordinator
                }
                return _managedObjectContext!
            }
            
        }else{
            var threadContext:NSManagedObjectContext?=Thread.current.threadDictionary["NSManagedObjectContext"] as? NSManagedObjectContext;
            if threadContext==nil{
                
                threadContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                threadContext!.parent = _managedObjectContext
                threadContext!.name=Thread.current.description
                Thread.current.threadDictionary["NSManagedObjectContext"] = threadContext
                
                NotificationCenter.default.addObserver(self, selector: #selector(CoreDataManager.contextWillSave(_:)), name: NSNotification.Name.NSManagedObjectContextWillSave, object: threadContext)
                

            }
            else{
                 print("using old context")
            }
            return threadContext!;

            
        }
        return _managedObjectContext!
    }
    
    // Returns the managed object model for the application.
    // If the model doesn't already exist, it is created from the application's model.
    var managedObjectModel:NSManagedObjectModel{
    
       if !(_managedObjectModel != nil){
           let modelURL=Bundle.main.url(forResource: dataModelName, withExtension: "momd")
            _managedObjectModel=NSManagedObjectModel(contentsOf: modelURL!)
        }
        return _managedObjectModel!
    }
    
    
    var persistentStoreCoordinator:NSPersistentStoreCoordinator{
    
    if !(_persistentStoreCoordinator != nil){
          let storeURL=self.applicationDocumentsDirectory.appendingPathComponent(storeName)
        //var error:NSError?=nil
        _persistentStoreCoordinator=NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        do {
            try _persistentStoreCoordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: self.databaseOptions())
        } catch _ as NSError {
            //error = error1
            abort()
        }
        
        
        
        }
        return _persistentStoreCoordinator!;
    }
    
    
     // #pragma mark - fetches
    
    func executeFetchRequest(_ request:NSFetchRequest<NSFetchRequestResult>)->Array<NSFetchRequestResult>?{
        var results:Array<NSFetchRequestResult>?
        self.managedObjectContext.performAndWait{
             var fetchError:NSError?
            
             do {
                results = try self.managedObjectContext.fetch(request)
             } catch let error as NSError {
                 fetchError = error
                 results = nil
             } catch {
                 fatalError()
             };
            if let error=fetchError{
                print("Warning!! \(error.description)")
            }
        }
        return results;
    }
    
    func executeFetchRequest(_ request:NSFetchRequest<NSFetchRequestResult>,completionHandler:@escaping (_ results:Array<NSFetchRequestResult>?) -> Void){
        
        self.managedObjectContext.perform(){
            var fetchError:NSError?
            var results:Array<NSFetchRequestResult>?
            
            do {
                 results=try self.managedObjectContext.fetch(request)
            } catch let error as NSError {
                fetchError = error
                results = nil
            } catch {
                fatalError()
            }
            if let error=fetchError {
                 print("Warning!! \(error.description)")
            }
            
            completionHandler(results)
            
        }
    }
    
    func save(){
        let context:NSManagedObjectContext = self.managedObjectContext
        if context.hasChanges {
            context.perform{
                
                var saveError:NSError?
                let saved: Bool
                do {
                    try context.save()
                    saved = true
                } catch let error as NSError {
                    saveError = error
                    saved = false
                } catch {
                    fatalError()
                };
                if !saved {
                    if let error = saveError{
                        print("Warning!! Saving error \(error.description)")
                    }
                }
                
                if (context.parent != nil) {
                    context.parent!.performAndWait{
                        var saveError:NSError?
                        let saved: Bool
                        do {
                            try context.parent!.save()
                            saved = true
                        } catch let error as NSError {
                            saveError = error
                            saved = false
                        } catch {
                            fatalError()
                        }
                        
                        if !saved{
                            if let error = saveError{
                                print("Warning!! Saving parent error \(error.description)")
                            }
                        }
                    }
                }
                
            }
        }
        
    }
    
    
    func contextWillSave(_ notification:Notification){
        let context : NSManagedObjectContext! = notification.object as! NSManagedObjectContext
        let insertedObjects:NSSet = context.insertedObjects as NSSet;
        
        if insertedObjects.count != 0 {
             var obtainError:NSError?
            
            
            
             do {
                 try context.obtainPermanentIDs(for: insertedObjects.allObjects as! [NSManagedObject])
                
             } catch let error as NSError {
                 obtainError = error
             }
            
            if let error = obtainError {
                print("Warning!! obtaining ids error \(error.description)")
            }
        }
    }
    
    func deleteEntity(_ object:NSManagedObject){
        
    
        object.managedObjectContext?.delete(object)
    }
    
    func deleteTable<ResultType:NSFetchRequestResult>(request:NSFetchRequest<ResultType>,tableName:String){
        let managedObjectContext=self.managedObjectContext;
        let entity=NSEntityDescription.entity(forEntityName: tableName, in: managedObjectContext)
        let request=NSFetchRequest<NSFetchRequestResult>()
        request.includesPropertyValues=false;
        request.entity=entity;
        
        let items=self.executeFetchRequest(request);
        if (items != nil&&items!.count>0) {
            for obj in items! {
                let item = obj as! NSManagedObject;
               self.deleteEntity(item)
            }
            
            self.save()
        }
    }
    
   
    
    
    
    // #pragma mark - Application's Documents directory
    
    // Returns the URL to the application's Documents directory.
    var applicationDocumentsDirectory: URL {
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
      //  println(urls[urls.endIndex-1] as NSURL)
        
        return urls[urls.endIndex-1] 
    }
    
    func databaseOptions() -> Dictionary <String,Bool> {
        var options =  Dictionary<String,Bool>()
        options[NSMigratePersistentStoresAutomaticallyOption] = true
        options[NSInferMappingModelAutomaticallyOption] = true
        return options
    }

    
}
