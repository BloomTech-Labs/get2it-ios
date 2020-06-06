//
//  HomeVC.swift
//  Get2It
//
//  Created by John Kouris on 3/28/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import UIKit

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
    
    let taskController = TaskController()
    var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ListModel>!
    var collectionView: UICollectionView! = nil

//    var lists: [String] = ["Today", "Tomorrow", "Someday", "Past"]
//    var categories: [String] = ["Personal", "Work"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        configureHierarchy()
        configureDataSource()
        configureViewController()
    }
    
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createHomeLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(HeaderCell.self, forCellWithReuseIdentifier: HeaderCell.reuseIdentifier)
        collectionView.register(SummaryCell.self, forCellWithReuseIdentifier: SummaryCell.reuseIdentifier)
        collectionView.register(HomeListCell.self, forCellWithReuseIdentifier: HomeListCell.reuseIdentifier)
        collectionView.register(HomeListCell.self, forCellWithReuseIdentifier: HomeListCell.reuseIdentifier)
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ListModel>(collectionView: collectionView) {
            (collectionView:UICollectionView, indexPath: IndexPath, model: ListModel) -> UICollectionViewCell? in
            
            let section = SectionLayoutKind(rawValue: indexPath.section)!
            
            if section == .list {
                // Get a cell of the desired kind
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeListCell.reuseIdentifier, for: indexPath) as? HomeListCell {
                    if case .list(let name) = model {
                        cell.label.text = name
                    }

                    return cell
                } else {
                    fatalError("Can't create new cell")
                }
            } else if section == .grid {
                // Get a cell of the desired kind
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SummaryCell.reuseIdentifier, for: indexPath) as? SummaryCell {
                    
                    cell.contentView.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
                    cell.contentView.layer.borderColor = UIColor.black.cgColor
                    cell.contentView.layer.borderWidth = 0.2
                    cell.contentView.layer.cornerRadius = section == .grid ? 10 : 0
                    
                    // Return the cell
                    return cell
                } else {
                    fatalError("Can't create new cell")
                }
            } else if section == .category {
                // Get a cell of the desired kind
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeListCell.reuseIdentifier, for: indexPath) as? HomeListCell {
                    if case .category(let name) = model {
                        cell.label.text = name
                    }

                    return cell
                } else {
                    fatalError("Can't create new cell")
                }
            } else {
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
        
        // Initial data
        var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ListModel>()
        snapshot.appendSections([.header, .grid, .list, .category])
        snapshot.appendItems([.header], toSection: .header)
        
        let gridItems: [ListModel] = [.grid(.tasks()), .grid(.completedTasks())]
        snapshot.appendItems(gridItems, toSection: .grid)
        
        let listItems: [ListModel] = [.list(name: "Today"), .list(name: "Tomorrow"), .list(name: "Someday"), .list(name: "Past")]
        snapshot.appendItems(listItems, toSection: .list)
        
        let categoryItems: [ListModel] = [.category(name: "Personal")]
        snapshot.appendItems(categoryItems, toSection: .category)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let _ = dataSource.itemIdentifier(for: indexPath) else { return }
        // TODO: - Add an initialzer that will accept a list and populate the taskVC with the tasks from that list
        let taskListVC = TaskListVC()
//        taskListVC.taskController = taskController
        taskListVC.title = "Task List"
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
        
        let signOutBarButton = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOutTapped))
        navigationItem.leftBarButtonItem = signOutBarButton
        
        collectionView.alwaysBounceVertical = true
    }
    
    @objc func addTaskButtonTapped() {
        let addTaskVC = AddTaskVC()
        addTaskVC.taskController = taskController
        let navigationController = UINavigationController(rootViewController: addTaskVC)
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc func signOutTapped() {
        UserController.shared.signOut()
        self.dismiss(animated: true, completion: nil)
    }
}
