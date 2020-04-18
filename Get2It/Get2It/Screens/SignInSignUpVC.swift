//
//  SignInSignUpVC.swift
//  Get2It
//
//  Created by John Kouris on 4/18/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import UIKit

class SignInSignUpVC: UIViewController {
    
    let usernameTextField = GTTextField()
    let passwordTextField = GTTextField()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        view.addSubviews(usernameTextField, passwordTextField)
        
        configureTextFields()
    }
    
    @objc func pushHomeVC() {
        passwordTextField.resignFirstResponder()
        
        let tabBar = GTTabBarController()
        tabBar.modalPresentationStyle = .fullScreen
        navigationController?.present(tabBar, animated: true, completion: nil)
    }
    
    func configureTextFields() {
        passwordTextField.returnKeyType = .go
        passwordTextField.delegate = self
        
        usernameTextField.placeholder = "username"
        passwordTextField.placeholder = "password"
        
        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SignInSignUpVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        pushHomeVC()
        return true
    }
}
