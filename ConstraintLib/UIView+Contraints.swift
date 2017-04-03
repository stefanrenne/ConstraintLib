//
//  UIView+Contraints.swift
//  ConstraintLib
//
//  Created by info@stefanrenne.nl on 17/06/16.
//  Copyright © 2016. All rights reserved.
//

import UIKit


public enum PinEdge: Hashable {
    
    /* Relation to superview */
    case left, right, bottom, top, centerX, centerY
    
    /* Views own relation */
    case width, height
    
    /* Relation to other view */
    case leftTo(UIView), rightTo(UIView), bottomTo(UIView), topTo(UIView), equalWidth(UIView), equalHeight(UIView)
    
    public static func ==(lhs: PinEdge, rhs: PinEdge) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
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
        }
    }
    
    fileprivate var startAttribute: [NSLayoutAttribute] {
        switch self {
        case .left, .leftTo:
            return [.leading, .left]
        case .right, .rightTo:
            return [.trailing, .right]
        case .bottom, .bottomTo:
            return [.bottom]
        case .top, .topTo:
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
        case .bottom, .topTo:
            return [.bottom]
        case .top, .bottomTo:
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
    
    fileprivate func endItem(startView: UIView) -> UIView? {
        switch self {
            case .left, .right, .bottom, .top, .centerX, .centerY:
                return startView.superview
            case .leftTo(let endItem), .rightTo(let endItem), .bottomTo(let endItem), .topTo(let endItem):
                return endItem
            default:
                return nil
        }
        
    }
    
    var flippedConstant: Bool {
        switch self {
        case .right, .bottom, .bottomTo, .rightTo:
            return true
        default:
            return false
        }
    }
    
    fileprivate func createConstraint(startView: UIView, constant: Float) -> NSLayoutConstraint {
        let endItem = self.endItem(startView: startView)
        
        if endItem != nil && flippedConstant {
            /* Flip Contraint when the endItem is out of bound */
            return NSLayoutConstraint(item: endItem!, attribute: endAttribute.first!, relatedBy: .equal, toItem: startView, attribute: startAttribute.first!, multiplier: 1.0, constant: CGFloat(constant))
        } else {
            return NSLayoutConstraint(item: startView, attribute: startAttribute.first!, relatedBy: .equal, toItem: endItem, attribute: endAttribute.first!, multiplier: 1.0, constant: CGFloat(constant))
        }
    }
    
}

/* Add Constraints */
public extension UIView {
    
    public func pin(_ edges: [PinEdge]) {
        edges.forEach { (edge) in
            let _ = pin(edge)
        }
    }
    
    public func pin(_ edges: [PinEdge:Float?]) {
        edges.forEach { (edge, constant) in
            let _ = pin(edge, constant: constant)
        }
    }
    
    public func pin(_ edge: PinEdge, constant: Float? = nil) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = edge.createConstraint(startView: self, constant: constant ?? edge.defaultConstantFor(view: self))
        
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
    
    public func constraint(_ edge: PinEdge) -> NSLayoutConstraint? {
        let attributes = edge.startAttribute
        let endItem = edge.endItem(startView: self)
        let matches = attributes.flatMap(searchConstaint(endItem: endItem))
        return matches.first
    }
    
    fileprivate func searchConstaint(endItem: UIView?) -> ((NSLayoutAttribute) -> (NSLayoutConstraint?)) {
        return { attribute in
            let constraints = (attribute == .width || attribute == .height) ? self.constraints : self.superview?.constraints
            return constraints?.filter(self.isConstraintWith(attribute: attribute, endItem: endItem)).first
        }
    }
    
    fileprivate func isConstraintWith(attribute: NSLayoutAttribute, endItem: UIView?) -> ((NSLayoutConstraint) -> (Bool)) {
        return { constraint in
            
            guard constraint.relation == .equal else {
                return false
            }
            
            /* Default case validation */
            if let firstItem = constraint.firstItem as? UIView, firstItem == self && constraint.firstAttribute == attribute {
                if let secondItem = constraint.secondItem as? UIView, secondItem == endItem {
                    return true
                } else if endItem == nil, constraint.secondItem == nil {
                    return true
                }
            }
            
            /* Flipped case validation */
            if let firstItem = constraint.firstItem as? UIView, let secondItem = constraint.secondItem as? UIView, firstItem == endItem && constraint.secondAttribute == attribute && secondItem == self {
                return true
            }
            
            return false
        }
    }
    
}

/* Animate Constraints, perform on a parent view */
extension UIViewController {
    public func animateConstraints(duration: TimeInterval, constraints: () -> Void, animations: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
        self.view.animateConstraints(duration: duration, constraints: constraints, animations: animations, completion: completion)
    }
}
extension UIView {
    public func animateConstraints(duration: TimeInterval, constraints: () -> Void, animations: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
        constraints()
        self.setNeedsLayout()
        UIView.animate(withDuration: duration, animations: { 
            self.layoutIfNeeded()
            animations?()
            }, completion: completion)
    }
    
}

/* Easier way of removing constraints */
extension NSLayoutConstraint {
    public func remove() {
        if let secondItem = self.secondItem {
            secondItem.removeConstraint(self)
        } else {
            self.firstItem.removeConstraint(self)
        }
    }
    
}
