//
//  MemeGridViewController.swift
//  MemeMe
//
//  Created by Steven O'Toole on 4/3/15.
//  Copyright (c) 2015 Steven O'Toole. All rights reserved.
//

import UIKit


class MemeGridViewController: UICollectionViewController, UICollectionViewDelegate {

    // MARK: -
    // MARK: Properties & Outlets
    private let memeManager = (UIApplication.sharedApplication().delegate as AppDelegate).memeManager
    private let reuseIdentifier = "SentMemeCollectionCell"
    private var isEditing = false


    // MARK: -
    // MARK: Loading & showing the editor
    override func viewDidLoad() {
        super.viewDidLoad()

        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("presentMemeEditorModal"))
        self.navigationItem.leftBarButtonItem = addButton;
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    /*
    Edit view controller knows how to present itself in a class function.  This eliminates duplicate code
    between the list and the grid views
    */
    func presentMemeEditorModal() {
        EditMemeViewController.presentForAddingOrEditingMeme(self)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        dispatch_async(dispatch_get_main_queue(), { self.collectionView!.reloadData() })
    }
    



    // MARK: -
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memeManager.numberOfMemes()
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as MemeCollectionViewCell

        cell.deleteButton.hidden = !self.isEditing
        cell.deleteButton.tag = indexPath.row

        let meme = memeManager.memeAtIndex(indexPath.row)
        if let i = meme.memedImage {
            cell.imageView.image = i
            cell.topLabel.hidden = true
            cell.bottomLabel.hidden = true
            cell.imageView.hidden = false
        } else {
            cell.topLabel.text = meme.topString
            cell.bottomLabel.text = meme.bottomString
            cell.topLabel.hidden = false
            cell.bottomLabel.hidden = false
            cell.imageView.hidden = true
        }
        return cell
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as MemeDetailViewController
        controller.currentMeme = memeManager.memeAtIndex(indexPath.row)
        self.navigationController?.pushViewController(controller, animated: true)
    }


    /*
    This is the action for the delete button in the collection item prototype.  Each button's tag is set
    in collectionView cellForItemAtIndexPath, along with the hidden state.  If not in editing, the delete
    buttons are hidden.
    */
    @IBAction func doDelete(sender: UIButton) {
        assert(self.isEditing)
        self.memeManager.removeMemeAtIndex(sender.tag)
        self.collectionView!.reloadData()
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.isEditing = editing
        self.collectionView!.reloadData()
    }


    // MARK: -
    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
            cell.contentView.backgroundColor = UIColor(red: 173.0, green: 216.0, blue: 230.0, alpha: 0.5)

        }
    }

    override func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
            cell.contentView.backgroundColor = nil
        }
    }





}
