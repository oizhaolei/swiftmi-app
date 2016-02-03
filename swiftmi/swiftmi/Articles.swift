//
//  Articles.swift
//  swiftmi
//
//  Created by yangyin on 16/2/3.
//  Copyright © 2016年 swiftmi. All rights reserved.
//

import Foundation
import CoreData

@objc(Article)
public class Article:NSManagedObject {
    
    @NSManaged var articleId:Int64
    @NSManaged var title:String?
    @NSManaged var content:String?
    @NSManaged var createDate:Int64
    @NSManaged var sourceName:String?
    @NSManaged var sourceUrl:String?
    @NSManaged var author:String?
    @NSManaged var viewCount:Int64
    @NSManaged var siteId:Int64
    @NSManaged var language:String?
    @NSManaged var imageUrl:String?
}
