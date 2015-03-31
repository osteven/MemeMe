//
//  MemeTabViewController.swift
//  MemeMeV1
//
//  Created by Steven O'Toole on 3/23/15.
//  Copyright (c) 2015 Steven O'Toole. All rights reserved.
//

import UIKit

class MemeTabViewController: UITabBarController {

    private let memeManager = (UIApplication.sharedApplication().delegate as AppDelegate).memeManager
    private var isFirstAppearance = true

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if isFirstAppearance && memeManager.numberOfMemes() == 0 {
            /* Don't show the editor until after the tab bar has completed initialization.
            This avoids a warning: "Unbalanced calls to begin/end appearance transitions for <UITabBarController>"
            http://stackoverflow.com/questions/8563473/unbalanced-calls-to-begin-end-appearance-transitions-for-uitabbarcontroller
            */
            let delayInSeconds = Int64(0.1 * Double(NSEC_PER_SEC));
            dispatch_time(DISPATCH_TIME_NOW, delayInSeconds);
            dispatch_async(dispatch_get_main_queue(), { self.presentMemeEditorModal() })
        }
        isFirstAppearance = false
    }


    func presentMemeEditorModal() {

        if let currentSelectedTabVC = self.selectedViewController {
            let editController = currentSelectedTabVC.storyboard!.instantiateViewControllerWithIdentifier("MemeEditor")! as EditMemeViewController
            editController.memeManager = self.memeManager
//            if let tableVC = currentSelectedTabVC as? SentMemeTableViewController {
//                editController.parentTable = tableVC.tableView
//            } else  {
//                println("parenttable not set")
//                editController.parentTable = nil
//            }
            editController.currentMeme = nil
            currentSelectedTabVC.presentViewController(editController, animated: true, completion: nil)
        }

    }
    

}
