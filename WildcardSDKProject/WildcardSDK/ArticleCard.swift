//
//  ArticleCard.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/3/14.
//
//

import Foundation

/**
Article Card
*/
@objc
public class ArticleCard : Card{
    
    public let title:String
    public let html:String
    public let publisher:Publisher
    
    public var publicationDate:NSDate?
    public var isBreaking:Bool?
    public var abstractContent:String?
    public var source:String?
    public var author:String?
    public var updatedDate:NSDate?
    public var media:[NSDictionary]?
    public var appLinkAndroid:NSURL?
    public var appLinkIOS:NSURL?
    public var primaryImageURL:NSURL?
    
    public init(title:String,html:String, url:NSURL,publisher:Publisher){
        self.title = title
        self.html = html
        self.publisher = publisher
        super.init(webUrl: url, cardType: "article")
    }
    
    override class func deserializeFromData(data: NSDictionary) -> AnyObject? {
        var articleCard:ArticleCard?
        
        var startURL:NSURL?
        var title:String?
        var html:String?
        var publisher:Publisher?
        if let urlString = data["startUrl"] as? String{
            startURL = NSURL(string:urlString)
        }
        
        if let brandData = data["brand"] as? NSDictionary{
            publisher = Publisher.deserializeFromData(brandData) as? Publisher
        }
        
        if let article = data["article"] as? NSDictionary{
            title = article["title"] as? String
            html = article["html"] as? String
            if(title != nil && html != nil && startURL != nil && publisher != nil){
                articleCard = ArticleCard(title: title!, html: html!, url: startURL!, publisher:publisher!)
                
                if let epochTime = article["publishedAt"] as? NSTimeInterval{
                    articleCard?.publicationDate = NSDate(timeIntervalSince1970: epochTime/1000)
                }
                
                if let epochTime = article["lastUpdatedAt"] as? NSTimeInterval{
                    articleCard?.updatedDate = NSDate(timeIntervalSince1970: epochTime/1000)
                }
                
                articleCard?.abstractContent = article["description"] as? String
                articleCard?.author = article["author"] as? String
                articleCard?.source = article["source"] as? String
                articleCard?.isBreaking = article["breaking"] as? Bool
                articleCard?.media = article["media"] as? [NSDictionary]
                
                if articleCard?.media != nil && articleCard?.media?.count > 0{
                    if let mediaDictionary = articleCard?.media![0]{
                        if mediaDictionary["type"] as String == "image"{
                            let src = mediaDictionary["src"] as String
                            articleCard?.primaryImageURL = NSURL(string:src)
                        }
                    }
                }
            }
        }
        return articleCard
    }
    
    /**
    Attempts to create an Article Card from a URL.
    */
    public class func createFromUrl(url:NSURL, completion: ((ArticleCard?, NSError?)->Void)) -> Void{
        Platform.sharedInstance.getArticleCardFromWebUrl(url,completion:completion)
    }
    
    /**
    Searches for Article Cards from a given query. Caps out at 10 cards.
    */
    public class func search(query:String, completion: (([ArticleCard]?, NSError?)->Void)) -> Void{
        search(query, limit: 10, completion: completion)
    }
    
    /**
    Searches for Article Cards from a given query with an arbitrary limit.
    */
    public class func search(query:String, limit:Int, completion: (([ArticleCard]?, NSError?)->Void)) -> Void{
        Platform.sharedInstance.generalSearchFromQuery(query, limit:limit, vertical:"news", completion: { (cards:[Card]?, error:NSError?) -> Void in
            if(error != nil){
                completion(nil,error)
            }else{
                var articleCards:[ArticleCard] = []
                for card in cards!{
                    if let articleCard = card as? ArticleCard{
                        articleCards.append(articleCard)
                    }
                }
                completion(articleCards,nil)
            }
        })
    }
    
    
}