//
//  UIView+Contraints.swift
//  ConstraintLib
//
//  Created by info@stefanrenne.nl on 17/06/16.
//  Copyright © 2016. All rights reserved.
//

import UIKit

/**
 * This enum represents all current options for adding constraints
 * .left, .right, .bottom, .top, .centerX, .centerY are relations to the views superview
 * .width, .height are relations to the view itself
 * .leftTo(UIView), .rightTo(UIView), .bottomTo(UIView), .topTo(UIView), .equalWidth(UIView), .equalHeight(UIView) are relations from one view to another views
 */
public enum PinEdge: Hashable {
    
    /// leading (left) relation to the views superview
    case left
    
    /// trailing (right) relation to the views superview
    case right
    
    /// bottom relation to the views superview
    case bottom
    
    /// top relation to the views superview
    case top
    
    /// center x relation to the views superview
    case centerX
    
    /// center y relation to the views superview
    case centerY
    
    /// width relation for the view
    case width
    
    /// height relation for the view
    case height
    
    /// pin the left side of the view to the right side of the (in the enum) provided UIView
    case leftTo(UIView)
    
    /// pin the right side of the view to the left side of the (in the enum) provided UIView
    case rightTo(UIView)
    
    /// pin the bottom side of the view to the top side of the (in the enum) provided UIView
    case bottomTo(UIView)
    
    /// pin the top side of the view to the bottom side of the (in the enum) provided UIView
    case topTo(UIView)
    
    /// pin the width of the view to the width of the (in the enum) provided UIView
    case equalWidth(UIView)
    
    /// pin the height of the view to the height of the (in the enum) provided UIView
    case equalHeight(UIView)
    
    /// top relation to the views layoutGuide
    case topLayoutGuide
    
    /// bottom relation to the views layoutGuide
    case bottomLayoutGuide
    
    /**
     * Compare two PinEdge's
     *
     * - Parameter lhs: first PinEdge
     * - Parameter rhs: first PinEdge
     * - Returns: Boolean
     */
    public static func ==(lhs: PinEdge, rhs: PinEdge) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    /**
     * Unique value for a PinEdge, mainly used for comparising
     *
     * - Returns: Int
     */
    public var hashValue: Int {
        switch self {
        case .left:
            return 1
        case .right:
            return 2
        case .bottom:
            return 3
        case .top:
            return 4
        case .centerX:
            return 5
        case .centerY:
            return 6
        case .width:
            return 7
        case .height:
            return 8
        case .leftTo:
            return 9
        case .rightTo:
            return 10
        case .bottomTo:
            return 11
        case .topTo:
            return 12
        case .equalWidth:
            return 13
        case .equalHeight:
            return 14
        case .topLayoutGuide:
            return 15
        case .bottomLayoutGuide:
            return 16
        }
    }
    
    fileprivate var startAttribute: [NSLayoutAttribute] {
        switch self {
        case .left, .leftTo:
            return [.leading, .left]
        case .right, .rightTo:
            return [.trailing, .right]
        case .bottom, .bottomTo, .bottomLayoutGuide:
            return [.bottom]
        case .top, .topTo, .topLayoutGuide:
            return [.top]
        case .centerX:
            return [.centerX]
        case .centerY:
            return [.centerY]
        case .width, .equalWidth:
            return [.width]
        case .height, .equalHeight:
            return [.height]
        }
    }
    
    fileprivate var endAttribute: [NSLayoutAttribute] {
        switch self {
        case .left, .rightTo:
            return [.leading, .left]
        case .right, .leftTo:
            return [.trailing, .right]
        case .bottom, .topTo, .topLayoutGuide:
            return [.bottom]
        case .top, .bottomTo, .bottomLayoutGuide:
            return [.top]
        case .centerX:
            return [.centerX]
        case .centerY:
            return [.centerY]
        case .width, .height:
            return [.notAnAttribute]
        case .equalWidth:
            return [.width]
        case .equalHeight:
            return [.height]
        }
    }
    
