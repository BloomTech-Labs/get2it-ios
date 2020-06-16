//
//  UIAlertController+Ext.swift
//  Get2It
//
//  Created by Vici Shaweddy on 5/22/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import UIKit

extension UIAlertController {
    class func okWithMessage(_ message: String, presentingViewController: UIViewController, completion: (() -> Void)? = nil, onOK: ((UIAlertAction?) -> Void)? = nil)
    {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addOKButton(onOK)
        presentingViewController.present(alert, animated: true, completion: completion)
    }

    class func cancelWithMessage(_ message: String, presentingViewController: UIViewController?, completion: (() -> Void)? = nil, onOK: ((UIAlertAction?) -> Void)? = nil) {
        if let presentingViewController = presentingViewController {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

            alert.addOKButton(onOK)
            alert.addCancelButton()

            presentingViewController.present(alert, animated: true, completion: completion)
        }
    }

    func addCancelButton() {
        let cancel = NSLocalizedString("Cancel", comment: "The cancel button")
        self.addAction(UIAlertAction(title: cancel, style: .cancel, handler: nil))
    }

    func addOKButton(_ handler: ((UIAlertAction?) -> Void)? = nil) {
        let ok = NSLocalizedString("OK", comment: "The OK button")
        self.addAction(UIAlertAction(title: ok, style: .default, handler: handler))
    }

    func addCancelOKButtons(_ handler: ((UIAlertAction?) -> Void)? = nil) {
        addCancelButton()
        addOKButton(handler)
    }
}

