//
//  CardView.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/8/14.
//
//

import Foundation
import UIKit
import QuartzCore

/**
The visual source of a CardView.

Every CardView is associated with a visual source to provide layout guidelines as well as views for various subcomponents. If you choose to completely customize a card, you will have to implement a visual source of your own.
*/
@objc
public protocol CardViewVisualSource{
    
    /// Width for the card
    func widthForCard()->CGFloat
    
    /// CardViewElement for the card body
    func viewForCardBody()->CardViewElement
    
    /// Height for the card body, must be >0
    func heightForCardBody()->CGFloat
    
    /// Optional CardViewElement for header
    optional func viewForCardHeader()->CardViewElement?
    
    /// Height for card header, must be >0 if header is not nil
    optional func heightForCardHeader()->CGFloat
    
    /// Optional CardViewElement for footer
    optional func viewForCardFooter()->CardViewElement?
    
    /// Height for card footer, must be >0 if footer is not nil
    optional func heightForCardFooter()->CGFloat
    
    /// Optional CardViewElement for the back of the card. Height is always full card height.
    optional func viewForBackOfCard()->CardViewElement?
}

/**
The visual source of a maximized CardView extends from the standard visual source.

The maximized visual source should always be used with the extension UIView.maximizeCardView. This visual source is responsible for displaying a Card during its 'maximized state'. In this state, the Card takes up the entire application frame, and is owned by a fully presented view controller.

This visual source may never be used for an inline card. 
*/
@objc
public protocol MaximizedCardViewVisualSource : CardViewVisualSource {
    
    /**
    This represents the edge insets of the maximized CardView to the application frame.
    
    This must be defined carefully with the width / height protocol functions since both will dictate the eventual size of the maximized card.
    */
    func applicationFrameEdgeInsets()->UIEdgeInsets
}

@objc
public protocol CardViewDelegate{
    
    /**
    The CardView is about to go through re-layout. For example, if a CardView is reloaded
    with a brand new Card and visual source, a re-layout of the CardView will happen. This lets
    the delegate prepare for the re-layout given the old and new-size for any elements dependent
    on the CardView
    
    :param: fromSize - The previous size of the CardView
    :param: toSize - The new size of the CardView
    */
    optional func cardViewWillLayoutToNewSize(cardView:CardView, fromSize:CGSize, toSize:CGSize)
    
    /**
    Simply just a hook into UIView.layoutSubviews() for the CardView
    */
    optional func cardViewLayoutSubviews(cardView:CardView)
    
    /**
    CardView is about to be reloaded.
    */
    optional func cardViewWillReload(cardView:CardView)

    /**
    CardView has reloaded.
    */
    optional func cardViewDidReload(cardView:CardView)
    
    /**
    Optionally gates the CardView action, always called before an action is requested.
    
    If this function is not implemented the action will be requested.
    */
    optional func cardViewShouldPerformAction(cardView:CardView, action: CardViewAction) -> Bool
    
    /**
    CardView has been requested to perform a specific action.
    */
    optional func cardViewRequestedAction(cardView:CardView, action: CardViewAction)
    
}

@objc
public class CardView : UIView
{
    // MARK: Public
    
    /// ALPHA: See CardPhysics
    public var physics:CardPhysics?
    
    /// See CardViewDelegate
    public var delegate:CardViewDelegate?
    
    /// The visual source associated with this CardView
    public var visualSource:CardViewVisualSource!
    
    /// The backing card for this CardView
    public var backingCard:Card!
    
    /// Creates a CardView from a card. A layout will be chosen and the CardView will be returned framed at a default size.
    public class func createCardView(card:Card)->CardView?{
        let layoutToUse = CardLayoutEngine.sharedInstance.matchLayout(card)
        return CardView.createCardView(card, layout: layoutToUse)
    }
    
    /// Creates a CardView from a card with a prechosen layout. See WCCardLayout for layouts.
    public class func createCardView(card:Card, layout:WCCardLayout)->CardView?{
        if(!card.supportsLayout(layout)){
            println("Unsupported layout for this card type, returning nil.")
            return nil
        }
        let datasource = CardViewVisualSourceFactory.visualSourceFromLayout(layout, card: card, width:nil)
        return CardView.createCardView(card, visualSource: datasource)
    }

