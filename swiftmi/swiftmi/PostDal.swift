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
    func valueOrDefault(defaultValue: T) -> T {
        switch(self) {
        case .None:
            return defaultValue
        case .Some(let value):
            return value
        }
    }
}


class PostDal:NSObject {
    
    func addPostList(items:[AnyObject]) {
        
        for po in items {
            
            self.addPost(po, save: false)
        }
        
        CoreDataManager.shared.save()
    }
    
    func addPost(obj:AnyObject,save:Bool){
        
        
        var context=CoreDataManager.shared.managedObjectContext;
        
        
        let model = NSEntityDescription.entityForName("Post", inManagedObjectContext: context)
        
        var post = Post(entity: model!, insertIntoManagedObjectContext: context)
        
        if model != nil {
            //var article = model as Article;
            self.obj2ManagedObject(obj, post: post)
            
            if(save)
            {
                CoreDataManager.shared.save()
                
            }
        }
    }
    
    func deleteAll(){
       
        CoreDataManager.shared.deleteTable("Post")
    }
    
    func save(){
        var context=CoreDataManager.shared.managedObjectContext;
        context.save(nil)
    }
    
    func getPostList()->[AnyObject]? {
        
        var request = NSFetchRequest(entityName: "Post")
        var sort1=NSSortDescriptor(key: "lastCommentTime", ascending: false)
       
       // var sort2=NSSortDescriptor(key: "postId", ascending: false)
        request.fetchLimit = 30
        request.sortDescriptors = [sort1]
        request.resultType = NSFetchRequestResultType.DictionaryResultType
        var result = CoreDataManager.shared.executeFetchRequest(request)
        return result
    
    }
    
    func obj2ManagedObject(obj:AnyObject,post:Post) -> Post{
        
         var data = JSON(obj)
    
        var postId = data["postId"].int64!
        var title = data["title"].string!
        var content = data["content"].string
        var createTime = data["createTime"].int64!
        var updateTime = data["updateTime"].int64

        var channelId = data["channelId"].int64!
        var channelName = data["channelName"].string
        var commentCount = data["commentCount"].int32!
        var lastCommentId = data["lastCommentId"].int64
        var lastCommentTime =  data["lastCommentTime"].int64!
        var viewCount = data["viewCount"].int32!
        var authorId = data["authorId"].int64!
        var authorName = data["authorName"].string
        var avatar = data["avatar"].string
        var cmtUserId = data["cmtUserId"].int64
        var cmtUserName = data["cmtUserName"].string
        var desc = data["desc"].string
        var isHtml = data["commentCount"].int32!
        
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
        
        //var tickes:Double = (obj.valueForKey("posttime") as Double);
        //var date=NSDate(timeIntervalSince1970: tickes);
        //article.posttime=date;
        //article.content = content
        //article.thumbnail=thumbnail
        
      //  println(post)
        return post;
    }
}