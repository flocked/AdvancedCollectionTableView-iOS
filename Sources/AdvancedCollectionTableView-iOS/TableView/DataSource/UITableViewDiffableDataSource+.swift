//
//  UITableViewDiffableDataSource+.swift
//
//
//  Created by Florian Zand on 14.09.23.
//

import UIKit

public extension UITableViewDiffableDataSource {
    /**
     Creates a diffable data source with the specified cell registration, and connects it to the specified table view.

     - Parameters:
        - tableView: The initialized table view object to connect to the diffable data source.
        - cellRegistration: A cell registration that creates, configurates and returns each of the cells for the table view from the data the diffable data source provides.
     */
    convenience init<Cell>(tableView: UITableView, cellRegistration: UITableView.CellRegistration<Cell, ItemIdentifierType>) where Cell: UITableViewCell {
        self.init(tableView: tableView) { tableView, indexPath, item in
            tableView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
    
    /**
     Updates the UI to reflect the state of the data in the specified snapshot, optionally animating the UI changes and executing a completion handler.

     It’s safe to call this method from a background queue, but you must do so consistently in your app. Always call this method exclusively from the main queue or from a background queue.

     - Parameters:
        - snapshot: The snapshot reflecting the new state of the data in the collection view.
        - option: Option how to apply the snapshot to the table view.
        - completion: An optional closure to be executed when the animations are complete. This closure has no return value and takes no parameters. The system calls this closure from the main queue. The default value is `nil`.
     */
    func apply(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>, _ option: DiffableDataSourceSnapshotApplyOption, completion: (() -> Void)? = nil) {
        switch option {
        case .usingReloadData:
            if #available(iOS 15.0, tvOS 15.0, *) {
                applySnapshotUsingReloadData(snapshot, completion: completion)
            } else {
                apply(snapshot, animatingDifferences: false, completion: completion)
            }
        case .animated(duration: let duration):
            if duration == DiffableDataSourceSnapshotApplyOption.noAnimationDuration {
                apply(snapshot, animatingDifferences: true, completion: completion)
            } else {
                UIView.animate(withDuration: duration) {
                    self.apply(snapshot, animatingDifferences: true, completion: completion)
                }
            }
        case .withoutAnimation:
            if #available(iOS 15.0, tvOS 15.0, *) {
                apply(snapshot, animatingDifferences: false, completion: completion)
            } else {
                UIView.animate(withDuration: 0.0) {
                    self.apply(snapshot, animatingDifferences: true, completion: completion)
                }
            }
        }
    }
}
