//
//  MemeManager.swift
//  MemeMeV1
//
//  Created by Steven O'Toole on 3/20/15.
//  Copyright (c) 2015 Steven O'Toole. All rights reserved.
//

import Foundation


class MemeManager {

    var memeList = [Meme]()

    func numberOfMemes() -> Int { return memeList.count }
    func memeAtIndex(row: Int) -> Meme { return memeList[row] }
    func appendMeme(meme: Meme) { memeList.append(meme) }
    func removeMemeAtIndex(row: Int) { memeList.removeAtIndex(row) }

    func removeMeme(meme: Meme?) {
        if nil == meme { return }
        if let index = find(self.memeList, meme!) {
            self.memeList.removeAtIndex(index)
        }
    }

}