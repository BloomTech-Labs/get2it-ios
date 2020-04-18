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
        signInSignUpVC.title = "Welcome!"
        viewControllers = [signInSignUpVC]
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
