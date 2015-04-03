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
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        dispatch_async(dispatch_get_main_queue(), { self.tableView.reloadData() })
    }


    func presentMemeEditorModal() {
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


}
