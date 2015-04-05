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
//    private let memeManager = (UIApplication.sharedApplication().delegate as AppDelegate).memeManager

    @IBOutlet weak var imageView: UIImageView!

    // MARK: -
    // MARK: Load 
    override func viewDidLoad() {
        super.viewDidLoad()

        if let meme = currentMeme {
            imageView.image = meme.memedImage
        }

    }

}
