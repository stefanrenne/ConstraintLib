//
//  ConstraintLibTests.swift
//  ConstraintLibTests
//
//  Created by info@stefanrenne.nl on 30/03/2017.
//  Copyright © 2017. All rights reserved.
//

import XCTest
@testable import ConstraintLib

class ConstraintLibTests: XCTestCase {
    
    func testItCanGetTheHashValue() {
        
        XCTAssertEqual(PinEdge.left.hashValue, 1)
        XCTAssertEqual(PinEdge.right.hashValue, 2)
        XCTAssertEqual(PinEdge.bottom.hashValue, 3)
        XCTAssertEqual(PinEdge.top.hashValue, 4)
        XCTAssertEqual(PinEdge.centerX.hashValue, 5)
        XCTAssertEqual(PinEdge.centerY.hashValue, 6)
        XCTAssertEqual(PinEdge.width.hashValue, 7)
        XCTAssertEqual(PinEdge.height.hashValue, 8)
        XCTAssertEqual(PinEdge.leftTo(UIView()).hashValue, 9)
        XCTAssertEqual(PinEdge.rightTo(UIView()).hashValue, 10)
        XCTAssertEqual(PinEdge.bottomTo(UIView()).hashValue, 11)
        XCTAssertEqual(PinEdge.topTo(UIView()).hashValue, 12)
        XCTAssertEqual(PinEdge.equalWidth(UIView()).hashValue, 13)
        XCTAssertEqual(PinEdge.equalHeight(UIView()).hashValue, 14)
        XCTAssertEqual(PinEdge.topLayoutGuide.hashValue, 15)
        XCTAssertEqual(PinEdge.bottomLayoutGuide.hashValue, 16)
        
        XCTAssertEqual(PinEdge.left, PinEdge.left)
        XCTAssertNotEqual(PinEdge.left, PinEdge.right)
    }
    
    func testItCanCreateEdgeConstraintsFromRect() {
        
        let viewcontroller = UIViewController()
        viewcontroller.view.frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 480.0)
        
        let newView = UIView(frame: CGRect(x: 50.0, y: 50.0, width: 100.0, height: 100.0))
        viewcontroller.view.addSubview(newView)
        let topConstraint = newView.pin(.top)
        let leftConstraint = newView.pin(.left)
        let bottomConstraint = newView.pin(.bottom)
        let rightConstraint = newView.pin(.right)
        
        /* Validated created constraints */
        XCTAssertEqual(topConstraint.constant, 50.0)
        XCTAssertEqual(leftConstraint.constant, 50.0)
        XCTAssertEqual(bottomConstraint.constant, 330.0)
        XCTAssertEqual(rightConstraint.constant, 170.0)
        
