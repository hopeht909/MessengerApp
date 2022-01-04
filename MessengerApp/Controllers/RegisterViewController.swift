//
//  RegisterViewController.swift
//  MessengerApp
//
//  Created by administrator on 04/01/2022.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    
    @IBOutlet weak var firstNameTf: UITextField!
    @IBOutlet weak var lastNameTf: UITextField!
    @IBOutlet weak var emailAddressTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var imageviewProfile: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    // MARK: - Navigation
    @IBAction func registerButtonClicked(_ sender: UIButton) {
        if let password = passwordTf.text,
           let email = emailAddressTf.text {
            // Firebase Login / check to see if email is taken
            // try to create an account
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult , error  in
                guard let result = authResult, error == nil else {
                    print("Error creating user")
                    return
                }
                let user = result.user
                print("Created User: \(user)")
            })
        }
    }
    
}
// MARK: - Image Picker

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // get results of user taking picture or selecting from camera roll
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
    }
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // take a photo or select a photo
        
        // action sheet - take photo or choose photo
        picker.dismiss(animated: true, completion: nil)
        print(info)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.imageviewProfile.image = selectedImage
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}


