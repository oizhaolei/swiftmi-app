//
//  PostDal.swift
//  swiftmi
//
//  Created by yangyin on 15/3/28.
//  Copyright (c) 2015年 swiftmi. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

extension Optional {
    func valueOrDefault(_ defaultValue: Wrapped) -> Wrapped {
        switch(self) {
        case .none:
            return defaultValue
        case .some(let value):
            return value
        }
    }
}


class PostDal:NSObject {
    
    func addPostList(_ items:[AnyObject]) {
        
        for po in items {
            
            self.addPost(po, save: false)
        }
        
        CoreDataManager.shared.save()
    }
    
    func addPost(_ obj:AnyObject,save:Bool){
        
        
        let context=CoreDataManager.shared.managedObjectContext;
        
        
        let model = NSEntityDescription.entity(forEntityName: "Post", in: context)
        
        let post = Post(entity: model!, insertInto: context)
        
        if model != nil {
            self.obj2ManagedObject(obj, post: post)            
            if(save)
            {
                CoreDataManager.shared.save()
                
            }
        }
    }
    
    func deleteAll(){
       
        CoreDataManager.shared.deleteTable(request: NSFetchRequest<Post>(),tableName: "Post")
    }
    
    func save(){
        let context=CoreDataManager.shared.managedObjectContext;
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func getPostList()->[AnyObject]? {
        
        
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Post")
        let sort1=NSSortDescriptor(key: "lastCommentTime", ascending: false)
       
       // var sort2=NSSortDescriptor(key: "postId", ascending: false)
        request.fetchLimit = 30
        request.sortDescriptors = [sort1]
        request.resultType = NSFetchRequestResultType.dictionaryResultType
        let result = CoreDataManager.shared.executeFetchRequest(request)
        return result
    
    }
    
    func obj2ManagedObject(_ obj:AnyObject,post:Post) {
        
         var data = JSON(obj)
    
        let postId = data["postId"].int64!
        let title = data["title"].string!
        let content = data["content"].string
        let createTime = data["createTime"].int64!
        let updateTime = data["updateTime"].int64

        let channelId = data["channelId"].int64!
        let channelName = data["channelName"].string
        let commentCount = data["commentCount"].int32!
        let lastCommentId = data["lastCommentId"].int64
        let lastCommentTime =  data["lastCommentTime"].int64!
        let viewCount = data["viewCount"].int32!
        let authorId = data["authorId"].int64!
        let authorName = data["authorName"].string
        let avatar = data["avatar"].string
        // _ = data["cmtUserId"].int64
        let cmtUserName = data["cmtUserName"].string
        let desc = data["desc"].string
        let isHtml = data["commentCount"].int32!
        
        post.postId = postId
        post.title = title
        post.content = content
        post.createTime = createTime
        post.updateTime = updateTime ?? 0
        
        post.channelId = channelId
        post.channelName = channelName
        post.commentCount = commentCount
        post.lastCommentId = lastCommentId ?? 0
        post.lastCommentTime = lastCommentTime
        post.viewCount = viewCount
        post.authorId = authorId
        post.authorName = authorName
        post.avatar = avatar
        //post.cmtUserId = cmtUserId
        post.cmtUserName = cmtUserName
        post.desc = desc
        post.isHtml = isHtml
        
    }
}
