//
//  ViewController.swift
//  MessengerApp
//
//  Created by administrator on 03/01/2022.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
   
    @IBOutlet weak var emailAddressTf: UITextField!
    
    @IBOutlet weak var passwordTf: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
    }

    @IBAction func logInButtonClicked(_ sender: UIButton) {
        if let email = emailAddressTf.text,
           let password = passwordTf.text {
        // Firebase Login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { authResult, error in
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email \(email)")
                return
            }
            let user = result.user
            print("logged in user: \(user)")
        })
    }
      
    }
    @IBAction func registerBarButtonAction(_ sender: UIBarButtonItem) {
        let registerVC = storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        
        navigationController?.pushViewController(registerVC, animated: true)
    }
}

