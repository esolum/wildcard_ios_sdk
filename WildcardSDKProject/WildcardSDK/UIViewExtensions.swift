//
//  Extensions.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 12/8/14.
//
//

import Foundation

extension UIView{
    // for any view with a superview, constrain all edges flush with superview
    func constrainToSuperViewEdges(){
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        superview?.addConstraint(NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.superview, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        superview?.addConstraint(NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.superview, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        superview?.addConstraint(NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.superview, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0.0))
        superview?.addConstraint(NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self.superview, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0))
        self.superview?.layoutIfNeeded()
    }
    
    func verticallyConstrainToSuperView(offset:CGFloat)->NSLayoutConstraint {
        setTranslatesAutoresizingMaskIntoConstraints(false)
        let yConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: offset)
        superview!.addConstraint(yConstraint)
        return yConstraint
    }
    
    func horizontallyConstrainToSuperView(offset:CGFloat)->NSLayoutConstraint {
        setTranslatesAutoresizingMaskIntoConstraints(false)
        let xConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: offset)
        superview!.addConstraint(xConstraint)
        return xConstraint
    }
    
    func constrainWidth(width:CGFloat, andHeight:CGFloat){
        setTranslatesAutoresizingMaskIntoConstraints(false)
        addConstraint(NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: width))
        addConstraint(NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: andHeight))
        superview?.layoutIfNeeded()
    }
    
    // adds a blur overlay to the view and returns a reference to it.
    func addBlurOverlay(style:UIBlurEffectStyle)->UIView{
        let overlay = UIView(frame: CGRectZero)
        addSubview(overlay)
        overlay.constrainToSuperViewEdges()
        
        let visualEffect = UIVisualEffectView(effect: UIBlurEffect(style:style)) as UIVisualEffectView
        overlay.addSubview(visualEffect)
        visualEffect.constrainToSuperViewEdges()
        
        return overlay
    }
    
    func hasSuperview()->Bool{
        return superview != nil
    }
    
    func parentViewController() -> UIViewController? {
        var parentResponder: UIResponder? = self
        while true {
            if parentResponder == nil {
                return nil
            }
            parentResponder = parentResponder!.nextResponder()
            if parentResponder is UIViewController {
                return (parentResponder as UIViewController)
            }
        }
    }
  
}