    fileprivate func defaultConstantFor(view: UIView) -> Float {
        switch self {
        case .left:
            return Float(view.frame.origin.x)
        case .right:
            return -Float(-(view.superview!.frame.width-(view.frame.width+view.frame.origin.x)))
        case .top:
            return Float(view.frame.origin.y)
        case .bottom:
            return Float(view.superview!.frame.height-(view.frame.height+view.frame.origin.y))
        case .width:
            return Float(view.frame.width)
        case .height:
            return Float(view.frame.height)
        default:
            return 0.0
        }
    }
    
    fileprivate func endItem(startView: UIView) -> AnyObject? {
        switch self {
            case .left, .right, .bottom, .top, .centerX, .centerY:
                return startView.superview
            case .leftTo(let endItem), .rightTo(let endItem), .bottomTo(let endItem), .topTo(let endItem):
                return endItem
            case .bottomLayoutGuide:
                return startView.parentViewController?.bottomLayoutGuide
            case .topLayoutGuide:
                return startView.parentViewController?.topLayoutGuide
            default:
                return nil
        }
        
    }
    
    fileprivate var flippedConstant: Bool {
        switch self {
        case .right, .bottom, .bottomTo, .rightTo, .bottomLayoutGuide:
            return true
        default:
            return false
        }
    }
    
    fileprivate func createConstraint(startView: UIView, constant: Float, multiplier: Float = 1.0) -> NSLayoutConstraint {
        let endItem = self.endItem(startView: startView)
        
        if endItem != nil && flippedConstant {
            /* Flip Contraint when the endItem is out of bound */
            return NSLayoutConstraint(item: endItem!, attribute: endAttribute.first!, relatedBy: .equal, toItem: startView, attribute: startAttribute.first!, multiplier: CGFloat(multiplier), constant: CGFloat(constant))
        } else {
            return NSLayoutConstraint(item: startView, attribute: startAttribute.first!, relatedBy: .equal, toItem: endItem, attribute: endAttribute.first!, multiplier: CGFloat(multiplier), constant: CGFloat(constant))
        }
    }
    
    
}

extension UIView {
    internal var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            guard let newResponder = parentResponder?.next else {
                break
            }
            if let viewController = newResponder as? UIViewController {
                return viewController
            }
            parentResponder = newResponder
        }
        return nil
    }
}

/* Add Constraints */
public extension UIView {
    
    /**
     * Add multiple NSLayoutConstraints to a view, provided in an array.
     * The NSLayoutConstraints value's are calculated from the views frame.
     * Make sure the view is first added to a superview.
     *
     * - Parameter edges: [PinEdge], Array of PinEdge's. Take a look at PinEdge for all options
     */
    public func pin(_ edges: [PinEdge]) {
        edges.forEach { (edge) in
            let _ = pin(edge)
        }
    }
    
    /**
     * Add multiple NSLayoutConstraints to a view, provided in an dictionary.
     * If the provided value is Nil, then the NSLayoutConstraints value will be calculated from the views frame.
     * Make sure the view is first added to a superview.
     *
     * - Parameter edges: [PinEdge:Float?], Dicionary of PinEdge's and constant values. Take a look at PinEdge for all options
     */
    public func pin(_ edges: [PinEdge:Float?]) {
        edges.forEach { (edge, constant) in
            let _ = pin(edge, constant: constant)
        }
    }
    
    /**
     * Add a NSLayoutConstraint to a view.
     * Make sure the view is first added to a superview.
     *
     * - Parameter edge: PinEdge, Take a look at PinEdge for all options
     * - Parameter constant: Float?, The amount of spacing in pixels that will be used by the Constrant. If the provided value is Nil, then the NSLayoutConstraints value will be calculated from the views frame
     * - Parameter multiplier: Float, modify the default constraint multiplier
     * - Returns: The created NSLayoutConstraint
     */
    public func pin(_ edge: PinEdge, constant: Float? = nil, multiplier: Float = 1.0) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = edge.createConstraint(startView: self, constant: constant ?? edge.defaultConstantFor(view: self), multiplier: multiplier)
        
