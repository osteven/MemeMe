//
//  EditMemeViewController.swift
//  MemeMeV1
//
//  Created by Steven O'Toole on 3/20/15.
//  Copyright (c) 2015 Steven O'Toole. All rights reserved.
//
// note: to add text as subviews to the image view, follow this:
// http://stackoverflow.com/questions/2415561/apple-interface-builder-adding-subview-to-uiimageview


import UIKit

class EditMemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // MARK: -
    // MARK: Properties
    var currentMeme: Meme? = nil
    var memeManager: MemeManager? = nil
    let VERTICAL_MARGIN: CGFloat = 2.0


    // MARK: -
    // MARK: Outlets

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topMemeText: UITextField!
    @IBOutlet weak var bottomMemeText: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!



    // MARK: -
    // MARK: Load & Dismiss Actions
    override func viewDidLoad() {
        super.viewDidLoad()

        assert(memeManager != nil, "Need to set memeManager in EditMemeViewController")
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        saveButton.enabled = false
        topMemeText.delegate = self
        bottomMemeText.delegate = self

        topMemeText.backgroundColor = UIColor.clearColor()
        bottomMemeText.backgroundColor = UIColor.clearColor()
        let memeTextAttributes = [NSStrokeColorAttributeName: UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: Float(-3.0)]        // sign needed to indicate fill
        topMemeText.defaultTextAttributes = memeTextAttributes
        bottomMemeText.defaultTextAttributes = memeTextAttributes

        topMemeText.textAlignment = .Center;
        bottomMemeText.textAlignment = .Center;

        // turn off Predictive Text because it does not work reliably with uppercase fields
        topMemeText.autocorrectionType = .No;
        bottomMemeText.autocorrectionType = .No;

        if let meme = currentMeme {
            topMemeText.text = meme.topString
            bottomMemeText.text = meme.bottomString
        } else {
            topMemeText.text = "TOP"
            bottomMemeText.text = "BOTTOM"
        }
        // resize the image view so the top and bottom text fields are positioned nicely
        let availableHeight = self.view.bounds.size.height - self.toolBar.bounds.size.height - self.topToolbar.bounds.size.height - VERTICAL_MARGIN
        dispatch_async(dispatch_get_main_queue(), { self.resizeImageView(availableHeight) })
    }


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotificiations()
    }



    override func prefersStatusBarHidden() -> Bool {
        return true
    }


    @IBAction func doCancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func doSave(sender: UIBarButtonItem) {
        let memeImage = generateMemedImage()
        let shareArray = [memeImage]
        let activityVC = UIActivityViewController(activityItems: shareArray, applicationActivities: nil)

        activityVC.completionWithItemsHandler = { activity, success, items, error in
            if success {
                self.saveSentMeme(memeImage)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        self.presentViewController(activityVC, animated: true, completion: nil)
     }

    private func saveSentMeme(memeImage: UIImage) {
        if let meme = currentMeme {
            // editing a sent meme
            meme.topString = topMemeText.text
            meme.bottomString = bottomMemeText.text
            meme.originalImage = imageView.image
            meme.memedImage = memeImage
        } else {
            // new meme
            currentMeme = Meme(top: topMemeText.text, bottom: bottomMemeText.text)
            currentMeme!.originalImage = imageView.image
            currentMeme!.memedImage = memeImage
            memeManager!.appendMeme(currentMeme!)
        }
    }


    private func generateMemedImage() -> UIImage {
        toolBar.hidden = true

        // Render view to an image
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.drawViewHierarchyInRect(imageView.bounds, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        toolBar.hidden = false
        return memedImage
    }


    // MARK: -
    // MARK: Text delegate & management
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == topMemeText && textField.text == "TOP" {
            textField.text = ""
        } else if textField == bottomMemeText && textField.text == "BOTTOM" {
            textField.text = ""
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // Construct the text that will be in the field if this change is accepted
        var newText = textField.text as NSString
        newText = newText.stringByReplacingCharactersInRange(range, withString: string).uppercaseString

        textField.text = newText
        saveButton.enabled = readyForSave()
        return false
    }

    private func readyForSave() -> Bool {
        var s = topMemeText.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if s == "TOP" || s == "" { return false }
        s = bottomMemeText.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if s == "BOTTOM" || s == "" { return false }
        return imageView.image != nil
    }

    func keyboardWillShow(notification: NSNotification) {
        if bottomMemeText.isFirstResponder() {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        if bottomMemeText.isFirstResponder() {
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }

    private func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    private func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        if let userInfo = notification.userInfo {
            if let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                return keyboardSize.CGRectValue().height
            }
        }
        return 0
    }

    private func unsubscribeFromKeyboardNotificiations() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }


    // MARK: -
    // MARK: UImage Picker support
    @IBAction func getImageAction(sender: UIBarButtonItem) {
        if let choice = sender.title {

            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            if choice == "Album" {
                pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            } else {
                pickerController.sourceType = UIImagePickerControllerSourceType.Camera
            }
            self.presentViewController(pickerController, animated: true, completion: nil)
        }
    }

    /* Resize the image view when user goes switches between portrait and landscape.  This also will
    re-position the top and bottom text fields.
    Source ideas:
    http://www.shinobicontrols.com/blog/posts/2014/08/06/ios8-day-by-day-day-14-rotation-deprecation
    */
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        let availableHeight = size.height - self.toolBar.bounds.size.height - self.topToolbar.bounds.size.height - VERTICAL_MARGIN
        if let image = self.imageView.image {
            self.calcScaleforImageToResizeImageView(image, inMaxHeight: availableHeight, inMaxWidth: size.width)
        } else {
            dispatch_async(dispatch_get_main_queue(), { self.resizeImageView(availableHeight) })
        }
    }



    private func resizeImageView(newheight: CGFloat) {
        self.imageViewHeightConstraint.constant = newheight
        self.view.layoutIfNeeded()
    }


    private func calcScaleforImageToResizeImageView(image: UIImage, inMaxHeight: CGFloat, inMaxWidth: CGFloat) {
        let ratio = inMaxWidth / image.size.width
        var newheight = ratio * image.size.height

        // don't let the new height get too big or the bottom text falls below the toolbar
        if newheight > inMaxHeight { newheight = inMaxHeight }
        dispatch_async(dispatch_get_main_queue(), { self.resizeImageView(newheight) })
    }



    // http://stackoverflow.com/questions/16878607/change-uiimageview-size-to-match-image-with-autolayout
    // http://stackoverflow.com/questions/8701751/uiimageview-change-size-to-image-size
    internal func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: nil)

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageView.image = image
            saveButton.enabled = readyForSave()
            let availableHeight = self.view.bounds.size.height - self.toolBar.bounds.size.height - self.topToolbar.bounds.size.height - VERTICAL_MARGIN
            self.calcScaleforImageToResizeImageView(image, inMaxHeight: availableHeight, inMaxWidth: imageView.bounds.size.width)
        }
    }


    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }


}
