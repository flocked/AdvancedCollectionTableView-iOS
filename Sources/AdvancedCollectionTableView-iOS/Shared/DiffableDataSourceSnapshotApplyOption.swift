//
//  NSDiffableDataSourceSnapshot+ApplyOption.swift
//
//
//  Created by Florian Zand on 23.07.23.
//

import Foundation

///  Options for applying a snapshot to a diffable data source.
public enum DiffableDataSourceSnapshotApplyOption: Hashable, Sendable {
    /**
     The snapshot gets applied animated.

     The data source computes a diff of the previous and new state and applies the updates to the receiver animated with a default animation duration.
     */
    public static var animated: Self { .animated(duration: noAnimationDuration) }

    /**
     The snapshot gets applied animiated with the specified animation duration.
     
     The data source computes a diff of the previous and new state and applies the updates to the receiver animated with the specified animation duration.
     */
    case animated(duration: TimeInterval)

    /**
     The snapshot gets applied using `reloadData()`.

     The system resets the UI to reflect the state of the data in the snapshot without computing a diff or animating the changes.
     */
    case usingReloadData
    /**
     The snapshot gets applied without any animation.

     The data source computes a diff of the previous and new state and applies the updates to the receiver without any animation.
     */
    case withoutAnimation

    static var noAnimationDuration: TimeInterval { 2_344_235 }

    var animationDuration: TimeInterval? {
        switch self {
        case let .animated(duration):
            return duration
        default:
            return nil
        }
    }
}