        if constraint.secondItem == nil {
            self.addConstraint(constraint)
        } else {
            self.superview?.addConstraint(constraint)
        }
        
        return constraint
    }
    
}

/* Find Constraints */
public extension UIView {
    
    /**
     * Find a NSLayoutConstraint for a UIView (or a subclass of UIView)
     *
     * - Parameter edge: PinEdge, Take a look at PinEdge enum for all options
     */
    public func constraint(_ edge: PinEdge) -> NSLayoutConstraint? {
        let attributes = edge.startAttribute
        let endItem = edge.endItem(startView: self)
        let matches = attributes.flatMap(searchConstaint(endItem: endItem))
        return matches.first
    }
    
    fileprivate func searchConstaint(endItem: AnyObject?) -> ((NSLayoutAttribute) -> (NSLayoutConstraint?)) {
        return { attribute in
            let constraints = (attribute == .width || attribute == .height) ? self.constraints : self.superview?.constraints
            return constraints?.filter(self.isConstraintWith(attribute: attribute, endItem: endItem)).first
        }
    }
    
    fileprivate func isConstraintWith(attribute: NSLayoutAttribute, endItem: AnyObject?) -> ((NSLayoutConstraint) -> (Bool)) {
        return { constraint in
            
            guard constraint.relation == .equal else {
                return false
            }
            
            /* Default case validation - UIView */
            if let firstItem = constraint.firstItem as? UIView, firstItem == self && constraint.firstAttribute == attribute {
                if let secondItem = constraint.secondItem as? UIView, secondItem == endItem as? UIView {
                    return true
                } else if endItem == nil, constraint.secondItem == nil {
                    return true
                }
            }
            
            /* Flipped case validation */
            if let firstItem = constraint.firstItem as? UIView, let secondItem = constraint.secondItem as? UIView, firstItem == endItem as? UIView && constraint.secondAttribute == attribute && secondItem == self {
                return true
            }
            
            return false
        }
    }
    
}

/* Animate Constraints, perform on a parent view */
public extension UIViewController {
    /**
     * Perform NSLayoutConstraint changes with a animation
     *
     * - Parameter duration: TimeInterval, The duration of the animation
     * - Parameter constraints: Void completion block in which NSLayoutConstraint constant changes need to be performed
     * - Parameter animations: (Optional) Void completion block in which non NSLayoutConstraint changes need to be performed
     * - Parameter completion: (Optional) Bool completion block which gets performed after the animation
     */
    public func animateConstraints(duration: TimeInterval, constraints: () -> Void, animations: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
        self.view.animateConstraints(duration: duration, constraints: constraints, animations: animations, completion: completion)
    }
}

public extension UIView {
    
    /**
     * Perform NSLayoutConstraint changes with a animation, perform this call on the highest UIView or use the extension on UIViewController
     *
     * - Parameter duration: TimeInterval, The duration of the animation
     * - Parameter constraints: Void completion block in which NSLayoutConstraint constant changes need to be performed
     * - Parameter animations: (Optional) Void completion block in which non NSLayoutConstraint changes need to be performed
     * - Parameter completion: (Optional) Bool completion block which gets performed after the animation
     */
    public func animateConstraints(duration: TimeInterval, constraints: () -> Void, animations: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
        constraints()
        self.setNeedsLayout()
        UIView.animate(withDuration: duration, animations: { 
            self.layoutIfNeeded()
            animations?()
            }, completion: completion)
    }
    
}

public extension NSLayoutConstraint {
    
    /**
     * Remove a NSLayoutConstraint from the managing view.
     */
    public func remove() {
        if let secondItem = self.secondItem {
            secondItem.removeConstraint(self)
        } else {
            self.firstItem.removeConstraint(self)
        }
    }
    
}
