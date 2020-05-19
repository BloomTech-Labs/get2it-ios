//
//  SignInSignUpVC.swift
//  Get2It
//
//  Created by John Kouris on 4/18/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import UIKit

class SignInSignUpVC: UIViewController {
    let emailTextField = GTTextField()
    let displayNameTextField = GTTextField()
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
        view.addSubviews(emailTextField, displayNameTextField, passwordTextField, confirmPasswordTextField, callToActionButton, toggleStatusButton)
        
        createDismissKeyboardTapGesture()
        configureTextFields()
        configureButtons()
        
        // Delete anything when the user sign in
        TaskController.clearData()
    }
    
    func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    func configureTextFields() {
        let textFieldViews = [passwordTextField, confirmPasswordTextField, emailTextField, displayNameTextField]
        
        passwordTextField.returnKeyType = .go
        confirmPasswordTextField.returnKeyType = .go
        
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        
        emailTextField.placeholder = "email"
        displayNameTextField.placeholder = "display name"
        passwordTextField.placeholder = "password"
        confirmPasswordTextField.placeholder = "confirm password"
        displayNameTextField.autocapitalizationType = .none
        emailTextField.autocapitalizationType = .none
        
        for view in textFieldViews {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: padding),
                view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -padding),
            ])
        }
        
        NSLayoutConstraint.activate([
            displayNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            displayNameTextField.heightAnchor.constraint(equalToConstant: padding),
            
            emailTextField.topAnchor.constraint(equalTo: displayNameTextField.bottomAnchor, constant: 20),
            emailTextField.heightAnchor.constraint(equalToConstant: padding),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
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
            guard let password = passwordTextField.text, !password.isEmpty, password.count > 7,
                let email = emailTextField.text, !email.isEmpty else {
                    let ac = UIAlertController(title: "Sign In Failed", message: "Please enter your email and password.", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(ac, animated: true, completion: nil)
                    return
            }
            
            let user = User(displayName: nil, password: password, email: email)
            
            UserController.shared.signIn(user) { (error) in
                if let error = error {
                    print("Error signing in: \(error)")
                    DispatchQueue.main.async {
                        let ac = UIAlertController(title: "Sign In Failed", message: "Please enter your email and password.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(ac, animated: true, completion: nil)
                        return
                    }
                } else {
                    DispatchQueue.main.async {
                        // TODO: - CHANGE THIS BACK TO TABBAR ONCE LISTS GET IMPLEMENTED
                        let taskListNC = TaskListNC()
                        taskListNC.modalPresentationStyle = .fullScreen
                        self.navigationController?.present(taskListNC, animated: true, completion: nil)
                        
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                    }
                }
            }
            
        } else {
            guard let email = emailTextField.text, !email.isEmpty,
                let displayName = displayNameTextField.text, !displayName.isEmpty,
                let password = passwordTextField.text, !password.isEmpty, password.count > 7,
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
            
            let user = User(displayName: displayName, password: password, email: email)
            
            UserController.shared.signUp(with: user) { [weak self] (error) in
                if let error = error {
                    print("Error signing up: \(error)")
                    return
                }
                
                // signing in the user
                self?.signInWithUser(user)
            }
        }
    }
    
    func signInWithUser(_ user: User) {
        UserController.shared.signIn(user) { [weak self] (error) in
            if let error = error {
                print("Error signing in: \(error)")
                DispatchQueue.main.async {
                    let ac = UIAlertController(title: "Sign In Failed", message: "Please enter your email and password.", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(ac, animated: true, completion: nil)
                    return
                }
            } else {
                DispatchQueue.main.async {
                    // TODO: - CHANGE THIS BACK TO TABBAR ONCE LISTS GET IMPLEMENTED
                    let taskListNC = TaskListNC()
                    taskListNC.modalPresentationStyle = .fullScreen
                    self?.navigationController?.present(taskListNC, animated: true, completion: nil)
                    
                    self?.displayNameTextField.text = ""
                    self?.emailTextField.text = ""
                    self?.passwordTextField.text = ""
                    self?.confirmPasswordTextField.text = ""
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

// MARK: - REMOVE THIS ONCE LISTS WORK
class TaskListNC: UINavigationController {
    let userController = UserController.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        let taskListVC = TaskListVC()
        let displayName = userController.authenticatedUser?.displayName ?? ""
        taskListVC.title = "Welcome \(displayName)!"
        viewControllers = [taskListVC]
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }

}
