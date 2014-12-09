//
//  CardViewRenderer.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/8/14.
//
//

import Foundation
import UIKit

public class CardViewRenderer
{
    // Renders a CardView from a Card if possible. 
    // If layout is nil, a layout will be automatically chosen from the CardLayoutEngine
    public class func renderViewFromCard(card:Card, layout:CardLayout?)->CardView?{
        
        var layoutToUse = layout
        if layoutToUse == nil{
            layoutToUse = CardLayoutEngine.sharedInstance.matchLayout(card)
        }
        
        var newCardView = CardView(frame: CGRectZero)
        if let cardContentView = CardViewRenderer.generateContentViewFromLayout(layoutToUse!, cardView:newCardView){
            // initialize card content view
            newCardView.initializeContentView(cardContentView)
            
            // upate content for card
            cardContentView.updateViewForCard(card)
            
            // apply best fit bounds
            
            return newCardView
        }else{
            return nil
        }
    }
    
    class func generateContentViewFromLayout(layout:CardLayout,cardView:CardView)->CardContentView?{
        switch(layout){
            
        case .BareCard:
            return CardContentView.loadFromNibNamed("BareCard")
        default:
            return nil
        }
    }
    
}