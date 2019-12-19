//
//  SigninViewController.swift
//  Bopy
//
//  Created by bojack on 2019/12/19.
//  Copyright © 2019 bojack. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // signup action
    @IBAction func signupAction(_ sender: Any) {
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            let alertController = UIAlertController(
                                    title: "Error",
                                    message: "Please enter an email and password.",
                                    preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            print("emailTextField: " + emailTextField.text!)
            print("passwordTextField: " + passwordTextField.text!)
        }
    }
    
}