    /// Creates a CardView from a card with a prechosen layout and width. The card's height will be calculated optimally from the width. You may choose various layouts to a get a height that is suitable.
    public class func createCardView(card:Card, layout:WCCardLayout, cardWidth:CGFloat)->CardView?{
        if(!card.supportsLayout(layout)){
            println("Unsupported layout for this card type, returning nil.")
            return nil
        }
        let datasource = CardViewVisualSourceFactory.visualSourceFromLayout(layout, card: card, width:cardWidth)
        return CardView.createCardView(card, visualSource: datasource)
    }
    
    /// Creates a CardView with a customized visual source. See tutorials on how to create your own visual source.
    public class func createCardView(card:Card, visualSource:CardViewVisualSource)->CardView?{
        
        if(WildcardSDK.apiKey == nil){
            println("Wildcard API Key not initialized -- can't create CardView.")
            return nil
        }
        
        let newCardView = CardView(frame: CGRectZero)
        
        // init data and visuals
        newCardView.backingCard = card
        newCardView.visualSource = visualSource
        
        if(newCardView.initializeCardComponents()){
            let currentSize = newCardView.calculateCurrentSize()
            
            // layout card elements
            newCardView.frame = CGRectMake(0, 0, currentSize.width, currentSize.height)
            newCardView.layoutCardComponents()
            
            // layout the card view before returning
            newCardView.layoutIfNeeded()
            
            newCardView.notifyCardViewElementsFinishedLayout()
            
            return newCardView
        }else{
            println("Could not create CardView -- layout problem in visual source.")
            return nil
        }
    }
    
    /// ALPHA: Reloads the CardView with a new card. Autogenerates a layout
    public func reloadWithCard(newCard:Card){
        let layoutToUse = CardLayoutEngine.sharedInstance.matchLayout(newCard)
        return reloadWithCard(newCard, layout: layoutToUse)
    }
    
    /// ALPHA: Reloads the CardView with a new card and specified layout.
    public func reloadWithCard(newCard:Card, layout:WCCardLayout){
        if(!newCard.supportsLayout(layout)){
            println("Unsupported layout for this card type, nothing reloaded.")
            return
        }
        let autoDatasource = CardViewVisualSourceFactory.visualSourceFromLayout(layout, card: newCard, width:nil)
        reloadWithCard(newCard, visualSource: autoDatasource)
    }
    
    /// ALPHA: Reloads the CardView with a new card, specified layout, and width.
    public func reloadWithCard(newCard:Card, layout:WCCardLayout, cardWidth:CGFloat){
        if(!newCard.supportsLayout(layout)){
            println("Unsupported layout for this card type, nothing reloaded.")
            return
        }
        let autoDatasource = CardViewVisualSourceFactory.visualSourceFromLayout(layout, card: newCard, width:cardWidth)
        reloadWithCard(newCard, visualSource: autoDatasource)
    }
    
    /// ALPHA: Reloads the CardView with a custom visual source.
    public func reloadWithCard(card:Card, visualSource:CardViewVisualSource){
        
        backingCard = card
        self.visualSource = visualSource
        
        delegate?.cardViewWillReload?(self)
        
        // remove old card subviews
        removeCardSubviews()
        
        if(initializeCardComponents() == false){
            println("Could not reload CardView -- layout problem in visual source.")
            return
        }
        
        // let delegate prepare before layout happens
        let newSize = calculateCurrentSize()
        delegate?.cardViewWillLayoutToNewSize?(self, fromSize: bounds.size, toSize: newSize)
        layoutCardComponents()
        layoutIfNeeded()
        
        notifyCardViewElementsFinishedLayout()
        
        // reloaded
        delegate?.cardViewDidReload?(self)
    }
    
