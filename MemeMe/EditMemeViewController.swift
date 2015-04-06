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
    private let VERTICAL_MARGIN: CGFloat = 2.0
    private let memeManager = (UIApplication.sharedApplication().delegate as AppDelegate).memeManager


    // MARK: -
    // MARK: Outlets

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topMemeText: UITextField!
    @IBOutlet weak var bottomMemeText: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cameraButton: UIBarButtonItem!



    // MARK: -
    // MARK: Class function
    /*
    Edit view controller knows how to present itself in a class function.  This eliminates duplicate code
    between the list and the grid views
    */
    class func presentForAddingOrEditingMeme(sourceController: UIViewController, editMeme: Meme? = nil) {
        sourceController.editing = false
        let editController = sourceController.storyboard!.instantiateViewControllerWithIdentifier("MemeEditViewController")! as EditMemeViewController
        editController.currentMeme = editMeme
        sourceController.presentViewController(editController, animated: true, completion: nil)
    }



    // MARK: -
    // MARK: Load & Dismiss Actions
    override func viewDidLoad() {
        super.viewDidLoad()

        //       assert(memeManager != nil, "Need to set memeManager in EditMemeViewController")
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
            if let i = meme.originalImage { imageView.image = i }
        } else {
            topMemeText.text = "TOP"
            bottomMemeText.text = "BOTTOM"
        }
        // resize the image view so the top and bottom text fields are positioned nicely
        self.calcScaleforImageToResizeImageView(self.imageView.image, inMaxHeight: self.getAvailableHeight(),
            inMaxWidth: getActualWidth(self.view))
    }


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotificiations()
    }


    // There's more room for the image if you hide the status bar.  If this is not set
    // to true, have to change getAvailableHeight() to subtract the height of the status bar
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
            memeManager.appendMeme(currentMeme!)
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
    // MARK: UIImage Picker support
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

    // http://stackoverflow.com/questions/16878607/change-uiimageview-size-to-match-image-with-autolayout
    // http://stackoverflow.com/questions/8701751/uiimageview-change-size-to-image-size
    internal func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: nil)

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageView.image = image
            saveButton.enabled = readyForSave()
            self.calcScaleforImageToResizeImageView(image, inMaxHeight: getAvailableHeight(), inMaxWidth: imageView.bounds.size.width)
        }
    }


    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }


    // MARK: -
    // MARK: Resize UIImageView for best fit of UIImage in available space

    /* Resize the image view when user goes switches between portrait and landscape.  This also will
    re-position the top and bottom text fields.
    Source ideas:
    http://www.shinobicontrols.com/blog/posts/2014/08/06/ios8-day-by-day-day-14-rotation-deprecation
    */
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        let availableHeight = getAvailableHeight(size.height)
        if let image = self.imageView.image {
            self.calcScaleforImageToResizeImageView(image, inMaxHeight: availableHeight, inMaxWidth: size.width)
        } else {
            dispatch_async(dispatch_get_main_queue(), { self.resizeImageView(availableHeight) })
        }
    }



    private func getActualWidth(inView: UIView) -> CGFloat {
        var realWidth: CGFloat = (UIScreen.mainScreen().bounds.height > UIScreen.mainScreen().bounds.width) ? UIScreen.mainScreen().bounds.size.width : UIScreen.mainScreen().bounds.size.height
        return realWidth
    }


    // most of the time, we just need to start out with the view bounds, but on a rotate, we'll need the incoming size
    private func getAvailableHeight() -> CGFloat {
        // it looks like the view bounds height and width don't swap anymore when you change orientation
        // I don't know how best to get the available height when we are rotated, so just use the screen bounds which does swap
       return getAvailableHeight(UIScreen.mainScreen().bounds.size.height)
    }

    private func getAvailableHeight(rawHeight: CGFloat) -> CGFloat {
        return rawHeight - self.toolBar.bounds.size.height - self.topToolbar.bounds.size.height - VERTICAL_MARGIN
    }

    private func resizeImageView(newheight: CGFloat) {
        self.imageViewHeightConstraint.constant = newheight
        self.view.layoutIfNeeded()
    }


    // if we have an image, scale the imageview to its width, else just fit the imageview in max available height
    private func calcScaleforImageToResizeImageView(image: UIImage?, inMaxHeight: CGFloat, inMaxWidth: CGFloat) {
        var newheight = inMaxHeight
        if let img = image {
            let ratio = inMaxWidth / img.size.width
            newheight = ratio * img.size.height

            // don't let the new height get too big or the bottom text falls below the toolbar
            if newheight > inMaxHeight { newheight = inMaxHeight }
        }
        dispatch_async(dispatch_get_main_queue(), { self.resizeImageView(newheight) })
    }


}
