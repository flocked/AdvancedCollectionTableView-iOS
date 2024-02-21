//
//  ContentConfigurationView.swift
//
//
//  Created by Florian Zand on 21.02.24.
//

import UIKit

class ContentConfigurationView: UIView {
    var contentView: (UIView & UIContentView)

    var contentConfiguration: UIContentConfiguration {
        didSet {
            updateContentView()
        }
    }
    
    func updateContentView() {
        contentView.removeFromSuperview()
        contentView = contentConfiguration.makeContentView()
        addSubview(withConstraint: contentView)
    }
    
    init(configuration: UIContentConfiguration) {
        self.contentConfiguration = configuration
        self.contentView = configuration.makeContentView()
        super.init(frame: .zero)
        addSubview(withConstraint: contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
