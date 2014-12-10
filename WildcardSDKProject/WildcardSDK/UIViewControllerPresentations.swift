//
//  UIViewControllerPresentations.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/9/14.
//
//

import Foundation

public extension UIViewController{
    
    public func presentCard(card:Card){
        let modalViewController = ModalCardViewController()
        
        let snapShot:UIView = view.snapshotViewAfterScreenUpdates(false)
        modalViewController.view.insertSubview(snapShot, atIndex:0)
        
        modalViewController.presentingControllBackgroundView = snapShot
        modalViewController.blurredOverlayView = snapShot.addBlurOverlay(UIBlurEffectStyle.Dark)
        modalViewController.blurredOverlayView!.alpha = 0
        modalViewController.presentedCard = card
        modalViewController.cardView = CardViewRenderer.renderViewFromCard(card)
        
        presentViewController(modalViewController, animated: false, completion: nil)
    }
}