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
        
        self.title = "Log In"
        emailAddressTf.delegate = self
        passwordTf.delegate = self
    
    }
    
    // MARK: - Navigation
    @IBAction func logInButtonClicked(_ sender: UIButton) {
        loginButtonTapped()
    }
    
    func loginButtonTapped(){
        
        emailAddressTf.resignFirstResponder()
        passwordTf.resignFirstResponder()
        
        guard let email = emailAddressTf.text,
              let password = passwordTf.text, !email.isEmpty, !password.isEmpty else {
                  alertUserLoginError()
                  return
              }
        // Firebase Login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                    return
            }

            guard let result = authResult, error == nil else {
                print("Failed to log in user with email \(email)")
                return
            }
            let user = result.user
            print("logged in user: \(user)")
            // if this succeeds, dismiss
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
      
    
    func alertUserLoginError() {
           let alert = UIAlertController(title: "Warning",
                                         message: "Please enter all information to log in.",
                                         preferredStyle: .alert)
           alert.addAction(UIAlertAction(title:"Dismiss",
                                         style: .cancel, handler: nil))
           present(alert, animated: true)
       }

    @IBAction func registerBarButtonAction(_ sender: UIBarButtonItem) {
        let registerVC = storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        
        navigationController?.pushViewController(registerVC, animated: true)
    }
}
// MARK: - TextField Delegate
extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField == emailAddressTf {
            passwordTf.becomeFirstResponder()
        }
        else if textField == passwordTf {
            loginButtonTapped()
        }

        return true
    }

}

