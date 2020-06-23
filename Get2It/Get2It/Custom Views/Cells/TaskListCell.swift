//
//  TaskListCell.swift
//  Get2It
//
//  Created by Vici Shaweddy on 4/8/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import UIKit

protocol TaskListCellDelegate: AnyObject {
    func cellDidToggle(isChecked: Bool, for task: Task?)
}

class TaskListCell: UICollectionViewCell {
    weak var delegate: TaskListCellDelegate?
    var task: Task?
    
    static let reuseIdentifier = "TaskListCell"
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        return dateFormatter
    }()
    
    private lazy var mainStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 8
        return view
    }()
    
    private lazy var innerStackView: UIStackView = {
         let view = UIStackView()
         view.axis = .horizontal
         view.translatesAutoresizingMaskIntoConstraints = false
         view.spacing = 8
        view.alignment = .center
         return view
     }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var checkButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(checkButtonDidPress), for: .primaryActionTriggered)
        return button
    }()
    
    private lazy var titleLabel: UILabel = { // Name of the task
        let label = UILabel()
        label.font = Font.bodyText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateLabel: UILabel = { // Date
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.captionText
        label.textColor = .gray
        return label
    }()
    
    private lazy var timeLabel: UILabel = { // Time
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.captionText
        label.textColor = .gray
        return label
    }()
    
    private lazy var circleBar: CircleView = {
        let view = CircleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var seperatorView: UIView = {
        let seperator = UIView()
        seperator.translatesAutoresizingMaskIntoConstraints = false
        seperator.backgroundColor = .lightGray
        
        return seperator
    }()
    
    private lazy var chevronImage: UIImageView = {
        let chevron = UIImageView()
        chevron.translatesAutoresizingMaskIntoConstraints = false
        
        return chevron
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMainStackView()
        setupInnerStackView()
        setupClearButton()
        setupCircleBar()
        setupStackView()
        setupSeperatorView()
        setupChevronImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    func configure(with task: Task?) {
        self.task = task

        if let startTime = task?.startTime,
            let endTime = task?.endTime,
            let date = task?.date {
            self.timeLabel.text = "\(startTime) - \(endTime)"
            self.dateLabel.text = dateFormatter.string(from: date)
        }
        
        circleBar.isChecked = task?.status == true
        updateStrikethrough()
    }
    
    @objc func checkButtonDidPress() {
        circleBar.isChecked.toggle()
        
        // change the label color
        updateStrikethrough()
        
        delegate?.cellDidToggle(isChecked: circleBar.isChecked, for: task)
    }
    
    func updateStrikethrough() {
        guard let title = self.task?.name else {
            return
        }
        
        let attributeString = NSMutableAttributedString(string: title)
        if circleBar.isChecked == true {
           attributeString.addAttribute(.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        }
        
        self.titleLabel.attributedText = attributeString
    }
    
    // MARK: - Private
    
    private func setupMainStackView() {
        contentView.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func setupClearButton() {
        contentView.addSubview(checkButton)
        
        NSLayoutConstraint.activate([
            checkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            checkButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            checkButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            checkButton.widthAnchor.constraint(equalTo: checkButton.heightAnchor, multiplier: 1.0)
        ])
    }
    
    private func setupInnerStackView() {
        mainStackView.addArrangedSubview(innerStackView)
    }

    private func setupCircleBar() {
        innerStackView.addArrangedSubview(circleBar)
    }
    
    private func setupStackView() {
        innerStackView.addArrangedSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(timeLabel)
        stackView.addArrangedSubview(dateLabel)
    }
    
    private func setupSeperatorView() {
        mainStackView.addArrangedSubview(seperatorView)
        
        NSLayoutConstraint.activate([
            seperatorView.heightAnchor.constraint(equalToConstant: 0.5),
            seperatorView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor)
        ])
    }
    
    private func changeLabelColor() {
        titleLabel.textColor = .gray
    }
    
    private func setupChevronImage() {
        innerStackView.addArrangedSubview(self.chevronImage)
        
        let rtl = effectiveUserInterfaceLayoutDirection == .rightToLeft
        let chevronImageName = rtl ? "chevron.left" : "chevron.right"
        let chevronImage = UIImage(systemName: chevronImageName)
        self.chevronImage.image = chevronImage
        self.chevronImage.tintColor = UIColor.lightGray.withAlphaComponent(0.7)

        NSLayoutConstraint.activate([
            self.chevronImage.widthAnchor.constraint(equalToConstant: 13)
        ])
    }
}
