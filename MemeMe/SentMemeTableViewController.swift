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
        self.navigationItem.leftBarButtonItem = addButton
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        dispatch_async(dispatch_get_main_queue(), { self.tableView.reloadData() })
    }


    /*
    Edit view controller knows how to present itself in a class function.  This eliminates duplicate code 
    between the list and the grid views
    */
    func presentMemeEditorModal() {
        EditMemeViewController.presentForAddingOrEditingMeme(self)
    }



    // MARK: -
    // MARK: UITableViewDataSource support
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memeManager.numberOfMemes()
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SentMemeTableCell") as UITableViewCell
        let meme = memeManager.memeAtIndex(indexPath.row)


//        cell.separatorInset = UIEdgeInsetsZero
//        cell.preservesSuperviewLayoutMargins = true
//        cell.layoutMargins = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)


        cell.textLabel?.text = meme.topString
        if let i = meme.memedImage {
            cell.imageView?.image = i
//            cell.imageView?.contentMode = .Center
//            cell.imageView?.bounds.size.height = 30.0
        }

        if let detailTextLabel = cell.detailTextLabel {
            detailTextLabel.text = meme.bottomString
        }
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as MemeDetailViewController
        controller.currentMeme = memeManager.memeAtIndex(indexPath.row)
        self.navigationController?.pushViewController(controller, animated: true)
    }


    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.editing = editing
    }


    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if self.tableView.editing {
            return UITableViewCellEditingStyle.Delete
        }
        return UITableViewCellEditingStyle.None
    }


    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.memeManager.removeMemeAtIndex(indexPath.row)
            self.tableView.reloadData()
        }
    }


}
