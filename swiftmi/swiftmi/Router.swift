//
//  Router.swift
//  swiftmi
//
//  Created by yangyin on 15/4/23.
//  Copyright (c) 2015年 swiftmi. All rights reserved.
//

import UIKit
import Alamofire



enum Router: URLRequestConvertible {
    /// Returns a URL request or throws if an `Error` was encountered.
    ///
    /// - throws: An `Error` if the underlying `URLRequest` is `nil`.
    ///
    /// - returns: A URL request.
    public func asURLRequest() throws -> URLRequest {
        return self.urlRequest
    }

   
    static var token: String?
    
    //Restfull api
    case topicComment(parameters:[String: AnyObject])
    case topicCreate(parameters:[String: AnyObject])
    case topicList(maxId:Int,count:Int)
    case topicDetail(topicId:Int)
    case codeList(maxId:Int,count:Int)
    case codeDetail(codeId:Int)
    case bookList(type:Int,maxId:Int,count:Int)
    case userRegister(parameters:[String: AnyObject])
    case userLogin(parameters:[String: AnyObject])
    case articleList(maxId:Int,count:Int)
    case articleDetail(articleId:Int)

    var method: Alamofire.HTTPMethod {
        switch self {
        case .topicComment:
            return .post
        case .topicCreate:
            return .post
        case .topicDetail:
            return .get
        case .topicList:
            return .get
        case .codeList:
            return .get
        case .codeDetail:
            return .get
        case .bookList:
            return .get
        case .userRegister:
            return .post
        case .userLogin:
            return .post
        default:
            return .get
        }
        
    }
    
    
    var path: String {
        switch self {
        case .topicComment:
            return ServiceApi.getTopicCommentUrl()
        
        case .topicCreate:
            return ServiceApi.getCreateTopicUrl()
            
        case .topicDetail(let topicId):
            
            return ServiceApi.getTopicDetail(topicId)
            
        case .topicList(let maxId,let count):
            return ServiceApi.getTopicUrl(maxId,count:count)
        case .codeList(let maxId,let count):
            return ServiceApi.getCodeUrl(maxId,count:count)
        case .bookList(let type,let maxId,let count):
            return ServiceApi.getBookUrl(type, maxId: maxId, count: count)
        case .userLogin(_):
            return ServiceApi.getLoginUrl()
        case .userRegister(_):
            return ServiceApi.getRegistUrl()
        case .codeDetail(let codeId):
            return ServiceApi.getCodeDetailUrl(codeId)
        case .articleList(let maxId,let count):
            return ServiceApi.getArticlesUrl(maxId, count: count)
        case .articleDetail(let articleId):
            return ServiceApi.getArticlesDetail(articleId)
        }
    }
    
    
    var urlRequest: URLRequest {
        let url =  URL(string: path)!
        var mutableURLRequest = URLRequest(url: url)
        mutableURLRequest.httpMethod = method.rawValue
        
        if let token = Router.token {
            mutableURLRequest.setValue("\(token)", forHTTPHeaderField: "token")
        }
        
        mutableURLRequest.setValue("com.swiftmi.app", forHTTPHeaderField: "clientid")
        mutableURLRequest.setValue("1.0", forHTTPHeaderField: "appversion")
        
        switch self {
        case .topicComment(let parameters):
            do {
                return try Alamofire.JSONEncoding().encode(mutableURLRequest, with: parameters)

            }catch {
            }
        case .topicCreate(let parameters):
            do {
                return try Alamofire.JSONEncoding().encode(mutableURLRequest, with: parameters)
                
            }catch {
            }
         case .userRegister(let parameters):
            do {
                return try Alamofire.JSONEncoding().encode(mutableURLRequest, with: parameters)
                
            }catch {
            }
         case .userLogin(let parameters):
            do {
                return try Alamofire.JSONEncoding().encode(mutableURLRequest, with: parameters)
                
            }catch {
            }
        default:
            return mutableURLRequest
        }
        return mutableURLRequest
    }
}
