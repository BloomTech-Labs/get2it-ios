//
//  SignInSignUpNC.swift
//  Get2It
//
//  Created by John Kouris on 4/18/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import UIKit

class SignInSignUpNC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let signInSignUpVC = SignInSignUpVC()
        viewControllers = [signInSignUpVC]
    }

}
