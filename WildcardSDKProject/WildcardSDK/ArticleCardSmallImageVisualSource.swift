//
//  ArticleCard4x3FloatRightImageTextWrapVisualSource.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 1/18/15.
//
//

import Foundation


public class ArticleCardShortVisualSource : BaseVisualSource, CardViewVisualSource
{
    var header:FullCardHeader!
    var body:ImageFloatRightBody!
    var footer:ReadMoreFooter!
    var footerWeb:ViewOnWebCardFooter!
    
    @objc public func viewForCardHeader()->CardViewElement?{
        if(header == nil){
            header = CardViewElementFactory.createCardViewElement(WCElementType.FullHeader) as! FullCardHeader
            header.hairline.hidden = true
        }
        return header
    }
    
    @objc public func viewForCardBody()->CardViewElement{
        if(body == nil){
            self.body = CardViewElementFactory.createCardViewElement(WCElementType.ImageFloatRight) as! ImageFloatRightBody
            self.body.contentEdgeInset = UIEdgeInsetsMake(5, 15, 0, 15)
        }
        return body
    }
    
    @objc public func viewForCardFooter() -> CardViewElement? {
        if let articleCard = card as? ArticleCard{
            if(articleCard.html == nil){
                if(footerWeb == nil){
                    self.footerWeb = CardViewElementFactory.createCardViewElement(WCElementType.ViewOnWebFooter) as! ViewOnWebCardFooter
                    self.footerWeb.hairline.hidden = true
                }
                return footerWeb
            }else{
                if(footer == nil){
                    self.footer = CardViewElementFactory.createCardViewElement(WCElementType.ReadMoreFooter) as! ReadMoreFooter
                    self.footer.contentEdgeInset = UIEdgeInsetsMake(15, 15, 15, 15)
                }
                return footer
            }
        }else{
            return nil
        }
    }
}