//
//  RegisterViewController.swift
//  MessengerApp
//
//  Created by administrator on 04/01/2022.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    @IBOutlet weak var firstNameTf: UITextField!
    @IBOutlet weak var lastNameTf: UITextField!
    @IBOutlet weak var emailAddressTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var imageviewProfile: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create Account"
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(self.presentPhotoActionSheet))
        imageviewProfile.isUserInteractionEnabled = true
        imageviewProfile.addGestureRecognizer(tapImage)
        passwordTf.delegate = self
        emailAddressTf.delegate = self
        imageviewProfile.layer.masksToBounds = true
        imageviewProfile.layer.cornerRadius = imageviewProfile.bounds.width / 2
        
    }
    // MARK: - registerButtonTapped
    @IBAction func registerButtonClicked(_ sender: UIButton) {
        registerButtonTapped()
    }
    
    func registerButtonTapped(){
        emailAddressTf.resignFirstResponder()
        passwordTf.resignFirstResponder()
        firstNameTf.resignFirstResponder()
        lastNameTf.resignFirstResponder()
        
        guard let password = passwordTf.text, let email = emailAddressTf.text,
              let firstName = firstNameTf.text, let lastName = lastNameTf.text,
              !email.isEmpty, !password.isEmpty, !firstName.isEmpty,
              !lastName.isEmpty else {
                  alertUserLoginError()
                  return
              }
        spinner.show(in: view)
        // Firebase Login / check to see if email is taken
        DatabaseManger.shared.userExists(with: email, completion: { [weak self] exists in
            //Prevent memory leak
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            guard !exists else {
                strongSelf.alertUserLoginError(message: "Looks like a user account for that email address already exists.")
                return
            }
            // try to create an account
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult , error  in
                guard authResult != nil, error == nil else {
                    print("Error creating user")
                    return
                }
                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
                
                let chatUser = ChatAppUser(firstName: firstName,
                                            lastName: lastName,
                                            emailAddress: email)
                DatabaseManger.shared.insertUser(with: chatUser) { success in
                    if success {
                        guard let image = strongSelf.imageviewProfile.image,
                              let data = image.pngData() else{
                            return
                        }
                        let fileName = chatUser.profilePictureFileName
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName,  completion: {result in
                            
                            switch result {
                            case .success(let downloadUrl):
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                print(downloadUrl)
                            case .failure(let error):
                                print("Storage Manager erroe \(error)")
                            }
                        })
                    }
                }
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
            
        })
    }
    func alertUserLoginError(message: String = "Please enter all information to log in.") {
        let alert = UIAlertController(title: "Warning",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Dismiss",
                                      style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
}
// MARK: - TextField Delegate

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailAddressTf {
            passwordTf.becomeFirstResponder()
        }
        else if textField == passwordTf {
            registerButtonTapped()
        }
        
        return true
    }
    
}
// MARK: - Image Picker

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // get results of user taking picture or selecting from camera roll
    
    
    @objc func presentPhotoActionSheet(){
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


