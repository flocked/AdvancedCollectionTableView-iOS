//
//  ContentConfigurationView.swift
//
//
//  Created by Florian Zand on 21.02.24.
//

import UIKit

/// A view that displays the content view of a `UIContentConfiguration`.
class ContentConfigurationView: UIView {
    
    /// The content view.
    var contentView: (UIView & UIContentView)

    /// The current content configuration.
    public var contentConfiguration: UIContentConfiguration {
        didSet {
            updateContentView()
        }
    }
    
    func updateContentView() {
        contentView.removeFromSuperview()
        contentView = contentConfiguration.makeContentView()
        addSubview(withConstraint: contentView)
    }
    
    /// Creates a view with the specified content configuration.
    public init(configuration: UIContentConfiguration) {
        self.contentConfiguration = configuration
        self.contentView = configuration.makeContentView()
        super.init(frame: .zero)
        addSubview(withConstraint: contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
