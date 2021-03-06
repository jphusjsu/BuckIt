//
//  BuckitEditViewController.swift
//  BuckIt
//
//  Created by Samnang Sok on 4/5/18.
//  Copyright © 2018 Samnang Sok. All rights reserved.
//

import UIKit
import Firebase
class BuckitEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    var ref = FirebaseDataContoller.sharedInstance.refToFirebase
    let store = FirebaseDataContoller.sharedInstance.refToStorage
    var userStorage = StorageReference()
    
    var buckit = BuckIt()
    let picker = UIImagePickerController()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        userStorage = self.store.child("BuckIts")
    
        //round corners of buttons
        saveButton.layer.cornerRadius = 5
        deleteButton.layer.cornerRadius = 5
        selectButton.layer.cornerRadius = 3
        
        //maximize text input to 80 character
        descriptionText.delegate = self
        nameText.delegate = self
        fillActivityInfo()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    deinit {
        //stop listening for keyboard hide/show events
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func fillActivityInfo(){
        nameText.text! = buckit.title!
        descriptionText.text! = buckit.desc!
        CacheImage.getImage(withURL: URL(string: buckit.pathToImage!)!) { image in
            self.imageView.image = image
        }
//        imageView.downloadImage(from: buckit.pathToImage!)
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
        let newLength = text.count + string.count - range.length
        return newLength <= 45 // Bool
    }
    
    //Override the edit data to the database
    @IBAction func saveChange(_ sender: Any) {
        var emptyText: UIAlertController
        guard nameText.text != ""
            else {
                // alert the user when fields are empty
                if( (nameText.text?.isEmpty)!) {
                    emptyText = UIAlertController(title: "Error",
                                                  message: "Please fill in the Buckit name",
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    emptyText.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self.present(emptyText, animated: true)
                }
                return
        }
        let buid = buckit.buckitId
        let imageRef = self.userStorage.child("\(buid).jpg")
        let data = UIImageJPEGRepresentation(self.imageView.image!, 0.5)
        let usersReference = ref.child("BuckIts").child(buid!)
        
        let uploadTask = imageRef.putData(data!, metadata: nil, completion: { (metadata, err) in
            imageRef.downloadURL(completion: { (url, er) in
                if er != nil
                {
                    print(er!.localizedDescription)
                }
                if let url = url
                {
                    
                    let values = ["title": self.nameText.text,
                                  "pathToImage": url.absoluteString,
                    "description": self.descriptionText.text] as [String : Any]
                    usersReference.updateChildValues(values)
                    self.navigationController?.popToRootViewController(animated: true)
                }
            })
        })
    }
    
    //the bucket is being deleted from Firebase
    @IBAction func deleteBuckitPressed(_ sender: Any) {
        let buid = buckit.buckitId
        ref.child("BuckIts").child(buid!).removeValue()
        let vc = UIStoryboard(name: "TabController" , bundle: nil).instantiateViewController(withIdentifier: "tabBarVC")
        
        self.present(vc, animated: true, completion: nil)

    }
    
    //needed to dismiss the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameText.endEditing(true)
        descriptionText.endEditing(true)
    }
    
    //hide the keyboard function
    func hideKeyBoard()
    {
        descriptionText.resignFirstResponder()
        nameText.resignFirstResponder()
    }
    
    //return the textfield back to normal
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyBoard()
        
        return true
    }
    
    //push the UI up the keyboard is out
    @objc func keyboardWillChange(notification: Notification){
        //get the keyboard length
        guard let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        if notification.name == Notification.Name.UIKeyboardWillShow || notification.name == Notification.Name.UIKeyboardWillChangeFrame{
            view.frame.origin.y = -keyboardRect.height + 120
        } else
        {
            view.frame.origin.y = 0
        }
    }
    
}
