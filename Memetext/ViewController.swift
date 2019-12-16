//
//  ViewController.swift
//  Memetext
//
//  Created by Hajar F on 9/29/19.
//  Copyright © 2019 Hajar F. All rights reserved.
//

import UIKit


class MemeEditorViewController: UIViewController ,UIImagePickerControllerDelegate , UINavigationControllerDelegate , UITextFieldDelegate{
    
    
    // MARK :IBOutlet
    
    // IBOutlet for Tool Bar
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    // IBOutlet for Navigation Controller
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    // IBOutlet for Text
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    // IBOutlet for image
    @IBOutlet weak var imagePickerView: UIImageView!
    // IBOutlet for  Toolbar
    @IBOutlet weak var toolbar: UIToolbar!
    
    
    // MARK :viewDidLoad
    override func viewDidLoad() {
        
        super.viewDidLoad()
        

        //disabled share button until select image
        shareButton.isEnabled = false
        
        //check if camera is not available  ?
        if !(UIImagePickerController.isSourceTypeAvailable(.camera)) {
            
            cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        }
        
        //Text field Attributes
        configure(textField: topText , withText :"TOP")
        configure(textField: bottomText , withText:"BOTTOM")
        
    }
    
    // MARK :viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
           
           super.viewWillAppear(animated)
           subscribeToKeyboardNotifications()
       }
    
    // MARK :viewWillDisappear
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK :Text field Attributes
    func configure(textField:UITextField, withText text : String)
    {
        //paragraph Alignment
        let paragraphStyle=NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        // Text field Attributes
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor :UIColor.black ,
            NSAttributedString.Key.foregroundColor : UIColor.white ,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth: -3.0,
            NSAttributedString.Key.paragraphStyle : paragraphStyle
            
        ]
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.text = text
        textField.delegate = self
    }
    
    
    
    //MARK: image Picker display
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imagePickerView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        shareButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: image Picker Cancel
    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: keyboard
    
    // Function keyboard Show
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomText.isFirstResponder {
            view.frame.origin.y = -(keyboardHeight(notification))
        }
        
    }
    
    // Function keyboard Hide
    @objc func keyboardWillHide(_ notification:Notification) {
        if bottomText.isFirstResponder {
            view.frame.origin.y = 0
        }
    }
    
    // Function keyboard Height
    func keyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    // Function  subscribe keyboard Notifications
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    // Function  unsubscribe keyboard Notifications
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
        
    }
    
    //MARK:Hide or Show Toolbar and Notification bar
    func hideTopBottomBars(_ hide: Bool)
    {
        navigationController?.navigationBar.isHidden = hide
        toolbar.isHidden = hide
        
    }
    
    //MARK:  When a user taps textfield, the default text should clear.
    func textFieldDidBeginEditing(_ textField: UITextField){
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text=""
        }
    }
    
    // MARK: When a user presses return, the keyboard should be dismissed
    func textFieldShouldReturn (_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
    
    // MARK: Function  generateMemedImage
    func generateMemedImage() -> UIImage {
        //Hide Toolbar and Notification bar
        hideTopBottomBars(true)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //Show Toolbar and Notification bar
        hideTopBottomBars( false)
        
        
        return memedImage
    }
    
    
    //MARK : save new image after edit
    func save() {
        // Create the meme
        _ = Meme(top: topText.text, bottom: bottomText.text, image:imagePickerView.image!, memedImage:generateMemedImage())
        
    }
    
    //MARK : Action Album Button
    func chooseImage(source: UIImagePickerController.SourceType) {
        
        if imagePickerView.image  != nil {
            topText.text = "TOP"
            bottomText.text = "BOTTOM"
        }
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    
    // MARK : Action function
    
    //MARK : Action Album Button
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        chooseImage( source: .photoLibrary )
        
    }
    
    //MARK : Action camera Button
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        chooseImage(source: .camera )
        
    }
    
    //MARK : Action Share Button
    @IBAction func shareImage(_ sender: Any) {
        
        let memedImage = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        //CompletionWithItemsHandler = (UIActivity.ActivityType?, Bool, [Any]?, Error?) -> Void
        
        activityController.completionWithItemsHandler = { activity, success, items, error in
            if success {self.save()}
            
            self.dismiss(animated: true, completion: nil)
        }
        
        present(activityController, animated: true   )
        
    }
    
    //MARK : Action cancel Button
    @IBAction func cancelImage(_ sender: Any) {
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        imagePickerView.image = nil
       shareButton.isEnabled = false
    }
    
    
}

