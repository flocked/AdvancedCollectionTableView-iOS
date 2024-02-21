# Advanced UICollectionView & UITableView

A framework for `UICollectionView` and `UITableView` that provides:

- Extended collection and table view diffable data sources with handlers for selecting, reordering, focusing and editing cells and additional functionality.
- Table view cell registration similar to `UICollectionView.CellRegistration`.
- Additional extensions for `UICollectionView` and `UITableView`.

## UICollectionViewDiffableDataSource & TableViewDiffableDataSource

It provides handlers for selecting, reordering, focusing and editing cells and additional functionality.

Examples of some of the included handlers:

```swift
// Handler that gets called when the user did select an item.
diffableDataSource.selectionHandlers.didSelect = { itemIdentifier in

}

// Handler that gets called when an item/cell is about to be shown.
diffableDataSource.displayingHandlers.willDisplay = { itemIdentifier, cell in

}
```

`TableViewDiffableDataSource` provides handlers for reordering of cells/items like `UICollectionViewDiffableDataSource’s` reordering handlers:

```swift
// Allow every item to be reordered
tableViewDataSource.reorderingHandlers.canReorder = { item in return true }

// Update the backing store from the did reorder transaction.
tableViewDataSource.reorderingHandlers.didReorder = { [weak self] transaction, _ in
    guard let self = self else { return }
             
    if let updatedCurrentItems = self.currentItems.applying(transaction.difference) {
        self.currentItems = updatedCurrentItems
    }
}
```

## UITableView Cell Registration

A registration for the table view’s cells similar to `UICollectionView.CellRegistration`.

Use a cell registration to register table cell views with your table view and configure each cell for display.

The following example creates a cell registration for cells of type `UITableViewCell` and string items. Each cells textfield displays its item string.

```swift
let cellRegistration = UITableView.CellRegistration<UITableViewCell, String> { cell, indexPath, string in
    var contentConfiguration = cell.defaultContentConfiguration()

    contentConfiguration.text = string
    contentConfiguration.textProperties.color = .lightGray

    cell.contentConfiguration = contentConfiguration
}
```

After you create a cell registration, you pass it in to ``dequeueConfiguredReusableCell(using:for:item:)``, which you call from your data source’s cell provider.

```swift
dataSource = UITableViewDiffableDataSource<Section, String>(tableView: tableView) {
    tableView, indexPath, item in
    return tableView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
}
```

Alternatively you can use the ``UICollectionViewDiffableDataSource`` and ``UITableViewDiffableDataSource`` initializers:

```swift
let dataSource = UITableViewDiffableDataSource(tableView: myTableView, cellRegistration: cellRegistration)
}
```

## UITableView Section View Registration

A registration for the table view’s header/footer section views.

The following example creates a section view registration for views of type `UITableViewHeaderFooterView` for sections with strings. Each section header views default content configuration text displays its section string.

```swift
let sectionViewRegistration = UITableView.SectionViewRegistration<UITableViewHeaderFooterView, String> {
    sectionView, indexPath, string in
     
    var configuration = sectionView.defaultContentConfiguration()
    configuration.text = string
    sectionView.contentConfiguration = configuration
}
```
     
After you create a section view registration, you pass it in to ``dequeueConfiguredReusableSectionView(using:section:)``, which you call from your data source’s section header view provider.

```swift
dataSource.headerViewProvider = { tableView, section in
    return tableView.dequeueConfiguredReusableSectionView(using: sectionViewRegistration, section: section)
}
```

Alternatively you can also ``applyHeaderViewRegistration()`` and `applyFooterViewRegistration()``:

```swift
dataSource.applyHeaderViewRegistration(sectionViewRegistration)
```

## Diffable DataSource Snapshot Apply Options

Options for applying snapshots to a diffable datasource:

```swift
// Applies the snapshot animated with default animation duration.
dataSource.apply(mySnapshot, .animated)

// Applies the snapshot animated with the specified animation duration.
dataSource.apply(mySnapshot, .animated(duration: 2.0))

// Applies the snapshot non animated.
dataSource.apply(mySnapshot, .withoutAnimation)

// Applies the snapshot using reload data.
dataSource.apply(mySnapshot, .usingReloadData)
```
