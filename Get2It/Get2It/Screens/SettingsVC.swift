//
//  SettingsVC.swift
//  Get2It
//
//  Created by Vici Shaweddy on 6/22/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
    let signOutButton = GTButton(backgroundColor: Theme.primaryBlue, title: "Sign Out")
    
    private lazy var buttonStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layoutMargins = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        view.isLayoutMarginsRelativeArrangement = true
        view.spacing = 8
        view.distribution = .fillEqually
        view.alignment = .fill
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        layoutViews()
        configureButtons()
    }
    
    private func configureButtons() {
        signOutButton.setTitle("Sign Out", for: .normal)
        signOutButton.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
    }
    
    func layoutViews() {
        view.addSubviews(buttonStackView)
        buttonStackView.addArrangedSubview(signOutButton)
        
        NSLayoutConstraint.activate([
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            
            signOutButton.widthAnchor.constraint(equalTo: buttonStackView.widthAnchor),
            signOutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc func signOutTapped() {
        UserController.shared.signOut()
        self.dismiss(animated: true, completion: nil)
    }
}
