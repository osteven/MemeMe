//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Steven O'Toole on 4/2/15.
//  Copyright (c) 2015 Steven O'Toole. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController     {
    // MARK: -
    // MARK: Properties
    var currentMeme: Meme? = nil
    private let memeManager = (UIApplication.sharedApplication().delegate as AppDelegate).memeManager
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!

    // MARK: -
    // MARK: Load 
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftItemsSupplementBackButton = true
        let deleteButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: Selector("deleteMeme"))
        let editButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: Selector("presentMemeEditorForEditModal"))

        let items = [deleteButton, editButton]
        self.navigationItem.rightBarButtonItems = items
    }


    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let meme = currentMeme {
            if let image = meme.memedImage {
                imageView.image = image
                self.calcScaleforImageToResizeImageView(self.imageView.image!, inMaxHeight: self.getAvailableHeight(),
                    inMaxWidth: getActualWidth(self.view))
            }
        }
    }

    // There's more room for the image if you hide the status bar.  If this is not set
    // to true, have to change getAvailableHeight() to subtract the height of the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }


    // MARK: -
    // MARK: Edit & Delete
    // note: these two functions are assigned to UIBarButtonItem Selectors and cannot be private
    func deleteMeme() {
        memeManager.removeMeme(self.currentMeme)
        self.navigationController?.popViewControllerAnimated(true)
    }


    /*
    Edit view controller knows how to present itself in a class function.  This eliminates duplicate code
    between the list and the grid views
    */
    func presentMemeEditorForEditModal() {
        EditMemeViewController.presentForAddingOrEditingMeme(self, editMeme: currentMeme)
    }




    // MARK: -
    // MARK: Resize UIImageView for best fit of UIImage in available space

    private func getActualWidth(inView: UIView) -> CGFloat {
        var realWidth: CGFloat = (UIScreen.mainScreen().bounds.height > UIScreen.mainScreen().bounds.width) ? UIScreen.mainScreen().bounds.size.width : UIScreen.mainScreen().bounds.size.height
        return realWidth
    }


    private func getAvailableHeight() -> CGFloat { return getAvailableHeight(self.view.bounds.size.height) }
    private func getAvailableHeight(rawHeight: CGFloat) -> CGFloat {
        let tabHeight = self.tabBarController!.tabBar.bounds.height
        let navHeight = self.navigationController!.navigationBar.bounds.height
        return rawHeight - navHeight - tabHeight
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


}
