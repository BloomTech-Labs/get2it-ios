//
//  SectionHeaderReusableView.swift
//  Get2It
//
//  Created by Vici Shaweddy on 6/8/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import UIKit

protocol SectionHeaderReusableViewDelegate: AnyObject {
    func addCategoryPressed()
}

// This means the section header view can be reused just like the cells
// This is for the Header List: Task and Category List
class SectionHeaderReusableView: UICollectionReusableView {
    static var reuseIdentifier: String {
        return String(describing: SectionHeaderReusableView.self)
    }
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layoutMargins = UIEdgeInsets(top: 20, left: 8, bottom: 8, right: 8)
        view.isLayoutMarginsRelativeArrangement = true
        view.spacing = 8
        return view
    }()
    
    // Setup the title label’s style
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.secondaryHeaderText
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.textAlignment = .left
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(
            .defaultHigh,
            for: .horizontal)
        return label
    }()
    
    lazy var addButton: UIButton = {
        let largeSize = UIImage.SymbolConfiguration(weight: .bold)
        let image = UIImage(systemName: "plus", withConfiguration: largeSize)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addPressed), for: .primaryActionTriggered)
        
        return button
    }()
    
    weak var delegate: SectionHeaderReusableViewDelegate?
    
    var hideAddButton = false {
        didSet {
            addButton.isHidden = hideAddButton
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func addPressed() {
        delegate?.addCategoryPressed()
    }
    
    private func setupStackView() {
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            self.stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            self.stackView.topAnchor.constraint(equalTo: topAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        // Add the title label to the header view and set up its Auto Layout constraints
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(addButton)
    }
}
