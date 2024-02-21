//
//  Swizzle.swift
//
//  Adopted from github.com/neutralradiance/swift-core
//  Created by Florian Zand on 05.06.22.
//

import Foundation

infix operator <->
infix operator <~>

extension Selector {
    /// Creates a selector pair for swizzleing from the first and second selector.
    static func <-> (lhs: Selector, rhs: Selector) -> Swizzle.SelectorPair {
        Swizzle.SelectorPair(old: lhs, new: rhs)
    }

    /// Creates a selector pair for swizzleing from the first and second static selector.
    static func <~> (lhs: Selector, rhs: Selector) -> Swizzle.SelectorPair {
        Swizzle.SelectorPair(old: lhs, new: rhs, static: true)
    }
}

/**
 Swizzling of class selectors.

 Example:
 ```swift
 try? Swizzle(NSView.self) {
     #selector(viewDidMoveToSuperview) <-> #selector(swizzledViewDidMoveToSuperview)
 }
 ```
 */
struct Swizzle {
    @resultBuilder
    enum Builder {
        static func buildBlock(_ swizzlePairs: SelectorPair...) -> [SelectorPair] {
            Array(swizzlePairs)
        }
    }

    /**
     Swizzles selectors of the specified class.

     - Parameters:
        - type:  The class to swizzle.
        - makeSelectorPairs: The swizzle selector pairs.

     - Throws:Throws if swizzling fails.
     - Returns: A `Swizzle` object for the specified values.
     */
    @discardableResult
    init(_ type: AnyClass, @Builder _ makeSelectorPairs: () -> [SelectorPair]) throws {
        try self.init(type, swizzlePairs: makeSelectorPairs())
    }

    /**
     Swizzles selectors of the specified class.

     - Parameters:
        - type:  The class to swizzle.
        - makeSelectorPairs: The swizzle selector pairs.

     - Throws:Throws if swizzling fails.
     - Returns: A `Swizzle` object for the specified values.
     */
    @discardableResult
    init(_ type: AnyClass, @Builder _ makeSelectorPairs: () -> SelectorPair) throws {
        try self.init(type, swizzlePairs: [makeSelectorPairs()])
    }

    @discardableResult
    init(_ class_: AnyClass, swizzlePairs: [SelectorPair]) throws {
        guard object_isClass(class_) else {
            throw Error.missingClass(String(describing: class_))
        }
        try swizzle(type: class_, pairs: swizzlePairs)
    }

    private func swizzle(
        type: AnyObject.Type,
        pairs: [SelectorPair]
    ) throws {
        try pairs.forEach { pair in
            guard let `class` =
                pair.static ?
                object_getClass(type) : type
            else {
                throw Error.missingClass(type.description())
            }
            guard
                let lhs =
                class_getInstanceMethod(`class`, pair.old)
            else {
                throw Error.missingMethod(`class`, pair.static, true, pair)
            }
            guard let rhs =
                class_getInstanceMethod(`class`, pair.new)
            else {
                throw Error.missingMethod(`class`, pair.static, false, pair)
            }

            if pair.static,
               class_addMethod(
                   `class`, pair.old,
                   method_getImplementation(rhs), method_getTypeEncoding(rhs)
               )
            {
                class_replaceMethod(
                    `class`,
                    pair.new,
                    method_getImplementation(lhs),
                    method_getTypeEncoding(lhs)
                )

            } else {
                method_exchangeImplementations(lhs, rhs)
            }
            //   debugPrint("Swizzled\(pair.static ? " static" : "") method for: \(pair)")
        }
    }
}

extension Swizzle {
    /// An error for swizzleing.
    enum Error: LocalizedError {
        /// The class is missing.
        case missingClass(_ name: String)
        /// The method is missing.
        case missingMethod(_ type: AnyObject.Type, _ static: Bool, _ old: Bool, SelectorPair)

        static let prefix: String = "Swizzle.Error: "

        var failureReason: String? {
            switch self {
            case let .missingClass(type):
                return "Missing class: \(type)"
            case let .missingMethod(type, `static`, old, pair):
                return
                    """
                    Missing \(old ? "old" : "new")\(`static` ? " static" : "") method for \
                    \(type.description()): \(pair)
                    """
            }
        }

        var recoverySuggestion: String? {
            switch self {
            case .missingClass:
                return nil
            case let .missingMethod(type, `static`, old, pair):
                return
                    """
                    Create \(old ? "old" : "new")\(`static` ? " static" : "") method for \
                    \(type.description()): \(pair)
                    """
            }
        }

        var errorDescription: String? {
            switch self {
            case .missingClass:
                return Self.prefix.appending(failureReason ?? "")
            case .missingMethod:
                return Self.prefix.appending(failureReason ?? "")
            }
        }
    }
}

extension Swizzle {
    /// A pair of selectors for swizzleing.
    struct SelectorPair: CustomStringConvertible {
        /// The old selector.
        let old: Selector
        /// The new selector to replace the old.
        let new: Selector
        /// A Boolean value indicating whether the selectors are static.
        let `static`: Bool

        /**
         Creates a selector pair.

         - Parameters:
            - old: The old selector.
            - new: The new selector to replace the old.
            - static: A Boolean value indicating whether the selectors are static. The default value is `false`.
         */
        init(old: Selector, new: Selector, static: Bool = false) {
            self.old = old
            self.new = new
            self.static = `static`
        }

        init<V>(get old: PartialKeyPath<V>, new: PartialKeyPath<V>, static: Bool = false) {
            self.old = NSSelectorFromString(old._kvcKeyPathString!)
            self.new = NSSelectorFromString(new._kvcKeyPathString!)
            self.static = `static`
        }

        init<V>(set old: PartialKeyPath<V>, new: PartialKeyPath<V>, static: Bool = false) {
            self.old = NSSelectorFromString("set" + old._kvcKeyPathString!.capitalized)
            self.new = NSSelectorFromString("set" + new._kvcKeyPathString!.capitalized)
            self.static = `static`
        }

        var `operator`: String {
            `static` ? "<~>" : "<->"
        }

        var description: String {
            "\(old) \(self.operator) \(new)"
        }
    }
}
