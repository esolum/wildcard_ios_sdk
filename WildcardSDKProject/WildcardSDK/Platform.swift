//
//  Platform.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/4/14.
//
//

import Foundation

protocol PlatformObject{
    class func deserializeFromData(data:NSDictionary) -> AnyObject?
}

class Platform{
    
    let PLATFORM_BASE_URL = "https://platform-prod.trywildcard.com"
    let API_VERSION = "v1.0"
    
    class var sharedInstance : Platform{
        struct Static{
            static var instance : Platform = Platform()
        }
        return Static.instance
    }
    
    func createWildcardShortLink(url:NSURL, completion:((url:NSURL?,error:NSError?)->Void)) ->Void
    {
        var targetUrlEncoded = url.absoluteString!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        var urlString = Platform.sharedInstance.PLATFORM_BASE_URL + "/v1.0/shortlink?url=" + targetUrlEncoded!
        if let shortLinkPlatformUrl = NSURL(string:urlString){
            getJsonResponseFromPlatform(shortLinkPlatformUrl) { (json:NSDictionary?, error:NSError?) -> Void in
                if(error == nil){
                    if let shortLink = json!["short_link_result"] as? String{
                        completion(url:NSURL(string: shortLink),error:nil)
                    }else{
                        let error = NSError(domain: NSBundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.MalformedResponse.rawValue, userInfo: nil)
                        completion(url:nil, error:error)
                    }
                }else{
                    completion(url:nil,error:error)
                }
            }
        }else{
            let error = NSError(domain: NSBundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.MalformedRequest.rawValue, userInfo: nil)
            completion(url:nil,error:error)
        }
    }
    
    func getFromUrl(url:NSURL, completion: ((card:Card?, error:NSError?)->Void)) -> Void
    {
        if (WildcardSDK.apiKey != nil){
            
            let params = NSMutableDictionary()
            params["url"] = url.absoluteString
            WildcardSDK.analytics?.trackEvent("GetCardCalled", withProperties: params, withCard: nil)
            
            var urlParam = url.absoluteString!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            var urlString = Platform.sharedInstance.PLATFORM_BASE_URL +
            "/public/\(API_VERSION)/get_card?api_key=\(WildcardSDK.apiKey!)&web_url=\(urlParam)"
            
            if let platformUrl = NSURL(string:urlString){
                getCardJsonResponseFromPlatform(platformUrl) { (json:NSDictionary?, error:NSError?) -> Void in
                    if(error == nil){
                        var returnCard = Card.deserializeFromData(json!) as? Card
                        if (returnCard == nil){
                            let deserializeError = NSError(domain: NSBundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.CardDeserializationError.rawValue, userInfo: nil)
                            completion(card:nil,error:deserializeError)
                        }else{
                            WildcardSDK.analytics?.trackEvent("GetCardSuccess", withProperties: nil, withCard: returnCard!)
                            completion(card:returnCard,error:nil)
                        }
                    }else{
                        completion(card:nil,error:error)
                    }
                }
            }else{
                let error = NSError(domain: NSBundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.MalformedRequest.rawValue, userInfo: nil)
                completion(card:nil,error:error)
            }
            
        }else{
            let notInitializedError = NSError(domain: NSBundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.UninitializedAPIKey.rawValue, userInfo:nil)
            completion(card:nil,error:notInitializedError)
        }
    }
    
    // MARK: Private
    private func getCardJsonResponseFromPlatform(url:NSURL, completion:((NSDictionary?, NSError?)->Void)) -> Void
    {
        let params = NSMutableDictionary()
        params["url"] = url.absoluteString
        
        var session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue:WildcardSDK.networkDelegateQueue)
        var task:NSURLSessionTask = session.dataTaskWithURL(url, completionHandler: { (data:NSData!, response:NSURLResponse!, error:NSError!) -> Void in
            if(error != nil){
                completion(nil, error)
            }else{
                var jsonError:NSError?
                var json:NSDictionary? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSDictionary
                if (jsonError == nil) {
                    let httpResponse = response as NSHTTPURLResponse
                    if(httpResponse.statusCode == 400){
                        let badRequestError = NSError(domain: NSBundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.BadRequest.rawValue, userInfo: json!)
                        completion(nil,badRequestError)
                    }else if(httpResponse.statusCode == 401){
                        let permissionDenied = NSError(domain: NSBundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.PermissionDenied.rawValue, userInfo: json!)
                        completion(nil,permissionDenied)
                    }else if(httpResponse.statusCode == 501){
                        WildcardSDK.analytics?.trackEvent("GetCardFailedNotImplemented", withProperties: params, withCard: nil)
                        let error = NSError(domain: NSBundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.NotImplemented.rawValue, userInfo: json!)
                        completion(nil,error)
                    }else if(httpResponse.statusCode == 500){
                        WildcardSDK.analytics?.trackEvent("GetCardFailedInternalError", withProperties: params, withCard: nil)
                        let error = NSError(domain: NSBundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.InternalServerError.rawValue, userInfo: json!)
                        completion(nil,error)
                    }else if(httpResponse.statusCode == 200){
                        if let result = json!["result"] as? NSDictionary{
                            completion(result,nil)
                        }else{
                            let malformedError = NSError(domain: NSBundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.MalformedResponse.rawValue, userInfo: nil)
                            completion(nil,malformedError)
                        }
                    }else{
                        let error = NSError(domain: NSBundle.wildcardSDKBundle().bundleIdentifier!, code: WCErrorCode.Unknown.rawValue, userInfo: json!)
                        completion(nil,error)
                    }
                }
                else {
                    completion(nil,jsonError)
                }
            }
        })
        task.resume()
    }
    
    private func getJsonResponseFromPlatform(url:NSURL, completion:((NSDictionary?, NSError?)->Void)) -> Void
    {
        var session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue:WildcardSDK.networkDelegateQueue)
        var task:NSURLSessionTask = session.dataTaskWithURL(url, completionHandler: { (data:NSData!, response:NSURLResponse!, error:NSError!) -> Void in
            if(error != nil){
                completion(nil, error)
            }else{
                var jsonError:NSError?
                var json:NSDictionary? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSDictionary
                if (jsonError == nil) {
                    completion(json!,nil)
                }
                else {
                    completion(nil,jsonError)
                }
            }
        })
        task.resume()
    }
    
}