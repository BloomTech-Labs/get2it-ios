//
//  ListCell.swift
//  Get2It
//
//  Created by Vici Shaweddy on 3/30/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import UIKit

class HomeListCell: UICollectionViewCell {
    static let reuseIdentifier = "HomeListCell"
    let label = UILabel()
    let accessoryImageView = UIImageView()
    let seperatorView = UIView()
    let iconImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
        layoutUIElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    private func configureViews() {
        contentView.addSubviews(seperatorView, label, accessoryImageView, iconImageView)
        
        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        accessoryImageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundColor = .systemBackground
        seperatorView.backgroundColor = .lightGray
        
        label.adjustsFontForContentSizeCategory = true
        label.font = Font.bodyText
        
        let rtl = effectiveUserInterfaceLayoutDirection == .rightToLeft
        let chevronImageName = rtl ? "chevron.left" : "chevron.right"
        let chevronImage = UIImage(systemName: chevronImageName)
        accessoryImageView.image = chevronImage
        accessoryImageView.tintColor = UIColor.lightGray.withAlphaComponent(0.7)
        
        iconImageView.image = UIImage(systemName: "calendar")
    }
    
    private func layoutUIElements() {
        let inset = CGFloat(10)
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            iconImageView.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -inset),
            iconImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            
            label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: inset),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset),
            label.trailingAnchor.constraint(equalTo: accessoryImageView.leadingAnchor, constant: -inset),
            
            accessoryImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            accessoryImageView.widthAnchor.constraint(equalToConstant: 13),
            accessoryImageView.heightAnchor.constraint(equalToConstant: 20),
            accessoryImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            
            seperatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            seperatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            seperatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            seperatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}
