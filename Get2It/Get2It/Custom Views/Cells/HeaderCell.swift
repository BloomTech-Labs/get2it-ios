//
//  HeaderCell.swift
//  Get2It
//
//  Created by John Kouris on 4/3/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import UIKit

class HeaderCell: UICollectionViewCell {
    static let reuseIdentifier = "HeaderCell"
    
    private lazy var mainStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layoutMargins = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        view.isLayoutMarginsRelativeArrangement = true
        view.spacing = 4
        view.distribution = .equalSpacing
        view.alignment = .leading
        return view
    }()
    
    private lazy var iconImage: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = UIColor(red: 5/255, green: 91/255, blue: 195/255, alpha: 1)
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .white
        return view
    }()
    
    private lazy var greetingLabel: UILabel = {
        let label = UILabel()
        label.font = Font.bodyText
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = Font.subcaptionText
        label.textColor = .white
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMainStackView()
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupMainStackView() {
        contentView.addSubview(self.mainStackView)
        mainStackView.addArrangedSubview(iconImage)
        mainStackView.addArrangedSubview(greetingLabel)
        mainStackView.addArrangedSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configureViews() {
        greetingLabel.text = "Greetings \(UserController.shared.authenticatedUser?.displayName ?? "")!"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateLabel.text = "\(dateFormatter.string(from: Date()))"
        
        iconImage.image = UIImage(systemName: "sun.max.fill")
    }
}