    public func fadeOut(duration:NSTimeInterval, delay:NSTimeInterval, completion:((bool:Bool) -> Void)?){
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.header?.alpha = 0
            self.body?.alpha = 0
            self.footer?.alpha = 0
            self.back?.alpha = 0
            }) { (bool:Bool) -> Void in
                completion?(bool: bool)
                return
        }
    }
    
    public func fadeIn(duration:NSTimeInterval, delay:NSTimeInterval, completion:((bool:Bool) -> Void)?){
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.header?.alpha = 1
            self.body?.alpha = 1
            self.footer?.alpha = 1
            self.back?.alpha = 1
            }) { (bool:Bool) -> Void in
                completion?(bool: bool)
                return
        }
    }
    
    // MARK: Private properties
    var containerView:UIView!
    var back:CardViewElement?
    var header:CardViewElement?
    var headerHeight:CGFloat?
    var body:CardViewElement!
    var bodyHeight:CGFloat!
    var footer:CardViewElement?
    var footerHeight:CGFloat?
    var width:CGFloat!
    
    // MARK: UIView
    override init(frame: CGRect) {
        super.init(frame: frame)
        convenienceInitialize()
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if(hasSuperview()){
            WildcardSDK.analytics?.trackEvent("CardViewDisplayed", withProperties: nil, withCard: backingCard)
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        convenienceInitialize()
    }
    
    override public func layoutSubviews(){
        super.layoutSubviews()
        
        delegate?.cardViewLayoutSubviews?(self)
        
        // reset shadow path to whatever bounds card is taking up
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: WildcardSDK.cardCornerRadius)
        layer.shadowPath = path.CGPath
    }
    
    required public init(coder: NSCoder) {
        super.init(coder: coder)
        convenienceInitialize()
    }
    
    // MARK: Instance
    func handleShare(){
        Platform.sharedInstance.createWildcardShortLink(backingCard.webUrl, completion: { (url:NSURL?, error:NSError?) -> Void in
            if let shareUrl = url {
                var params:NSDictionary = ["url":shareUrl]
                let cardAction = CardViewAction(type: WCCardAction.Share, parameters: params)
                let shouldPerform = self.delegate?.cardViewShouldPerformAction?(self, action: cardAction)
                if(shouldPerform == true || shouldPerform == nil){
                    self.delegate?.cardViewRequestedAction?(self, action: cardAction)
                }
            }
        })
    }
    
    func handleViewOnWeb(url:NSURL){
        let params:NSDictionary = ["url":url]
        let cardAction = CardViewAction(type: WCCardAction.ViewOnWeb, parameters: params)
        let shouldPerform = delegate?.cardViewShouldPerformAction?(self, action: cardAction)
        if(shouldPerform == true || shouldPerform == nil){
            delegate?.cardViewRequestedAction?(self, action: cardAction)
        }
    }
    
    func handleDownloadApp(){
        if let articleCard = backingCard as? ArticleCard{
            if let url = articleCard.creator.iosAppStoreUrl {
                var lastComponent:NSString = url.lastPathComponent!
                var id = lastComponent.substringFromIndex(2) as NSString
                var params:NSDictionary = ["id":id]
                
                let cardAction = CardViewAction(type: WCCardAction.DownloadApp, parameters: params)
                let shouldPerform = delegate?.cardViewShouldPerformAction?(self, action: cardAction)
                if(shouldPerform == true || shouldPerform == nil){
                    delegate?.cardViewRequestedAction?(self, action: cardAction)
                }
            }
        }
    }
    
    // MARK: Private
    public func notifyCardViewElementsFinishedLayout(){
        var cardViews:[CardViewElement?] = [header, body, footer, back]
        for view in cardViews{
            view?.cardViewFinishedLayout()
        }
    }
    
    private func calculateCurrentSize()->CGSize{
        var height:CGFloat = 0.0
        
        if(headerHeight != nil){
            height += headerHeight!
        }
        
        height += bodyHeight
        
        if(footerHeight != nil){
            height += footerHeight!
        }
        
        return CGSizeMake(width, height)
    }
    
    private func initializeCardComponents()->Bool{
        header = visualSource.viewForCardHeader?()
        body = visualSource.viewForCardBody()
        footer = visualSource.viewForCardFooter?()
        
        // initialize and update before height calculations
        body.cardView = self
        body.update()
        header?.cardView = self
        header?.update()
        footer?.cardView = self
        footer?.update()
        
        // validity checks
        headerHeight = visualSource.heightForCardHeader?()
        bodyHeight = visualSource.heightForCardBody()
        footerHeight = visualSource.heightForCardFooter?()
        width = visualSource.widthForCard()
        
        if(width <= 0){
            println("Visual source width must be greater than 0.")
            return false
        }
        
        if(bodyHeight <= 0){
            println("Visual source body height must be greater than 0.")
            return false
        }
        
        if(header != nil){
            if(headerHeight == nil){
                println("Visual source defines a header but header height is nil.")
                return false
            }else{
                if(headerHeight <= 0){
                    println("Visual source header height must be greater than 0.")
                    return false
                }
            }
        }
        
        if(footer != nil){
            if(footerHeight == nil){
                println("Visual source defines a footer but footer height is nil.")
                return false
            }else{
                if(footerHeight <= 0){
                    println("Visual source footer height must be greater than 0.")
                    return false
                }
            }
        }
        return true
    }
    
    private func layoutCardComponents()->Bool{
        // header and footer always stick to top and bottom
        if(header != nil){
            containerView.addSubview(header!)
            header!.constrainLeftToSuperView(0)
            header!.constrainRightToSuperView(0)
            header!.constrainTopToSuperView(0)
            header!.constrainHeight(headerHeight!)
        }
        
        if(footer != nil){
            containerView.addSubview(footer!)
            footer!.constrainLeftToSuperView(0)
            footer!.constrainRightToSuperView(0)
            footer!.constrainBottomToSuperView(0)
            footer!.constrainHeight(footerHeight!)
        }
        
        containerView.addSubview(body)
        body.constrainLeftToSuperView(0)
        body.constrainRightToSuperView(0)
        
        // card body layout has 4 height layout possibilities
        if(header == nil && footer == nil){
            body.constrainToSuperViewEdges()
        }else if(header != nil && footer == nil){
            containerView.addConstraint(NSLayoutConstraint(item: body, attribute: .Top, relatedBy: .Equal, toItem: header!, attribute: .Bottom, multiplier: 1.0, constant: 0))
            containerView.addConstraint(NSLayoutConstraint(item: body, attribute: .Bottom, relatedBy: .Equal, toItem: containerView, attribute: .Bottom, multiplier: 1.0, constant: 0))
        }else if(header == nil && footer != nil){
            containerView.addConstraint(NSLayoutConstraint(item: body, attribute: .Top, relatedBy: .Equal, toItem: containerView, attribute: .Top, multiplier: 1.0, constant: 0))
            containerView.addConstraint(NSLayoutConstraint(item: body, attribute: .Bottom, relatedBy: .Equal, toItem: footer!, attribute: .Top, multiplier: 1.0, constant: 0))
        }else{
            containerView.addConstraint(NSLayoutConstraint(item: body, attribute: .Top, relatedBy: .Equal, toItem: header!, attribute: .Bottom, multiplier: 1.0, constant: 0))
            containerView.addConstraint(NSLayoutConstraint(item: body, attribute: .Bottom, relatedBy: .Equal, toItem: footer!, attribute: .Top, multiplier: 1.0, constant: 0))
        }
        
        
        // Back of the card always constrain to edges if it exists
        if let backView = visualSource.viewForBackOfCard?(){
            backView.cardView = self
            backView.update()
            insertSubview(backView, belowSubview:containerView)
            backView.constrainToSuperViewEdges()
            backView.layer.cornerRadius = WildcardSDK.cardCornerRadius
            backView.layer.masksToBounds = true
            back = backView
        }
        
        return true
    }
    
    private func convenienceInitialize(){
        
        backgroundColor = UIColor.clearColor()
        
        // always have a white container view holder card elements
        containerView = UIView(frame: CGRectZero)
        containerView.backgroundColor = UIColor.whiteColor()
        containerView.layer.cornerRadius = WildcardSDK.cardCornerRadius
        containerView.layer.masksToBounds = true
        addSubview(containerView)
        containerView.constrainToSuperViewEdges()
        
        // drop shadow goes on actual card layer
        layer.shadowColor = UIColor.wildcardMediumGray().CGColor
        layer.shadowOpacity = 0.8
        layer.shadowOffset = CGSizeMake(0.0, 1.0)
        layer.shadowRadius = 1.0
        
        physics = CardPhysics(cardView:self)
        physics?.setup()
    }
    
    private func removeCardSubviews(){
        var cardViews:[UIView?] = [header, body, footer, back]
        for view in cardViews{
            view?.removeFromSuperview()
        }
    }
}