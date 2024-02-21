//
//  UIView+.swift
//  
//
//  Created by Florian Zand on 21.02.24.
//

import UIKit

extension UIView {
    
    /// Sends the view to the front of it's superview.
    func sendToFront() {
        superview?.bringSubviewToFront(self)
    }
    
    /// Sends the view to the back of it's superview.
    func sendToBack() {
        superview?.sendSubviewToBack(self)
    }
    
    /**
     The first superview that matches the specificed view type.

     - Parameter viewType: The type of view to match.
     - Returns: The first parent view that matches the view type or `nil` if none match or there isn't a matching parent.
     */
    func firstSuperview<V: UIView>(for _: V.Type) -> V? {
        firstSuperview(where: { $0 is V }) as? V
    }

    /**
     The first superview that matches the specificed predicate.

     - Parameter predicate: The closure to match.
     - Returns: The first parent view that is matching the predicate or `nil` if none match or there isn't a matching parent.
     */
    func firstSuperview(where predicate: (UIView) -> (Bool)) -> UIView? {
        if let superview = superview {
            if predicate(superview) == true {
                return superview
            }
            return superview.firstSuperview(where: predicate)
        }
        return nil
    }
    
    /**
     Adds a view to the end of the receiver’s list of subviews and constraits it's frame to the receiver.

     - Parameter view: The view to be added. After being added, this view appears on top of any other subviews.
     - Returns: The layout constraints in the following order: bottom, left, width and height.
     */
    @discardableResult
    func addSubview(withConstraint view: UIView) -> [NSLayoutConstraint] {
        addSubview(view)
        return view.constraint(to: self)
    }
    
    /**
     Constraits the view's frame to the specified view.

     - Parameter view: The view to be constraint to.
     - Returns: The layout constraints in the following order: bottom, left, width and height.
     */
    @discardableResult
    func constraint(to view: UIView) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            .init(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0),
            .init(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0),
            .init(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0),
            .init(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0),
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }
}
