//
//  EditProfileViewController.swift
//  BuckIt
//
//  Created by Samnang Sok on 1/18/18.
//  Copyright © 2018 Samnang Sok. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {


    let picker = UIImagePickerController()
    @IBOutlet weak var imageView: UIImageView!

    
    @IBOutlet weak var descriptionText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    
    //draw line for the input field
    override func viewDidLayoutSubviews() {
        let border = CALayer()
        let border1 = CALayer()
        let border2 = CALayer()

        let width = CGFloat(2.0)
        border.borderColor = UIColor.darkGray.cgColor
        border1.borderColor = UIColor.darkGray.cgColor
        border2.borderColor = UIColor.darkGray.cgColor

        //line for name
        border.frame = CGRect(x: 0, y: nameText.frame.size.height - width, width:   nameText.frame.size.width, height: nameText.frame.size.height)
        
        border.borderWidth = width
        nameText.layer.addSublayer(border)
        nameText.layer.masksToBounds = true
        
        //line for userName
        border1.frame = CGRect(x: 0, y: userNameText.frame.size.height - width, width:   userNameText.frame.size.width, height: userNameText.frame.size.height)
        
        border1.borderWidth = width
        userNameText.layer.addSublayer(border1)
        userNameText.layer.masksToBounds = true
        
        //line for Email
        border2.frame = CGRect(x: 0, y: emailText.frame.size.height - width, width: emailText.frame.size.width, height: emailText.frame.size.height)
        
        border2.borderWidth = width
        emailText.layer.addSublayer(border2)
        emailText.layer.masksToBounds = true

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //maximize text input to 80 character
        descriptionText.delegate = self
        userNameText.delegate = self
        nameText.delegate = self
        emailText.delegate = self
        
        //retrieve data from Firebase
        let ref  = Database.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: {snapshot in
            let users = snapshot.value as! [String: AnyObject]
            
            for(_, value) in users {
                if let uid = value["uid"] as? String {
                    if uid == Firebase.Auth.auth().currentUser!.uid{
                        
                        self.nameText.text = value["name"] as? String
                        self.emailText.text = value["email"] as? String
                        //                        let databaseProfilePic = value["urlToImage"] as? String
                        //                        let data = NSData(contentsOf: NSURL(string: databaseProfilePic!)! as URL)
                        //                        self.setProfilePicture(imageView: self.profileImage, imageToSet: UIImage(data:data! as Data)!)
                    }
                }
            }
        })
        ref.removeAllObservers()
    }
    
    //change image
    @IBAction func changeImagePressed(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true, completion: nil)
    }
    
    //change image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            self.imageView.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    //maximize text input to 80 character
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 45 // Bool
    }
    
    @IBAction func saveChange(_ sender: Any) {
        
        
        
    }
}