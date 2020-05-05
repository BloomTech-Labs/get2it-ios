//
//  TaskListVC.swift
//  Get2It
//
//  Created by Vici Shaweddy on 3/29/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import UIKit
import CoreData

class TaskListVC: UIViewController, UICollectionViewDelegate {
    
    enum ListModel: Hashable {
        case grid(Int)
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
    
    var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ListModel>!
    // TODO: - CHANGE THIS BACK TO AN OPTIONAL ONCE LISTS ARE IMPLEMENTED
    let taskController = TaskController()
    var tasksById: [Int: Task] = [:]
    var taskRepresentations: [TaskRepresentation] = []
    
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
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false),
            NSSortDescriptor(key: "startTime", ascending: true)
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
        
        do {
            try self.fetchedTaskController.performFetch()
            updateSnapshots()
        } catch {
            fatalError("frc crash")
        }
        
        taskController.fetchTasksFromServer { (result) in
            switch result {
            case .success(let representations):
                self.taskRepresentations = representations
                print(self.taskRepresentations)
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    func updateSnapshots() {
        let tasks = fetchedTaskController.fetchedObjects ?? []
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ListModel>()
        snapshot.appendSections([.grid, .list])
        
        let gridItems: [ListModel] = [.grid(1), .grid(2)]
        snapshot.appendItems(gridItems, toSection: .grid)
        
        let listItems: [ListModel] = tasks.map { ListModel.task(Task.Diffable(task: $0)) }
        snapshot.appendItems(listItems, toSection: .list)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension TaskListVC {
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTaskButtonTapped))
        navigationItem.rightBarButtonItem = addBarButton
    }
    
    @objc func addTaskButtonTapped() {
        let addTaskVC = AddTaskVC()
        addTaskVC.taskController = taskController
        let navigationController = UINavigationController(rootViewController: addTaskVC)
        present(navigationController, animated: true, completion: nil)
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
        
        if let items = dataSource.itemIdentifier(for: self.collectionView.indexPath(for: cell) ?? IndexPath()) {
            var snapshot = dataSource.snapshot()
            snapshot.deleteItems([items])
            dataSource.apply(snapshot, animatingDifferences: true)
            taskController.delete(task: taskRepresentations[itemIndex])
            taskRepresentations.remove(at: itemIndex)
        }
        
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ListModel>(collectionView: collectionView) {
            collectionView, indexPath, listModel -> UICollectionViewCell? in
            
            let section = SectionLayoutKind(rawValue: indexPath.section)!
            if section == .list {
                // Get a cell of the desired kind
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
                // Get a cell of the desired kind
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SummaryCell.reuseIdentifier, for: indexPath) as? SummaryCell {

                    cell.contentView.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
                    cell.contentView.layer.borderColor = UIColor.black.cgColor
                    cell.contentView.layer.borderWidth = 0.2
                    cell.contentView.layer.cornerRadius = section == .grid ? 10 : 0
                    
                    if listModel == .grid(1) {
                        cell.titleLabel.text = "Tasks"
                        cell.iconImage.image = UIImage(systemName: "list.bullet")
                        
                        cell.numberLabel.text = "\(self.taskRepresentations.count)"
                    } else {
                        cell.titleLabel.text = "Completed Tasks"
                        cell.iconImage.image = UIImage(systemName: "text.badge.checkmark")
                        
                        var completedTaskCount = 0
                        
                        for task in self.taskRepresentations {
                            if task.status == true {
                                completedTaskCount += 1
                                cell.numberLabel.text = "\(completedTaskCount)"
                            }
                        }
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
        
        let gridItems: [ListModel] = [.grid(1), .grid(2)]
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

        taskController.updateTaskOnServer(task: task, completion: { result in
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
