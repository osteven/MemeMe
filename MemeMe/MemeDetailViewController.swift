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
    private let VERTICAL_MARGIN: CGFloat = 2.0
//    private let memeManager = (UIApplication.sharedApplication().delegate as AppDelegate).memeManager
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var imageView: UIImageView!

    // MARK: -
    // MARK: Load 
    override func viewDidLoad() {
        super.viewDidLoad()

        if let meme = currentMeme {
            imageView.image = meme.memedImage
            dispatch_async(dispatch_get_main_queue(), {
                self.calcScaleforImageToResizeImageView(self.imageView.image!, inMaxHeight: self.getAvailableHeight(),
                    inMaxWidth: self.imageView.bounds.size.width)
            })
        }
    }

    // There's more room for the image if you hide the status bar.  If this is not set
    // to true, have to change getAvailableHeight() to subtract the height of the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }



    // most of the time, we just need to start out with the view bounds, but on a rotate, we'll need the incoming size
    private func getAvailableHeight() -> CGFloat { return getAvailableHeight(self.view.bounds.size.height) }
    private func getAvailableHeight(rawHeight: CGFloat) -> CGFloat {
        //   CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
        let tabHeight = self.tabBarController!.tabBar.bounds.height
        let navHeight = self.navigationController!.navigationBar.bounds.height
        return rawHeight - navHeight - tabHeight - VERTICAL_MARGIN
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
