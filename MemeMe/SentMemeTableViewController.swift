//
//  SentMemeTableViewController.swift
//  MemeMe
//
//  Created by Steven O'Toole on 3/20/15.
//  Copyright (c) 2015 Steven O'Toole. All rights reserved.
//

import UIKit

class SentMemeTableViewController: UIViewController, UITableViewDelegate {

    // MARK: -
    // MARK: Properties & Outlets
    private let memeManager = (UIApplication.sharedApplication().delegate as AppDelegate).memeManager
    @IBOutlet weak var tableView: UITableView!



    // MARK: -
    // MARK: Loading & showing the editor
    override func viewDidLoad() {
        super.viewDidLoad()

        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("presentMemeEditorModal"))
        self.navigationItem.rightBarButtonItem = addButton;

        let editButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: Selector("doEditMode"))
        self.navigationItem.leftBarButtonItem = editButton;
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        dispatch_async(dispatch_get_main_queue(), { self.tableView.reloadData() })
    }


    func doEditMode() {
               self.tableView.editing = true
    }

    private func presentMemeEditorModal() {
        let editController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditViewController")! as EditMemeViewController
        editController.memeManager = self.memeManager
        editController.currentMeme = nil
        self.presentViewController(editController, animated: true, completion: nil)
    }



    // MARK: -
    // MARK: UITableViewDataSource support
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memeManager.numberOfMemes()
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("SentMemeTableCell") as UITableViewCell
        let meme = memeManager.memeAtIndex(indexPath.row)

        cell.textLabel?.text = meme.topString
        if let i = meme.memedImage {
            cell.imageView?.image = i
        }

        if let detailTextLabel = cell.detailTextLabel {
            detailTextLabel.text = meme.bottomString
        }
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //    self.presentMemeEditorModal(memeManager.memeAtIndex(indexPath.row))

        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as MemeDetailViewController
        controller.memeManager = self.memeManager
        controller.currentMeme = memeManager.memeAtIndex(indexPath.row)
        self.navigationController?.pushViewController(controller, animated: true)
        //   self.presentViewController(controller, animated: true, completion: nil)
    }

//
//    func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
//        self.tableView.editing = true
//    }
//
//    func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
//        self.tableView.editing = false
//    }

    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if self.tableView.editing {
            return UITableViewCellEditingStyle.Delete
        }
        return UITableViewCellEditingStyle.None
    }


    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.memeManager.removeMemeAtIndex(indexPath.row)
            self.tableView.editing = false
            self.tableView.reloadData()
        }
    }

}
