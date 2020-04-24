//
//  SignInSignUpVC.swift
//  Get2It
//
//  Created by John Kouris on 4/18/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import UIKit

class SignInSignUpVC: UIViewController {
    
    let displayNameTextField = GTTextField()
    let usernameTextField = GTTextField()
    let passwordTextField = GTTextField()
    let confirmPasswordTextField = GTTextField()
    let callToActionButton = GTButton(backgroundColor: .systemBlue, title: "Sign Up")
    let toggleStatusButton = UIButton(frame: .zero)
    
    var toggleStatus = false
    let padding: CGFloat = 50

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        view.addSubviews(displayNameTextField, usernameTextField, passwordTextField, confirmPasswordTextField, callToActionButton, toggleStatusButton)
        
        createDismissKeyboardTapGesture()
        configureTextFields()
        configureButtons()
    }
    
    func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    func configureTextFields() {
        let textFieldViews = [passwordTextField, confirmPasswordTextField, displayNameTextField, usernameTextField]
        
        passwordTextField.returnKeyType = .go
        confirmPasswordTextField.returnKeyType = .go
        
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        
        displayNameTextField.placeholder = "display name"
        usernameTextField.placeholder = "username"
        passwordTextField.placeholder = "password"
        confirmPasswordTextField.placeholder = "confirm password"
        
        for view in textFieldViews {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: padding),
                view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -padding),
            ])
        }
        
        NSLayoutConstraint.activate([
            displayNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            displayNameTextField.heightAnchor.constraint(equalToConstant: padding),
            
            usernameTextField.topAnchor.constraint(equalTo: displayNameTextField.bottomAnchor, constant: 20),
            usernameTextField.heightAnchor.constraint(equalToConstant: padding),
            
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.heightAnchor.constraint(equalToConstant: padding),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: padding)
        ])
    }
    
    func configureButtons() {
        toggleStatusButton.translatesAutoresizingMaskIntoConstraints = false
        toggleStatusButton.setTitle("Have an account? Sign In", for: .normal)
        toggleStatusButton.setTitleColor(.systemBlue, for: .normal)
        toggleStatusButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
        
        callToActionButton.addTarget(self, action: #selector(authenticateUserAndPushTabBarController), for: .touchUpInside)
        toggleStatusButton.addTarget(self, action: #selector(toggleSignIn), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            callToActionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            callToActionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            callToActionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            callToActionButton.heightAnchor.constraint(equalToConstant: padding),
            
            toggleStatusButton.topAnchor.constraint(equalTo: callToActionButton.bottomAnchor, constant: 10),
            toggleStatusButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            toggleStatusButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            toggleStatusButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    @objc func authenticateUserAndPushTabBarController() {
        if toggleStatus {
            guard let username = usernameTextField.text, !username.isEmpty,
                let password = passwordTextField.text, !password.isEmpty else {
                    let ac = UIAlertController(title: "Sign In Failed", message: "Please enter your username and password.", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(ac, animated: true, completion: nil)
                    return
            }
            
            let user = User(username: username, password: password)
            
            UserController.shared.signIn(with: user) { (error) in
                if let error = error {
                    print("Error signing in: \(error)")
                } else {
                    DispatchQueue.main.async {
                        let tabBar = GTTabBarController()
                        tabBar.modalPresentationStyle = .fullScreen
                        self.navigationController?.present(tabBar, animated: true, completion: nil)
                    }
                }
            }
            
        } else {
            guard let displayName = displayNameTextField.text, !displayName.isEmpty,
                let username = usernameTextField.text, !username.isEmpty,
                let password = passwordTextField.text, !password.isEmpty,
                let confirmedPassword = confirmPasswordTextField.text, !confirmedPassword.isEmpty else {
                    let ac = UIAlertController(title: "Sign Up Failed", message: "Please fill in all the fields before trying to sign up.", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(ac, animated: true, completion: nil)
                    return
            }
            
            guard confirmedPassword == password else {
                let ac = UIAlertController(title: "Error", message: "Passwords do not match. Please try again", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(ac, animated: true, completion: nil)
                return
            }
            
            let user = User(username: username, password: password)
            
            UserController.shared.signUp(with: user) { (error) in
                if let error = error {
                    print("Error signing up: \(error)")
                }
            }
            
            UserController.shared.signIn(with: user) { (error) in
                if let error = error {
                    print("Error signing in: \(error)")
                } else {
                    DispatchQueue.main.async {
                        let tabBar = GTTabBarController()
                        tabBar.modalPresentationStyle = .fullScreen
                        self.navigationController?.present(tabBar, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @objc func toggleSignIn() {
        toggleStatus.toggle()
        if toggleStatus {
            displayNameTextField.isHidden = true
            confirmPasswordTextField.isHidden = true
            toggleStatusButton.setTitle("No account? Sign Up", for: .normal)
            callToActionButton.setTitle("Sign In", for: .normal)
        } else {
            displayNameTextField.isHidden = false
            confirmPasswordTextField.isHidden = false
            toggleStatusButton.setTitle("Have an account? Sign In", for: .normal)
            callToActionButton.setTitle("Sign Up", for: .normal)
        }
    }

}

extension SignInSignUpVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        authenticateUserAndPushTabBarController()
        return true
    }
}
