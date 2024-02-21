# Advanced UICollectionView & UITableView

A framework for `UICollectionView` and `UITableView` that provides:

- Extended collection and table view diffable data sources with handlers for selecting, reordering, focusing and editing cells and additional functionality.
- Table view cell registration similar to `UICollectionView.CellRegistration`.
- Additional extensions for `UICollectionView` and `UITableView`.

## UICollectionViewDiffableDataSource & TableViewDiffableDataSource

It provides handlers for selecting, reordering, focusing and editing cells and additional functionality.

Examples of some of the included handlers:

```swift
/// Handler that gets called when the user did select an item.
diffableDataSource.selectionHandlers.didSelect = { itemIdentifier in
    // did select an item
}

/// Handler that gets called when an item/cell is about to be shown.
diffableDataSource.displayingHandlers.willDisplay = { itemIdentifier, cell in

}
```

`TableViewDiffableDataSource` provides handlers for reordering of cells/items like `UICollectionViewDiffableDataSource’s` reordering handlers:

```swift
// Allow every item to be reordered
tableViewDataSource.reorderingHandlers.canReorder = { item in return true }

// Update the backing store from the did reorder transaction.
tableViewDataSource.reorderingHandlers.didReorder = { [weak self] transaction, itemIdentifier in
    guard let self = self else { return }
             
    if let updatedBackingStore = self.backingStore.applying(transaction.difference) {
        self.backingStore = updatedBackingStore
    }
}
```

## UITableView Cell and Header/Footer registration

A registration for the table view’s cells and header/footer views similar to `UICollectionView.CellRegistration`.

Use a cell registration to register table cell views with your table view and configure each cell for display.

The following example creates a cell registration for cells of type `UITableViewCell`. Each cells textfield displays its item.

```swift
let cellRegistration = UITableView.CellRegistration<UITableViewCell, String> { cell, indexPath, string in
    var contentConfiguration = cell.defaultContentConfiguration()

    contentConfiguration.text = string
    contentConfiguration.textProperties.color = .lightGray

    cell.contentConfiguration = contentConfiguration
}
```

After you create a cell registration, you pass it in to ``UIKit/UITableView/dequeueConfiguredReusableCell(using:for:item:)``, which you call from your data source’s cell provider.

```swift
dataSource = UITableViewDiffableDataSource<Section, String>(tableView: tableView) {
    tableView, indexPath, item in
    return tableView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
}
```
