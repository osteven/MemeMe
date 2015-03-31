//
//  MemeStruct.swift
//  MemeMeV1
//
//  Created by Steven O'Toole on 3/20/15.
//  Copyright (c) 2015 Steven O'Toole. All rights reserved.
//

import Foundation
import UIKit

class Meme {

    var topString: String
    var bottomString: String
    var originalImage: UIImage? = nil
    var memedImage: UIImage? = nil


    init(top: String, bottom: String) {
        self.topString = top
        self.bottomString = bottom
    }

}