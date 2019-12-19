//
//  ViewController.swift
//  Bopy
//
//  Created by bojack on 2019/12/19.
//  Copyright © 2019 bojack. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.hideKeyboardWhenTappedAround()
    }

    // login action
    @IBAction func loginAction(_ sender: Any) {
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
          let alertController = UIAlertController(title: "Error",
                message: "Please enter an email and password.", preferredStyle: .alert)
           
           let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
           alertController.addAction(defaultAction)
           
           self.present(alertController, animated: true, completion: nil)

        } else {
            Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
       
               if error == nil {
                   // go to the MainpageViewController if the login is sucessful
                   let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainPage")
                   self.present(vc!, animated: true, completion: nil)
               } else {
                   let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                   let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                   alertController.addAction(defaultAction)
                   self.present(alertController, animated: true, completion: nil)
               }
            }
        }
    } // loginAction
    
}
