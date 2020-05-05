//
//  EditTaskVC.swift
//  Get2It
//
//  Created by Vici Shaweddy on 4/24/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import UIKit

class EditTaskVC: UIViewController {
    let userController = UserController.shared
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    var taskController: TaskController?
    var task: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Edit Task"
        configureViewController()
        configureTableViewController()
    }
}

extension EditTaskVC {
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        let saveBarButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = saveBarButton

    }
    
    @objc private func saveButtonTapped() {
        guard let titleCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TaskInfoCell,
            let title = titleCell.title,
            !title.isEmpty,
            let dateCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TaskPickerCell,
            let startTimeCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? TaskPickerCell,
            let endTimeCell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? TaskPickerCell,
            let start = startTimeCell.textFieldString,
            let end = endTimeCell.textFieldString else
        {
            let alert = UIAlertController(title: "Missing some fields", message: "Check your information and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard let task = task else { return }
        
        task.name = title
        task.date = dateCell.date
        task.startTime = start
        task.endTime = end
        
        taskController?.updateTaskOnServer(task: task, completion: { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                DispatchQueue.main.async {
                    CoreDataStack.shared.save()
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        })
    }
    
    private func configureTableViewController() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TaskInfoCell.self, forCellReuseIdentifier: TaskInfoCell.reuseIdentifier)
        tableView.register(TaskPickerCell.self, forCellReuseIdentifier: TaskPickerCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension EditTaskVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskInfoCell.reuseIdentifier, for: indexPath) as? TaskInfoCell, let name = task?.name else {
                return UITableViewCell()
            }
            cell.title = name
            
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskPickerCell.reuseIdentifier, for: indexPath) as? TaskPickerCell, let date = task?.date else {
                return UITableViewCell()
            }
            cell.configure(with: "Date", date: date, cellType: .taskDate)
            
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskPickerCell.reuseIdentifier, for: indexPath) as? TaskPickerCell, let startTime = task?.startTime else {
                return UITableViewCell()
            }
            cell.configure(with: "Start Time", date: startTime, cellType: .startTime)
            
            return cell
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskPickerCell.reuseIdentifier, for: indexPath) as? TaskPickerCell, let endTime = task?.endTime else {
                return UITableViewCell()
            }
            cell.configure(with: "End Time", date: endTime, cellType: .endTime)
            
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension EditTaskVC: UITableViewDelegate {
    
}
