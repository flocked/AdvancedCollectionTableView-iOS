//
//  NSDiffableDataSourceSnapshot+.swift
//  
//
//  Created by Florian Zand on 22.02.24.
//

import UIKit

extension NSDiffableDataSourceSnapshot {
    /// A Boolean value indicating whether the snapshot is empty.
    var isEmpty: Bool {
        numberOfItems == 0 && numberOfSections == 0
    }
}
