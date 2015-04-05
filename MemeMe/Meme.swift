//
//  MemeStruct.swift
//  MemeMe
//
//  Created by Steven O'Toole on 3/20/15.
//  Copyright (c) 2015 Steven O'Toole. All rights reserved.
//

import Foundation
import UIKit

class Meme: Equatable {

    var topString: String
    var bottomString: String
    var originalImage: UIImage? = nil
    var memedImage: UIImage? = nil


    init(top: String, bottom: String) {
        self.topString = top
        self.bottomString = bottom
    }
}



func == (lhs: Meme, rhs: Meme) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}