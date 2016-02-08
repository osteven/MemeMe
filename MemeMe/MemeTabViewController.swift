//
//  MemeTabViewController.swift
//  MemeMeV1
//
//  Created by Steven O'Toole on 3/23/15.
//  Copyright (c) 2015 Steven O'Toole. All rights reserved.
//

import UIKit

class MemeTabViewController: UITabBarController {

    private let memeManager = (UIApplication.sharedApplication().delegate as! AppDelegate).memeManager

    func presentMemeEditorModal() {

        if let currentSelectedTabVC = self.selectedViewController {
            let editController = currentSelectedTabVC.storyboard!.instantiateViewControllerWithIdentifier("MemeEditViewController") as! EditMemeViewController
            editController.currentMeme = nil
            currentSelectedTabVC.presentViewController(editController, animated: true, completion: nil)
        }

    }
    

}
