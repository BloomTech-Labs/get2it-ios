//
//  HomeVC.swift
//  Get2It
//
//  Created by John Kouris on 3/28/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class HomeVC: UIViewController, UICollectionViewDelegate {
    enum ListModel: Hashable {
        case header
        case grid(GridDisplay)
        case list(name: String)
        case category(name: String)
    }

    enum SectionLayoutKind: Int, CaseIterable {
        case header, grid, list, category

        var columnCount: Int {
            switch self {
            case .header:
                return 1
            case .grid:
                return 2
            case .list:
                return 1
            case .category:
                return 1
            }
        }
    }
    
    private var workItem: DispatchWorkItem?
    
    let taskController = TaskController()
    let categoryController = CategoryController()
    var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ListModel>!
    var collectionView: UICollectionView! = nil
    
    private lazy var fetchedTaskController: NSFetchedResultsController<Task> = { [weak self] in
        // Fetch request
        let fetchRequest:NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false),
        ]
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    private lazy var fetchedCategoryController: NSFetchedResultsController<Category> = { [weak self] in
        let fetchRequest:NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: false)
        ]
        
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    private let center = UNUserNotificationCenter.current()
    private var pending: [UNNotificationRequest] = []
    private var delivered: [UNNotification] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        configureHierarchy()
        configureDataSource()
        configureViewController()
        setFont()
        
        do {
            try self.fetchedCategoryController.performFetch()
            try self.fetchedTaskController.performFetch()
            updateSnapshots()
        } catch {
            fatalError("frc crash")
        }
        
        categoryController.fetchCategoriesFromServer()
        taskController.fetchTasksFromServer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in }
    }
    
    // Custom Navigation Title
    func setFont() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: Theme.primaryBlue, NSAttributedString.Key.font: Font.primaryHeaderText ?? UIFont.systemFont(ofSize: 42)]
    }
    
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createHomeLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(HeaderCell.self, forCellWithReuseIdentifier: HeaderCell.reuseIdentifier)
        collectionView.register(SummaryCell.self, forCellWithReuseIdentifier: SummaryCell.reuseIdentifier)
        collectionView.register(HomeListCell.self, forCellWithReuseIdentifier: HomeListCell.reuseIdentifier)
        collectionView.register(HomeCategoryCell.self, forCellWithReuseIdentifier: HomeCategoryCell.reuseIdentifier)
        collectionView.register(SectionHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderReusableView.reuseIdentifier)
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ListModel>(collectionView: collectionView) {
            (collectionView:UICollectionView, indexPath: IndexPath, model: ListModel) -> UICollectionViewCell? in
            
            let section = SectionLayoutKind(rawValue: indexPath.section)!
            
            if section == .list {
                // Cell for Task List
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeListCell.reuseIdentifier, for: indexPath) as? HomeListCell {
                    if case .list(let name) = model {
                        cell.label.text = name
                    }

                    return cell
                } else {
                    fatalError("Can't create new cell")
                }
            } else if section == .grid {
                // Cell for Summary Cards
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SummaryCell.reuseIdentifier, for: indexPath) as? SummaryCell {
                    
                    cell.contentView.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
                    cell.contentView.layer.borderColor = UIColor.black.cgColor
                    cell.contentView.layer.borderWidth = 0.2
                    cell.contentView.layer.cornerRadius = section == .grid ? 10 : 0
                    
                    guard case .grid(let gridDisplay) = model else { return nil }
                    
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
            } else if section == .category {
                // Cell for Category List
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeListCell.reuseIdentifier, for: indexPath) as? HomeListCell {
                    if case .category(let name) = model {
                        cell.label.text = name
                    }

                    return cell
                } else {
                    fatalError("Can't create new cell")
                }
            } else {
                // Cell for Header
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderCell.reuseIdentifier, for: indexPath) as? HeaderCell {
                    
                    cell.contentView.backgroundColor = UIColor(red: 0.02, green: 0.357, blue: 0.765, alpha: 1)
                    cell.contentView.layer.borderColor = UIColor.black.cgColor
                    cell.contentView.layer.borderWidth = 0.2
                    cell.contentView.layer.cornerRadius = section == .header ? 10 : 0
                    
                    // Return the cell
                    return cell
                } else {
                    fatalError("Can't create new cell")
                }
            }
        }
        
        // Get an instance of the section for the supplementary view
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            // Ensure the supplementary view provider asks for a header
            guard kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }
            
            // Dequeue a new header view
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderReusableView.reuseIdentifier, for: indexPath)  as? SectionHeaderReusableView
            
            // Retrieve the section from the data source, then set the titleLabel‘s text value to the section‘s title
            let section = self?.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            view?.titleLabel.text = section?.title
            if section == .list {
                view?.hideAddButton = true
            }
            
            view?.delegate = self
            return view
        }
        
        // Initial data
        var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ListModel>()
        snapshot.appendSections([.header, .grid, .list, .category])
        snapshot.appendItems([.header], toSection: .header)
        
        let gridItems: [ListModel] = [.grid(.tasks()), .grid(.completedTasks())]
        snapshot.appendItems(gridItems, toSection: .grid)
        
        let listItems: [ListModel] = [.list(name: "Today"), .list(name: "Tomorrow"), .list(name: "Someday"), .list(name: "Past")]
        snapshot.appendItems(listItems, toSection: .list)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func updateSnapshots() {
        let tasks: [Task] = fetchedTaskController.fetchedObjects ?? []
        
        let completedTasks = tasks.filter { $0.status == true }
        
        let categories = fetchedCategoryController.fetchedObjects ?? []
        
        var snapshot = dataSource.snapshot()

        let categoryItems = categories.map { ListModel.category(name: $0.name ?? "") }

        let gridItems: [ListModel] = [.grid(.tasks(numberOfTasks: tasks.count)), .grid(.completedTasks(numberOfTasks: completedTasks.count))]
        
        // Delete the old grids and recreate new ones after fetching the tasks
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .grid))
        snapshot.appendItems(gridItems, toSection: .grid)
        
        snapshot.deleteSections([.category])
        snapshot.appendSections([.category])
        snapshot.appendItems(categoryItems, toSection: .category)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let _ = dataSource.itemIdentifier(for: indexPath) else { return }
        let taskListVC = TaskListVC()
        taskListVC.categoryController = categoryController
        taskListVC.taskController = taskController
        taskListVC.title = "Task List"
        
        if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                taskListVC.filterBy = .today
                taskListVC.title = "Today List"
            case 1:
                taskListVC.filterBy = .tomorrow
                taskListVC.title = "Tomorrow List"
            case 2:
                taskListVC.filterBy = .someday
                taskListVC.title = "Someday List"
            case 3:
                taskListVC.filterBy = .past
                taskListVC.title = "Past List"
                
            default:
                break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                break
            case 1:
                taskListVC.filterBy = .completed
            default:
                break
            }
        } else if indexPath.section == 3 {
            let categories = fetchedCategoryController.fetchedObjects ?? []
            let category = categories[indexPath.row]
            
            taskListVC.category = category
            taskListVC.title = category.name
        }
        
        navigationController?.pushViewController(taskListVC, animated: true)
    }
}

