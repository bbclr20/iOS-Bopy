//
//  ViewController.swift
//  Bopy
//
//  Created by bojack on 2019/12/19.
//  Copyright © 2019 bojack. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
         self.hideKeyboardWhenTappedAround() 
    }

    // login action
    @IBAction func loginAction(_ sender: Any) {
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            print("empty email or password")
        } else {
            print("emailTextField: " + emailTextField.text!)
            print("passwordTextField: " + passwordTextField.text!)
        }
    }
    
}
