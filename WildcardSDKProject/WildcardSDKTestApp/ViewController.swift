//
//  ViewController.swift
//  WildcardSDKTestApp
//
//  Created by David Xiang on 12/2/14.
//
//

import UIKit
import WildcardSDK

class ViewController: UIViewController, CardViewDelegate{
    
    var card:SummaryCard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let media:NSMutableDictionary = NSMutableDictionary()
        media["imageUrl"] = "http://netdna.webdesignerdepot.com/uploads/2013/02/featured35@wdd2x.jpg"
        media["type"] = "image"
        
        
        let google = NSURL(string: "http://www.yahoo.com")
        card = SummaryCard(url:google!, description: "Yahoo is a veteran of the Internet. They recently spinned off a company called SpinCo to avoid paying billions of dollars in taxes for their stake in Alibaba.", title: "Yahoo Spinning Off SpinCo", media:media, data:nil)
        
        view.backgroundColor = UIColor.wildcardBackgroundGray()
        
        if let newCardView = CardView.createCardView(card, layout: WCCardLayout.SummaryCardNoImage){
            newCardView.delegate = self
            view.addSubview(newCardView)
            newCardView.horizontallyCenterToSuperView(0)
            newCardView.verticallyCenterToSuperView(-50)
            newCardView.constrainWidth(newCardView.frame.size.width,height:newCardView.frame.size.height)
        }
    }
    
    func cardViewRequestedAction(cardView: CardView, action: CardViewAction) {
        handleCardAction(cardView, action: action)
    }
    
    @IBAction func firstButtonTapped(sender: AnyObject) {
        presentCard(card!, layout:WCCardLayout.SummaryCardTall, animated:true, completion:nil)
        presentCard(card, animated: true, completion: nil)
    }
  
    @IBAction func presentCardButtonTapped(sender: AnyObject) {
        let google = NSURL(string: "http://www.google.com")
        let noImage = SummaryCard(url:google!, description: "The quick brown fox jumped over the lazy dog. The quick brown fox jumped over the lazy dog.The quick brown fox jumped over the lazy dog. The quick brown fox jumped over the lazy dog.er the lazy dog.er the lazy dog.", title: "The Card Title -- Cards! Oh Yea!", media:nil, data:nil)
        presentCard(noImage, layout: .SummaryCardNoImage, animated:true, completion:nil)
    }
    
    @IBAction func secondButtonTapped(sender: AnyObject) {
        presentCard(card!, layout:.SummaryCardShort, animated:true, completion:nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

