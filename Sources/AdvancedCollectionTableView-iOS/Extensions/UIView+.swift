//
//  UIView+.swift
//  
//
//  Created by Florian Zand on 21.02.24.
//

import UIKit

extension UIView {
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
        addSubview(withConstraint: view, .full)
    }

    /**
     Adds a view to the end of the receiver’s list of subviews and constraits it's frame to the receiver using the specified mode.

     - Parameters:
        - view: The view to be added. After being added, this view appears on top of any other subviews.
        - mode: The mode for constraining the subview's frame.

     - Returns: The layout constraints in the following order: bottom, left, width and height.
     */
    @discardableResult
    func addSubview(withConstraint view: UIView, _ mode: ConstraintMode) -> [NSLayoutConstraint] {
        addSubview(view)
        return view.constraint(to: self, mode)
    }
    
    /// Constants how a view is constraint.
    enum ConstraintMode {
        enum Position: Int {
            case top
            case topLeft
            case topRight
            case center
            case centerLeft
            case centerRight
            case bottom
            case bottomLeft
            case bottomRight
        }

        case relative
        /// The view's frame is constraint to the edges of the other view.
        case absolute
        /// The view's frame is constraint to the edges of the other view.
        case full
        /// The view's frame is constraint to the edges of the other view with the specified insets.
        case insets(UIEdgeInsets)
        case positioned(Position, padding: CGFloat = 0)
        var padding: CGFloat? {
            switch self {
            case let .positioned(_, padding): return padding
            default: return nil
            }
        }
    }
    
    /**
     Constraits the view's frame to the specified view.

     - Parameters:
        - view: The view to be constraint to.
        - mode: The mode for constraining the subview's frame.

     - Returns: The layout constraints in the following order: bottom, left, width and height.
     */
    @discardableResult
    func constraint(to view: UIView, _ mode: ConstraintMode = .full) -> [NSLayoutConstraint] {
        let constants: [CGFloat]

        switch mode {
        case .absolute:
            constants = calculateConstants(view)
        case let .insets(insets):
            constants = [insets.left, insets.bottom, 0.0 - insets.right, 0.0 - insets.top]
        default:
            constants = [0, 0, 0, 0]
        }
        let multipliers: [CGFloat]
        switch mode {
        case .relative: multipliers = calculateMultipliers(self)
        default: multipliers = [1.0, 1.0, 1.0, 1.0]
        }

        switch mode {
        case .full: frame = view.bounds
        default: break
        }

        translatesAutoresizingMaskIntoConstraints = false

        var constraints: [NSLayoutConstraint] = []
        switch mode {
        case let .positioned(position, padding):
            switch position {
            case .top, .topLeft, .topRight:
                constraints.append(topAnchor.constraint(equalTo: view.topAnchor, constant: padding))
            case .center, .centerLeft, .centerRight:
                constraints.append(centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0))
            case .bottomLeft, .bottom, .bottomRight:
                constraints.append(bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: padding))
            }
            constraints.append(widthAnchor.constraint(equalTo: view.widthAnchor, constant: -(padding * 2.0)))
            constraints.append(heightAnchor.constraint(equalToConstant: view.frame.size.height))
        default:
            constraints.append(contentsOf: [
                .init(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: multipliers[0], constant: constants[0]),
                .init(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: multipliers[1], constant: constants[1]),
                .init(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: multipliers[2], constant: constants[2]),
                .init(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: multipliers[3], constant: constants[3]),
            ])
        }

        NSLayoutConstraint.activate(constraints)
        return constraints
    }
    
    internal func calculateMultipliers(_ view: UIView) -> [CGFloat] {
        let x = view.frame.origin.x / bounds.width
        let y = view.frame.origin.y / bounds.height
        let width = view.frame.width / bounds.width
        let height = view.frame.height / bounds.height
        return [x, y, width, height]
    }

    internal func calculateConstants(_ view: UIView) -> [CGFloat] {
        let x = view.frame.minX
        let y = -view.frame.minY
        let width = view.frame.width - bounds.width
        let height = view.frame.height - bounds.height
        return [x, y, width, height]
    }
}
