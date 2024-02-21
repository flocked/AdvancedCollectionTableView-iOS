//
//  Array+.swift
//
//
//  Created by Florian Zand on 21.02.24.
//

import Foundation

extension Array {
    subscript(safe index: Index) -> Element? {
        get {
            guard !isEmpty, index >= startIndex, index < count else { return nil }
            return self[index]
        }
        set {
            guard !isEmpty, index >= startIndex, index < count, let newValue = newValue else { return }
            self[index] = newValue
        }
    }
}