        /* Find Constraints in tree */
        XCTAssertEqual(topConstraint, newView.constraint(.top))
        XCTAssertEqual(leftConstraint, newView.constraint(.left))
        XCTAssertEqual(bottomConstraint, newView.constraint(.bottom))
        XCTAssertEqual(rightConstraint, newView.constraint(.right))
        
    }
    
    func testItCanCreatePositionConstraintsFromRect() {
        
        let viewcontroller = UIViewController()
        viewcontroller.view.frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 480.0)
        
        let newView = UIView(frame: CGRect(x: 110.0, y: 140.0, width: 100.0, height: 100.0))
        viewcontroller.view.addSubview(newView)
        let widthConstraint = newView.pin(.width)
        let heightConstraint = newView.pin(.height)
        let centerXConstraint = newView.pin(.centerX)
        let centerYConstraint = newView.pin(.centerY)
        
        /* Validated created constraints */
        XCTAssertEqual(widthConstraint.constant, 100.0)
        XCTAssertEqual(heightConstraint.constant, 100.0)
        XCTAssertEqual(centerXConstraint.constant, 0.0)
        XCTAssertEqual(centerYConstraint.constant, 0.0)
        
        /* Find Constraints in tree */
        XCTAssertEqual(widthConstraint, newView.constraint(.width))
        XCTAssertEqual(heightConstraint, newView.constraint(.height))
        XCTAssertEqual(centerXConstraint, newView.constraint(.centerX))
        XCTAssertEqual(centerYConstraint, newView.constraint(.centerY))
        
    }
    
    func testItCanStickViewsToOtherViews() {
        
        let viewcontroller = UIViewController()
        viewcontroller.view.frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 480.0)
        
        let newView1 = UIView(frame: CGRect(x: 50.0, y: 50.0, width: 200.0, height: 200.0))
        viewcontroller.view.addSubview(newView1)
        newView1.pin([.left, .top, .width, .height])
        
        XCTAssertEqual(newView1.constraint(.left)?.constant, 50.0)
        XCTAssertEqual(newView1.constraint(.top)?.constant, 50.0)
        XCTAssertEqual(newView1.constraint(.width)?.constant, 200.0)
        XCTAssertEqual(newView1.constraint(.height)?.constant, 200.0)
        
        let newView2 = UIView(frame: CGRect(x: 100.0, y: 100.0, width: 100.0, height: 100.0))
        viewcontroller.view.addSubview(newView2)
        
        let leftConstraint1 = newView2.pin(.leftTo(newView1))
        let topConstraint1 = newView2.pin(.topTo(newView1))
        let rightConstraint1 = newView2.pin(.rightTo(newView1))
        let bottomConstraint1 = newView2.pin(.bottomTo(newView1))
        
        /* Validated created constraints */
        XCTAssertEqual(leftConstraint1.constant, 0.0)
        XCTAssertEqual(topConstraint1.constant, 0.0)
        XCTAssertEqual(rightConstraint1.constant, 0.0)
        XCTAssertEqual(bottomConstraint1.constant, 0.0)
        
        /* Find Constraints in tree */
        XCTAssertEqual(leftConstraint1, newView2.constraint(.leftTo(newView1)))
        XCTAssertEqual(topConstraint1, newView2.constraint(.topTo(newView1)))
        XCTAssertEqual(rightConstraint1, newView2.constraint(.rightTo(newView1)))
        XCTAssertEqual(bottomConstraint1, newView2.constraint(.bottomTo(newView1)))
        
    }
    
    func testItCanFindConstraintsFromTheOtherView() {
        
        let viewcontroller = UIViewController()
        viewcontroller.view.frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 480.0)
        
        let newView1 = UIView(frame: CGRect(x: 50.0, y: 50.0, width: 200.0, height: 200.0))
        viewcontroller.view.addSubview(newView1)
        newView1.pin([.left, .top, .width, .height])
        
        let newView2 = UIView(frame: CGRect(x: 100.0, y: 100.0, width: 100.0, height: 100.0))
        viewcontroller.view.addSubview(newView2)
        
        let leftConstraint1 = newView2.pin(.leftTo(newView1))
        let topConstraint1 = newView2.pin(.topTo(newView1))
        let rightConstraint1 = newView2.pin(.rightTo(newView1))
        let bottomConstraint1 = newView2.pin(.bottomTo(newView1))
        
        let newView3 = UIView(frame: CGRect(x: 100.0, y: 100.0, width: 100.0, height: 100.0))
        viewcontroller.view.addSubview(newView3)
        
        let leftConstraint2 = newView3.pin(.leftTo(newView1))
        let topConstraint2 = newView3.pin(.topTo(newView1))
        let rightConstraint2 = newView3.pin(.rightTo(newView1))
        let bottomConstraint2 = newView3.pin(.bottomTo(newView1))
        
        
        /* Find Constraints in tree */
        XCTAssertEqual(leftConstraint1, newView1.constraint(.rightTo(newView2)))
        XCTAssertEqual(topConstraint1, newView1.constraint(.bottomTo(newView2)))
        XCTAssertEqual(rightConstraint1, newView1.constraint(.leftTo(newView2)))
        XCTAssertEqual(bottomConstraint1, newView1.constraint(.topTo(newView2)))
        
        XCTAssertEqual(leftConstraint2, newView1.constraint(.rightTo(newView3)))
        XCTAssertEqual(topConstraint2, newView1.constraint(.bottomTo(newView3)))
        XCTAssertEqual(rightConstraint2, newView1.constraint(.leftTo(newView3)))
        XCTAssertEqual(bottomConstraint2, newView1.constraint(.topTo(newView3)))
    }
    
    func testItCanPinWidthAndHightToOtherViews() {
        
        let viewcontroller = UIViewController()
        viewcontroller.view.frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 480.0)
        
        let newView1 = UIView()
        viewcontroller.view.addSubview(newView1)
        newView1.pin([.left:50.0, .top:50.0, .width:100.0, .height:100.0])
        
        let newView2 = UIView()
        viewcontroller.view.addSubview(newView2)
        let leftConstraint = newView2.pin(.left, constant: 50.0)
        let topConstraint = newView2.pin(.top, constant: 50.0)
        let equalWidthConstraint = newView2.pin(.equalWidth(newView1))
        let equalHeightConstraint = newView2.pin(.equalHeight(newView1))
        
        /* Validated created constraints */
        XCTAssertEqual(leftConstraint.constant, 50.0)
        XCTAssertEqual(topConstraint.constant, 50.0)
        XCTAssertEqual(equalWidthConstraint.constant, 0.0)
        XCTAssertEqual(equalHeightConstraint.constant, 0.0)
        
        /* Find Constraints in tree */
        XCTAssertEqual(leftConstraint, newView2.constraint(.left))
        XCTAssertEqual(topConstraint, newView2.constraint(.top))
        XCTAssertEqual(equalWidthConstraint, newView2.constraint(.equalWidth(newView1)))
        XCTAssertEqual(equalHeightConstraint, newView2.constraint(.equalHeight(newView1)))
    }
    
    func testItCanRemoveConstraints() {
        
        let viewcontroller = UIViewController()
        viewcontroller.view.frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 480.0)
        
        let newView = UIView(frame: CGRect(x: 50.0, y: 50.0, width: 100.0, height: 100.0))
        viewcontroller.view.addSubview(newView)
        let topConstraint = newView.pin(.top)
        let leftConstraint = newView.pin(.left)
        let bottomConstraint = newView.pin(.bottom)
        let rightConstraint = newView.pin(.right)
        
        /* Find Constraints in tree */
        XCTAssertEqual(topConstraint, newView.constraint(.top))
        XCTAssertEqual(leftConstraint, newView.constraint(.left))
        XCTAssertEqual(bottomConstraint, newView.constraint(.bottom))
        XCTAssertEqual(rightConstraint, newView.constraint(.right))
        
        leftConstraint.remove()
        
        /* Find Constraints in tree */
        XCTAssertEqual(topConstraint, newView.constraint(.top))
        XCTAssertNil(newView.constraint(.left))
        XCTAssertEqual(bottomConstraint, newView.constraint(.bottom))
        XCTAssertEqual(rightConstraint, newView.constraint(.right))
    }
    
    func testItCantFindTheParentViewControllerFromAnUnassignedView() {
        let newView = UIView(frame: CGRect(x: 50.0, y: 50.0, width: 100.0, height: 100.0))
        XCTAssertNil(newView.parentViewController)
    }
    
    func testItCanFindTheParentViewController() {
        
        let viewcontroller = UIViewController()
        viewcontroller.view.frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 480.0)
        
        let newView = UIView(frame: CGRect(x: 50.0, y: 50.0, width: 100.0, height: 100.0))
        viewcontroller.view.addSubview(newView)
        
        XCTAssertEqual(newView.parentViewController, viewcontroller)
    }
    
    func testItCanPinAViewToTheLayoutGuides() {
        if #available(iOS 9.0, *) {
            let viewcontroller = UIViewController()
            viewcontroller.view.frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 480.0)
            
            let newView = UIView()
            viewcontroller.view.addSubview(newView)
            
            let topConstraint = newView.pin(.topLayoutGuide, constant: 2.0)
            let _ = newView.pin(.left, constant: 0.0)
            let bottomConstraint = newView.pin(.bottomLayoutGuide, constant: 4.0)
            let _ = newView.pin(.right, constant: 0.0)
            
            /* Validated created constraints */
            XCTAssertEqual(topConstraint.constant, 2.0)
            XCTAssertEqual(bottomConstraint.constant, 4.0)
            
            XCTAssertEqual(topConstraint.firstItem as? UIView, newView)
            XCTAssertEqual((topConstraint.secondItem as! UILayoutGuide).owningView, viewcontroller.view)
            
            XCTAssertEqual((bottomConstraint.firstItem as! UILayoutGuide).owningView, viewcontroller.view)
            XCTAssertEqual(bottomConstraint.secondItem as? UIView, newView)
        }
    }
    
    func testItCanCreateAMulitplierConstraint() {
        
        let viewcontroller = UIViewController()
        viewcontroller.view.frame = CGRect(x: 0.0, y: 0.0, width: 320.0, height: 480.0)
        
        let newView = UIView(frame: CGRect(x: 50.0, y: 50.0, width: 100.0, height: 100.0))
        viewcontroller.view.addSubview(newView)
        let topConstraint = newView.pin(.top)
        let leftConstraint = newView.pin(.left, multiplier: 1.0)
        let bottomConstraint = newView.pin(.bottom, multiplier: 2.0)
        let rightConstraint = newView.pin(.right, multiplier: 3.0)
        
        /* Find Constraints in tree */
        XCTAssertEqual(topConstraint.multiplier, 1.0)
        XCTAssertEqual(topConstraint.multiplier, newView.constraint(.top)?.multiplier)
        XCTAssertEqual(leftConstraint.multiplier, 1.0)
        XCTAssertEqual(leftConstraint.multiplier, newView.constraint(.left)?.multiplier)
        XCTAssertEqual(bottomConstraint.multiplier, 2.0)
        XCTAssertEqual(bottomConstraint.multiplier, newView.constraint(.bottom)?.multiplier)
        XCTAssertEqual(rightConstraint.multiplier, 3.0)
        XCTAssertEqual(rightConstraint.multiplier, newView.constraint(.right)?.multiplier)
    }
    
}
