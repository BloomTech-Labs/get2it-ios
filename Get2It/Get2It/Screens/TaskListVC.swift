//
//  TaskListVC.swift
//  Get2It
//
//  Created by Vici Shaweddy on 3/29/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class TaskListVC: UIViewController, UICollectionViewDelegate {
    enum ListModel: Hashable {
        case grid(GridDisplay)
        case task(Task.Diffable)
    }
    
    enum SectionLayoutKind: Int, CaseIterable {
        case grid, list
        
        var columnCount: Int {
            switch self {
            case .grid:
                return 2
            case .list:
                return 1
            }
        }
    }
    
    enum FilterBy {
        case today, tomorrow, someday, past, completed
        case tasks(ids: [Int])
    }
    
    var filterBy: FilterBy?
    var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ListModel>!
    var taskController: TaskController?
    var categoryController: CategoryController?
    var category: Category?
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: self.createLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(SummaryCell.self, forCellWithReuseIdentifier: SummaryCell.reuseIdentifier)
        collectionView.register(TaskListCell.self, forCellWithReuseIdentifier: TaskListCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private lazy var fetchedTaskController: NSFetchedResultsController<Task> = {
        // Fetch request
        let fetchRequest:NSFetchRequest<Task> = Task.fetchRequest()
        
        if let thereIsAFilter = self.filterBy {
            let predicate: NSPredicate
            
            switch thereIsAFilter {
            case .today:
                let today = Date()
                predicate = predicateForFilteringBy(date: today)
            case .tomorrow:
                let tomorrow = Date().addingTimeInterval(86400)
                predicate = predicateForFilteringBy(date: tomorrow)
            case .past:
                predicate = predicateForFilteringBefore(date: Date())
            case .someday:
                let tomorrow = Date().addingTimeInterval(86400)
                predicate = predicateForFilteringAfter(date: tomorrow)
            case .completed:
                predicate = NSPredicate(format: "status == YES")
            case .tasks(let ids):
                predicate = NSPredicate(format: "taskId in %@", ids)
            }
            
            fetchRequest.predicate = predicate
        }
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false),
            NSSortDescriptor(key: "startTime", ascending: false)
        ]
        
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureHierarchy()
        configureDataSource()
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // check if it should be filtered by Category
        if let category = category {
            fetchByCategories(category: category)
        } else {
            performFetch()
        }
    }
    
    func fetchByCategories(category: Category) {
        taskController?.fetchTasksFromServerBy(categoryId: Int(category.categoriesId)) { [weak self] result in
            switch result {
            case .success(let tasks):
                let ids = tasks.compactMap { $0.taskId }
                self?.filterBy = .tasks(ids: ids)
                DispatchQueue.main.async {
                    self?.performFetch()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func performFetch() {
        do {
            try self.fetchedTaskController.performFetch()
            updateSnapshots()
        } catch {
            fatalError("frc crash")
        }
    }
    
    func updateSnapshots() {
        let tasks = fetchedTaskController.fetchedObjects ?? []
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ListModel>()
        snapshot.appendSections([.grid, .list])
        
        let completedTasks = tasks.filter { $0.status == true }
        
        let gridItems: [ListModel] = [.grid(.tasks(numberOfTasks: tasks.count)), .grid(.completedTasks(numberOfTasks: completedTasks.count))]
        snapshot.appendItems(gridItems, toSection: .grid)
        
        let listItems: [ListModel] = tasks.map { ListModel.task(Task.Diffable(task: $0)) }
        snapshot.appendItems(listItems, toSection: .list)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension TaskListVC {
    // Filtering the Tasks based on the date
    func predicateForFilteringBy(date: Date) -> NSPredicate {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        components.hour = 00
        components.minute = 00
        components.second = 00
        let startDate = calendar.date(from: components)
        components.hour = 23
        components.minute = 59
        components.second = 59
        let endDate = calendar.date(from: components)
        
        return NSPredicate(format: "date >= %@ AND date =< %@", argumentArray: [startDate!, endDate!])
    }
    
    // someday
    func predicateForFilteringAfter(date: Date) -> NSPredicate {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        components.hour = 23
        components.minute = 59
        components.second = 59
        let startDate = calendar.date(from: components)
        return NSPredicate(format: "date >= %@", argumentArray: [startDate!])
    }
    
    // past
    func predicateForFilteringBefore(date: Date) -> NSPredicate {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        components.hour = 00
        components.minute = 00
        components.second = 00
        let startDate = calendar.date(from: components)
        return NSPredicate(format: "date <= %@", argumentArray: [startDate!])
    }
}

extension TaskListVC {
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
//        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTaskButtonTapped))
//        navigationItem.rightBarButtonItem = addBarButton
    }
    
    @objc func addTaskButtonTapped() {
        let addTaskVC = AddTaskVC()
        addTaskVC.categoryController = categoryController
        addTaskVC.taskController = taskController
        addTaskVC.categoryController = categoryController
        let navigationController = UINavigationController(rootViewController: addTaskVC)
        present(navigationController, animated: true, completion: nil)
    }
    
    func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for a task"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionLayoutKind = SectionLayoutKind(rawValue: sectionIndex) else { return nil }
            
            switch sectionLayoutKind {
            case .grid:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
                let groupHeight = NSCollectionLayoutDimension.fractionalWidth(1/3)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: groupHeight)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                               subitem: item,
                                                               count: sectionLayoutKind.columnCount)
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
                return section
            case .list:
                let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(40))
                let item = NSCollectionLayoutItem(layoutSize: size)
                item.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: nil, top: .fixed(8), trailing: nil, bottom: .fixed(8))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
                return section
            }
        }
        return layout
    }
    
    func configureHierarchy() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    @objc func swipeToDelete(sender: UISwipeGestureRecognizer) {
        let cell = sender.view as! TaskListCell
        let itemIndex = self.collectionView.indexPath(for: cell)!.item
        let task = self.fetchedTaskController.fetchedObjects?[itemIndex]
        
        if let items = dataSource.itemIdentifier(for: IndexPath(item: itemIndex, section: 1)) {
            var snapshot = dataSource.snapshot()
            snapshot.deleteItems([items])
            dataSource.apply(snapshot, animatingDifferences: true)
            task.map { taskController?.delete(task:$0) }
        }
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ListModel>(collectionView: collectionView) {
            collectionView, indexPath, listModel -> UICollectionViewCell? in
            
            let section = SectionLayoutKind(rawValue: indexPath.section)!
            if section == .list {
                // Cell for Tasks
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskListCell.reuseIdentifier, for: indexPath) as? TaskListCell {
                    // Only extracting one case for this cell from ListModel enum
                    guard case .task(let taskDiffable) = listModel else { return nil }
                    cell.configure(with: taskDiffable.task)
                    cell.delegate = self
                    
                    let swipeToDeleteAction = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeToDelete(sender:)))
                    swipeToDeleteAction.direction = UISwipeGestureRecognizer.Direction.left
                    cell.addGestureRecognizer(swipeToDeleteAction)
                    
                    cell.delegate = self
                    return cell
                } else {
                    fatalError("Can't create new cell")
                }
            } else {
                // Cell for Summary Cards
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SummaryCell.reuseIdentifier, for: indexPath) as? SummaryCell {
                    
                    cell.contentView.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
                    cell.contentView.layer.borderColor = UIColor.black.cgColor
                    cell.contentView.layer.borderWidth = 0.2
                    cell.contentView.layer.cornerRadius = section == .grid ? 10 : 0
                    
                    guard case .grid(let gridDisplay) = listModel else { return nil }
                    
                    if gridDisplay.gridIndex == 0 {
                        cell.titleLabel.text = "Tasks"
                        cell.iconImage.image = UIImage(systemName: "list.bullet")
                        cell.numberLabel.text = String(gridDisplay.numberOfTasks)
                    } else {
                        cell.titleLabel.text = "Completed Tasks"
                        cell.iconImage.image = UIImage(systemName: "text.badge.checkmark")
                        cell.numberLabel.text = String(gridDisplay.numberOfTasks)
                    }
                    
                    // Return the cell
                    return cell
                } else {
                    fatalError("Can't create new cell")
                }
            }
        }
        
        // Initial data
        var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ListModel>()
        snapshot.appendSections([.grid, .list])
        
        let gridItems: [ListModel] = [.grid(.tasks()), .grid(.completedTasks())]
        snapshot.appendItems(gridItems, toSection: .grid)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = SectionLayoutKind(rawValue: indexPath.section)!
        if section == .list {
            let editVC = EditTaskVC()
            editVC.taskController = taskController
            editVC.task = fetchedTaskController.fetchedObjects?[indexPath.item]
            self.navigationController?.pushViewController(editVC, animated: true)
        }
    }
}

extension TaskListVC: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == self.fetchedTaskController {
            self.updateSnapshots()
        }
    }
}

extension TaskListVC: TaskListCellDelegate {
    func cellDidToggle(isChecked: Bool, for task: Task?) {
        guard let task = task else { return }
        task.status = isChecked
        
        taskController?.updateTaskOnServer(task: task, completion: { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                DispatchQueue.main.async {
                    let moc = CoreDataStack.shared.mainContext
                    try? moc.save()
                }
            }
        })
    }
}

extension TaskListVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive {
            guard let filter = searchController.searchBar.text, !filter.isEmpty else {
                fetchedTaskController.fetchRequest.predicate = nil
                performFetch()
                return
            }
            
            let predicate = NSPredicate(format: "(date CONTAINS %@) OR (startTime CONTAINS %@) OR (endTime CONTAINS %@) OR (name CONTAINS %@)", filter, filter, filter, filter)
            fetchedTaskController.fetchRequest.predicate = predicate
            performFetch()
        }
    }
}

