//
//  CategoryPickerCell.swift
//  Get2It
//
//  Created by John Kouris on 6/18/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import UIKit
import CoreData

protocol CategoryPickerCellDelegate: AnyObject {
    func didUpdate(category: Category?)
}

class CategoryPickerCell: UITableViewCell {
    static let reuseIdentifier = "CategoryPickerCell"
    
    weak var delegate: CategoryPickerCellDelegate?
    var categories = [Category]()
    var selectedCategory: Category?
    
    private lazy var fetchedCategoryController: NSFetchedResultsController<Category> = {
        let fetchRequest:NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: false)
        ]
        
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    lazy private var categoryPickerData: [[String]] = {
        updatePickerData()
    }()
    
    private func updatePickerData() -> [[String]] {
        do { try self.fetchedCategoryController.performFetch() } catch { fatalError() }
        let categories = fetchedCategoryController.fetchedObjects ?? []
        self.categories = categories
        let categoryItems = categories.map { $0.name ?? "" }
        let data: [[String]] = [categoryItems]
        return data
    }
    
    private func configurePickerView() {
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        categoryPicker.translatesAutoresizingMaskIntoConstraints = false
        
        categoryPicker.backgroundColor = .systemBackground
    }
    
    private lazy var mainStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layoutMargins = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        view.isLayoutMarginsRelativeArrangement = true
        view.spacing = 8
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        view.isLayoutMarginsRelativeArrangement = true
        view.spacing = 8
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Font.captionText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = Font.bodyText
        textField.inputView = self.categoryPicker
        textField.inputAccessoryView = self.toolbar
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Select Category"
        textField.textAlignment = .right
        return textField
    }()
    
    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // Creating flexible space
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // Creating Done button
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.dismissKeyboard))
        
        // Adding space and button to toolbar
        toolbar.setItems([flexibleSpace,doneButton], animated: false)
        
        return toolbar
    }()
    
    private lazy var categoryPicker: UIPickerView = {
        let categoryPicker = UIPickerView()
        categoryPicker.backgroundColor = .systemBackground

        return categoryPicker
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupStackView()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(with title: String, categories: [Category]) {
        configurePickerView()
        self.categories = categories
        titleLabel.text = title
        
        textField.text = self.selectedCategory?.name
    }
    
    @objc func dismissKeyboard() {
        self.textField.endEditing(true)
        self.delegate?.didUpdate(category: selectedCategory)
    }
    
    private func setupStackView() {
        contentView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(textField)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
}

extension CategoryPickerCell: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return categoryPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryPickerData[component].count
    }
}

extension CategoryPickerCell: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryPickerData[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 200
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let category = categories[row]
        self.selectedCategory = category
        textField.text = category.name
    }
}

extension CategoryPickerCell: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == self.fetchedCategoryController {
            
        }
    }
}
