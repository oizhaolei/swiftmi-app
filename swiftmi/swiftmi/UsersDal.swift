//
//  UsersDal.swift
//  swiftmi
//
//  Created by yangyin on 15/4/18.
//  Copyright (c) 2015年 swiftmi. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON


class UsersDal: NSObject {
    
    
    
    func addUser(obj:JSON,save:Bool)->Users? {
        
        
        var context=CoreDataManager.shared.managedObjectContext;
        
        
        let model = NSEntityDescription.entityForName("Users", inManagedObjectContext: context)
        
        var user = Users(entity: model!, insertIntoManagedObjectContext: context)
        
        if model != nil {
           
            var addUser = self.JSON2Object(obj, user: user)
            
            if(save)
            {
                CoreDataManager.shared.save()
                
            }
            
            return addUser
        }
        return nil
    }
    
    internal func deleteAll(){
        
        CoreDataManager.shared.deleteTable("Users")
    }
    
   internal  func save(){
        var context=CoreDataManager.shared.managedObjectContext;
        context.save(nil)
    }
    
   internal  func getCurrentUser()->Users? {
        
        var request = NSFetchRequest(entityName: "Users")
        request.fetchLimit = 1
        
    
        var result = CoreDataManager.shared.executeFetchRequest(request)
        if let users = result {
            
            if (users.count > 0 ){
                 return users[0] as? Users
            }
            return nil
           
        }
        else {
            return nil
        }
        
    }
    
    internal func JSON2Object(obj:JSON,user:Users) -> Users{
        
        var data = obj
        
        var userId = data["userId"].int64!
        var username = data["username"].string!
        var email = data["email"].string
        var following_count = data["following_count"].int32!
        var follower_count = data["follower_count"].int32!
        var points = data["points"].int32!
        
        var signature = data["signature"].string
        var profile = data["profile"].string
        var isAdmin = data["isAdmin"].int32!
        var avatar = data["avatar"].string
        var createTime =  data["createTime"].int64!
        var updateTime = data["updateTime"].int64!
       
        
        user.userId = userId
        user.username = username
        user.email = email
        user.follower_count = follower_count
        user.following_count = following_count
        user.points = points
        user.signature = signature
        user.profile = profile
        user.isAdmin = isAdmin
        user.avatar = avatar
        user.createTime = createTime
        user.updateTime = updateTime
        
        return user;
    }
}