extension HomeVC {
    private func configureViewController() {
        self.title = "Get2It"
        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTaskButtonTapped))
        navigationItem.rightBarButtonItem = addBarButton
        
        collectionView.alwaysBounceVertical = true
    }
    
    private func addCategory() {
        let alert = UIAlertController(title: "Add a New Category", message: "Custom your own category", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Enter category name"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let textField = alert.textFields![0] as UITextField
            guard let stringTextField = textField.text else { return }
            
            let newCategory = CategoryRepresentation(name: stringTextField)
            self.categoryController.createCategoryOnServer(categoryRepresentation: newCategory) { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let category):
                    print(category)
                }
            }
        }
        
        alert.addAction(saveAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            print("Cancel")
        }
        
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func addTaskButtonTapped() {
        let addTaskVC = AddTaskVC()
        addTaskVC.taskController = taskController
        addTaskVC.categoryController = categoryController
        let navigationController = UINavigationController(rootViewController: addTaskVC)
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc func signOutTapped() {
        UserController.shared.signOut()
        self.dismiss(animated: true, completion: nil)
    }
}

extension HomeVC.SectionLayoutKind {
    var title: String? {
        switch self {
        case .list:
            return "Tasks"
        case . category:
            return "Categories"
        default:
            return nil
        }
    }
}

extension HomeVC: SectionHeaderReusableViewDelegate {
    func addCategoryPressed() {
        addCategory()
    }
}

extension HomeVC: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Cancel previous work item because there are two fetching controllers performing
        self.workItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.updateSnapshots()
        }
        self.workItem = workItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }
}

// MARK: - UNUserNotificationCenterDelagate
extension HomeVC: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
}

extension HomeVC {
    private func refreshNotificationList() {
        center.getPendingNotificationRequests { [weak self] requests in
            guard let self = self else { return }
            
            self.pending = requests
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        center.getDeliveredNotifications { [weak self] requests in
            guard let self = self else { return }
            
            self.delivered = requests
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
}
