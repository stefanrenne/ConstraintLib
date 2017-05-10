//
//  ViewController.swift
//  ContraintLibDemo
//
//  Created by info@stefanrenne.nl on 30/03/2017.
//  Copyright © 2017. All rights reserved.
//

import UIKit
import ConstraintLib

class ViewController: UIViewController {
    
    var view1: UIView?
    var view2: UIView?
    var view3: UIView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /* Insert a view with relations to the top layout guide */
        let backgroundView = createView(backgroundColor: .gray, title: "Layout Guide View")
        backgroundView.pin([.topLayoutGuide: 0.0, .left: 0.0, .right: 0.0, .height: 20.0])
        
        /* Insert a view at the top left corner */
        let view1 = createView(rect: CGRect(x: 50.0, y: 50.0, width: 100.0, height: 100.0), backgroundColor: .red, title: "View 1")
        let _ = view1.pin(.top)
        let _ = view1.pin(.left)
        let _ = view1.pin(.height)
        let _ = view1.pin(.width)
        self.view1 = view1
        
        /* Insert a view that is always in the center of the screen */
        let view2 = createView(rect: CGRect(x: 50.0, y: 50.0, width: 200.0, height: 200.0), backgroundColor: .green, title: "View 2")
        let _ = view2.pin(.height)
        let _ = view2.pin(.width)
        let _ = view2.pin(.centerX)
        let _ = view2.pin(.centerY)
        self.view2 = view2
        
        
        /* Emty Views can also be positioned into the parentview */
        let view3 = createView(backgroundColor: .orange, title: "View 3")
        view3.pin([.bottom: 50.0, .right: 50.0, .height: 100.0, .width: 100.0])
        self.view3 = view3
        
        /* And Views can stick to other views */
        let view4 = createView(backgroundColor: .purple, title: "View 4")
        view4.pin([.left: 100.0, .right: 100.0, .height: 30.0, .topTo(view2): 30.0])
        
        let view5 = createView(backgroundColor: .purple, title: "View 5")
        view5.pin([.left: 100.0, .right: 100.0, .height: 30.0, .bottomTo(view2): 30.0])
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animationTik()
    }
    
    var animationPhase = 1
    func animationTik() {
        
        animationPhase = (animationPhase == 4) ? 1 : animationPhase + 1
        
        if let view1LeftContraint = view1?.constraint(.left),
            let view1WidthContraint = view1?.constraint(.width),
            let view2HeightContraint = view2?.constraint(.height),
            let view2WidthContraint = view2?.constraint(.width),
            let view3RightContraint = view3?.constraint(.right),
            let view3WidthContraint = view3?.constraint(.width) {
            
            animateConstraints(duration: 1.0, constraints: {
                
                /* Only contraint changes will be animated in this block */
                
                view1LeftContraint.constant = (animationPhase == 3) ? self.view.frame.width - 150.0 : 50.0
                view1WidthContraint.constant = (animationPhase == 2 || animationPhase == 4) ? self.view.frame.width - 100.0 : 100.0
                
                view2HeightContraint.constant = (animationPhase == 2 || animationPhase == 4) ? 100.0 : 200.0
                view2WidthContraint.constant = (animationPhase == 2 || animationPhase == 4) ? 100.0 : 200.0
                
                view3RightContraint.constant = (animationPhase == 3) ? self.view.frame.width - 150.0 : 50.0
                view3WidthContraint.constant = (animationPhase == 2 || animationPhase == 4) ? self.view.frame.width - 100.0 : 100.0
                
            }, animations: {
                
                /* Other changes will be animated from this block */
                
                self.view2?.backgroundColor = (self.animationPhase == 2 || self.animationPhase == 4) ? UIColor.blue : UIColor.green
            })
        }
        
        let nextTikTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: nextTikTime) {
            self.animationTik()
        }
    }
    
    func createView(rect: CGRect? = nil, backgroundColor: UIColor, title: String) -> UIView {
        
        let newView = (rect != nil) ? UIView(frame: rect!) : UIView()
        newView.backgroundColor = backgroundColor
        self.view.addSubview(newView)
        
        let label = UILabel()
        label.text = title
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 15.0)
        newView.addSubview(label)
        
        label.pin([.centerX, .centerY])
        
        return newView
    }


}

